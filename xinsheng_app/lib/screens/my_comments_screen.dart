import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart';
import '../services/note_service.dart';
import '../services/auth_service.dart';
import '../utils/utils.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/refresh_widgets.dart';

class MyCommentsScreen extends ConsumerWidget {
  const MyCommentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('请先登录')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的评论'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('comments')
            .where('authorId', isEqualTo: user.id)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ErrorStateWidget(
              message: '加载失败: ${snapshot.error}',
              onRetry: () => ref.refresh(authProvider),
            );
          }

          final comments = snapshot.data?.docs ?? [];

          if (comments.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.comment_outlined,
              title: '还没有评论',
              subtitle: '去动态下方留下你的第一条评论吧',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final data = comment.data() as Map<String, dynamic>;
              return _buildCommentItem(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, Map<String, dynamic> data) {
    final noteId = data['noteId'] as String?;
    final content = data['content'] as String? ?? '';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return InkWell(
      onTap: noteId != null ? () => context.push('/note/$noteId?return=/my-comments') : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.comment, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  formatTime(createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            if (noteId != null) ...[
              const SizedBox(height: 12),
              FutureBuilder(
                future: NoteService.getNoteById(noteId),
                builder: (context, snapshot) {
                  final note = snapshot.data;
                  if (note == null) return const SizedBox.shrink();
                  
                  return FutureBuilder(
                    future: AuthService.getUserById(note.authorId),
                    builder: (context, authorSnapshot) {
                      final author = authorSnapshot.data;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            AvatarWidget(
                              avatar: author?.avatar,
                              fallbackText: author?.nickname ?? author?.username ?? 'U',
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                note.content.length > 50
                                    ? '${note.content.substring(0, 50)}...'
                                    : note.content,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
