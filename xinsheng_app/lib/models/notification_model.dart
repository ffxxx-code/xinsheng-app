import 'package:cloud_firestore/cloud_firestore.dart';

/// 通知类型枚举
enum NotificationType {
  like,      // 点赞
  comment,   // 评论
  follow,    // 关注
  mention,   // 提及
  system,    // 系统通知
}

/// 通知模型
class NotificationModel {
  final String id;
  final String userId;           // 接收通知的用户ID
  final String? senderId;        // 发送者ID
  final String? senderName;      // 发送者名称
  final String? senderAvatar;    // 发送者头像
  final NotificationType type;   // 通知类型
  final String title;            // 通知标题
  final String body;             // 通知内容
  final String? postId;          // 相关动态ID
  final String? commentId;       // 相关评论ID
  final bool read;               // 是否已读
  final DateTime createdAt;      // 创建时间
  final Map<String, dynamic>? data; // 额外数据

  NotificationModel({
    required this.id,
    required this.userId,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.type,
    required this.title,
    required this.body,
    this.postId,
    this.commentId,
    this.read = false,
    required this.createdAt,
    this.data,
  });

  /// 从 Firestore 文档创建
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      senderId: data['senderId'],
      senderName: data['senderName'],
      senderAvatar: data['senderAvatar'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.system,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      postId: data['postId'],
      commentId: data['commentId'],
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: data['data'],
    );
  }

  /// 从 JSON 创建（用于本地存储）
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      postId: json['postId'],
      commentId: json['commentId'],
      read: json['read'] ?? false,
      createdAt: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      data: json['data'] != null 
          ? Map<String, dynamic>.from(json['data']) 
          : null,
    );
  }

  /// 转换为 Firestore 数据
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.name,
      'title': title,
      'body': body,
      'postId': postId,
      'commentId': commentId,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
      'data': data,
    };
  }

  /// 转换为 JSON（用于本地存储）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.name,
      'title': title,
      'body': body,
      'postId': postId,
      'commentId': commentId,
      'read': read,
      'timestamp': createdAt.toIso8601String(),
      'data': data,
    };
  }

  /// 复制并修改
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    NotificationType? type,
    String? title,
    String? body,
    String? postId,
    String? commentId,
    bool? read,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  /// 获取类型图标
  String get typeIcon {
    switch (type) {
      case NotificationType.like:
        return '❤️';
      case NotificationType.comment:
        return '💬';
      case NotificationType.follow:
        return '👤';
      case NotificationType.mention:
        return '@';
      case NotificationType.system:
        return '📢';
    }
  }

  /// 获取类型描述
  String get typeDescription {
    switch (type) {
      case NotificationType.like:
        return '赞了你的动态';
      case NotificationType.comment:
        return '评论了你的动态';
      case NotificationType.follow:
        return '关注了你';
      case NotificationType.mention:
        return '提到了你';
      case NotificationType.system:
        return '系统通知';
    }
  }
}
