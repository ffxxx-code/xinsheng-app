import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/post_model.dart';
import '../models/user_model.dart';

/// 分享服务
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// 分享动态
  Future<void> sharePost(PostModel post, {UserModel? author}) async {
    final StringBuffer content = StringBuffer();
    
    // 标题
    content.writeln('📱 来自心声的分享');
    content.writeln();
    
    // 作者信息
    if (author != null) {
      content.writeln('👤 ${author.nickname}');
      content.writeln();
    }
    
    // 动态内容
    content.writeln(post.content);
    content.writeln();
    
    // 统计信息
    content.writeln('❤️ ${post.likesCount}  👁️ ${post.viewsCount}  💬 ${post.commentsCount}');
    content.writeln();
    
    // 应用链接
    content.writeln('—— 下载心声，记录你的生活 ——');
    content.writeln('https://xinsheng.app/post/${post.id}');
    
    try {
      await Share.share(
        content.toString(),
        subject: '心声 - ${author?.nickname ?? "用户"}的动态',
      );
    } catch (e) {
      debugPrint('分享动态失败: $e');
    }
  }

  /// 分享用户主页
  Future<void> shareUserProfile(UserModel user) async {
    final StringBuffer content = StringBuffer();
    
    content.writeln('👤 ${user.nickname}');
    content.writeln();
    
    if (user.bio != null && user.bio!.isNotEmpty) {
      content.writeln('📝 ${user.bio}');
      content.writeln();
    }
    
    content.writeln('📊 关注 ${user.followingCount}  |  获赞 ${user.likesReceived}  |  动态 ${user.postsCount}');
    content.writeln();
    content.writeln('—— 在心声发现更多精彩内容 ——');
    content.writeln('https://xinsheng.app/user/${user.id}');
    
    try {
      await Share.share(
        content.toString(),
        subject: '心声 - ${user.nickname}的个人主页',
      );
    } catch (e) {
      debugPrint('分享用户主页失败: $e');
    }
  }

  /// 分享应用
  Future<void> shareApp() async {
    const String content = '''
📱 心声 - 极简笔记社区

一个纯粹的记录空间，让每一次分享都回归本真。

✨ 特色功能：
• 简洁优雅的界面设计
• 支持文字、图片多种内容形式
• 关注感兴趣的用户和话题
• 发现精彩的生活记录

👇 立即下载体验
https://xinsheng.app/download
''';  
    
    try {
      await Share.share(
        content,
        subject: '推荐一个好用的应用 - 心声',
      );
    } catch (e) {
      debugPrint('分享应用失败: $e');
    }
  }

  /// 分享文本
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject);
    } catch (e) {
      debugPrint('分享文本失败: $e');
    }
  }

  /// 分享图片（需要文件路径）
  Future<void> shareImage(String imagePath, {String? text}) async {
    try {
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: text,
      );
    } catch (e) {
      debugPrint('分享图片失败: $e');
    }
  }

  /// 分享多张图片
  Future<void> shareMultipleImages(List<String> imagePaths, {String? text}) async {
    try {
      final files = imagePaths.map((path) => XFile(path)).toList();
      await Share.shareXFiles(files, text: text);
    } catch (e) {
      debugPrint('分享多张图片失败: $e');
    }
  }
}
