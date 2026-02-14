import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../services/message_service.dart';
import '../services/auth_service.dart';
import '../services/note_service.dart';
import '../utils/utils.dart';
import '../widgets/avatar_widget.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('请先登录')),
      );
    }

    final messagesAsync = ref.watch(messagesStreamProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          TextButton(
            onPressed: () => MessageService.markAllAsRead(user.id),
            child: const Text('全部已读'),
          ),
        ],
      ),
      body: messagesAsync.when(
        data: (messages) {
          if (messages.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('还没有消息', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageItem(context, message, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('加载失败: $error'),
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, dynamic message, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !message.read;

    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => MessageService.deleteMessage(message.id),
      child: InkWell(
        onTap: () async {
          await MessageService.markAsRead(message.id);

          // Navigate to related content
          if (message.noteId != null) {
            context.push('/note/${message.noteId}?return=/');
          } else if (message.fromUserId != null) {
            context.push('/user/${message.fromUserId}');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            color: isUnread
                ? (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildMessageAvatar(message),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getMessageTitle(message),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          formatTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (message.noteContent != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message.noteContent,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isUnread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageAvatar(dynamic message) {
    if (message.type == 'system') {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF333333), Color(0xFF666666)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '声',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return FutureBuilder(
      future: AuthService.getUserById(message.fromUserId ?? ''),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return AvatarWidget(
          avatar: user?.avatar,
          fallbackText: user?.nickname ?? user?.username ?? 'U',
          size: 44,
        );
      },
    );
  }

  String _getMessageTitle(dynamic message) {
    switch (message.type) {
      case 'system':
        return '系统通知';
      case 'like':
        return '新的赞';
      case 'comment':
        return '新的评论';
      case 'follow':
        return '新的关注';
      default:
        return '消息';
    }
  }
}
