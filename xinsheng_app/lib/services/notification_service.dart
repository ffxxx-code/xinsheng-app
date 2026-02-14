import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';

/// 后台消息处理函数
/// 必须在顶层定义
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('后台收到消息: ${message.messageId}');
  // 后台消息处理逻辑
}

/// 推送通知服务
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  /// 通知点击回调
  Function(NotificationModel)? onNotificationTap;

  /// 获取 FCM Token
  String? get fcmToken => _fcmToken;

  /// 初始化推送通知服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 请求通知权限
    await _requestPermission();

    // 设置前台通知展示选项
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 初始化本地通知
    await _initLocalNotifications();

    // 设置后台消息处理
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 监听前台消息
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 监听通知点击（从终止状态）
    FirebaseMessaging.instance.getInitialMessage().then(_handleTerminatedMessage);

    // 监听通知点击（从后台状态）
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // 获取 FCM Token
    await _updateFcmToken();

    // 监听 Token 刷新
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _saveToken(token);
    });

    _isInitialized = true;
    debugPrint('推送通知服务初始化完成');
  }

  /// 请求通知权限
  Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('通知权限状态: ${settings.authorizationStatus}');
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// 初始化本地通知
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // 创建 Android 通知渠道
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// 创建 Android 通知渠道
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'xinsheng_channel',
      '心声通知',
      description: '心声应用的通知渠道',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 处理前台消息
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('前台收到消息: ${message.notification?.title}');
    
    final notification = message.notification;
    if (notification == null) return;

    // 显示本地通知
    _showLocalNotification(
      id: message.hashCode,
      title: notification.title ?? '新消息',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );

    // 保存通知到本地
    _saveNotificationToLocal(message);
  }

  /// 处理后台消息点击
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('从后台点击通知: ${message.notification?.title}');
    _processNotificationTap(message.data);
  }

  /// 处理终止状态消息点击
  void _handleTerminatedMessage(RemoteMessage? message) {
    if (message == null) return;
    debugPrint('从终止状态点击通知: ${message.notification?.title}');
    _processNotificationTap(message.data);
  }

  /// 处理本地通知点击
  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _processNotificationTap(data);
    } catch (e) {
      debugPrint('解析通知数据失败: $e');
    }
  }

  /// 处理通知点击
  void _processNotificationTap(Map<String, dynamic> data) {
    final notification = NotificationModel.fromJson(data);
    onNotificationTap?.call(notification);
  }

  /// 显示本地通知
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'xinsheng_channel',
      '心声通知',
      channelDescription: '心声应用的通知渠道',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 保存通知到本地
  Future<void> _saveNotificationToLocal(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    
    final notificationData = {
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };

    notifications.insert(0, jsonEncode(notificationData));
    
    // 只保留最近 100 条通知
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }

    await prefs.setStringList('notifications', notifications);
  }

  /// 更新 FCM Token
  Future<void> _updateFcmToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        await _saveToken(_fcmToken!);
      }
    } catch (e) {
      debugPrint('获取 FCM Token 失败: $e');
    }
  }

  /// 保存 Token 到本地
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// 订阅主题
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('订阅主题: $topic');
  }

  /// 取消订阅主题
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('取消订阅主题: $topic');
  }

  /// 获取本地通知列表
  Future<List<NotificationModel>> getLocalNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    
    return notifications.map((json) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return NotificationModel.fromJson(data);
    }).toList();
  }

  /// 标记通知为已读
  Future<void> markNotificationAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    
    final updatedNotifications = notifications.map((json) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      if (data['id'] == notificationId) {
        data['read'] = true;
        return jsonEncode(data);
      }
      return json;
    }).toList();

    await prefs.setStringList('notifications', updatedNotifications);
  }

  /// 清除所有通知
  Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    await _localNotifications.cancelAll();
  }

  /// 删除 FCM Token
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _fcmToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');
  }
}
