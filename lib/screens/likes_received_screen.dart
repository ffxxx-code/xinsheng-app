import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../services/note_service.dart';
import '../services/auth_service.dart';
import '../utils/utils.dart';
import '../widgets/avatar_widget.dart';

class LikesReceivedScreen extends ConsumerWidget {
  const LikesReceivedScreen({super.key});

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
        title: const Text('获赞'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder(
        future: NoteService.getLikedNotes(user.id),
        builder: (context, snapshot) {
          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('还没有被赞的动态', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('多发优质内容，获得更多点赞',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return FutureBuilder(
                future: AuthService.getUserById(note.authorId),
                builder: (context, snapshot) {
                  final author = snapshot.data;
                  return _buildLikeItem(context, note, author);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLikeItem(BuildContext context, dynamic note, dynamic author) {
    return InkWell(
      onTap: () => context.push('/note/${note.id}?return=/likes-received'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${note.likes.length} 个赞',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatTime(note.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AvatarWidget(
                              avatar: author?.avatar,
                              fallbackText: author?.nickname ??
                                  author?.username ??
                                  'U',
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              author?.nickname ?? author?.username ?? '未知用户',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note.content.length > 50
                              ? '${note.content.substring(0, 50)}...'
                              : note.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
