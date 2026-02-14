import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';
import '../services/note_service.dart';
import '../services/auth_service.dart';
import '../services/share_service.dart';
import '../widgets/note_card.dart';
import '../widgets/skeleton_widgets.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/refresh_widgets.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesStreamProvider);
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('心声'),
        centerTitle: true,
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return PullToRefresh(
              onRefresh: () async => ref.refresh(notesStreamProvider),
              child: const EmptyStateWidget(
                icon: Icons.inbox_outlined,
                title: '还没有动态',
                subtitle: '点击右下角按钮发布第一条动态',
              ),
            );
          }

          return PullToRefresh(
            onRefresh: () async => ref.refresh(notesStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return FadeSlideAnimation(
                  delay: Duration(milliseconds: index * 50),
                  child: FutureBuilder(
                    future: AuthService.getUserById(note.authorId),
                    builder: (context, snapshot) {
                      final author = snapshot.data;
                      return NoteCard(
                        note: note,
                        author: author,
                        currentUserId: currentUser?.id,
                        onLike: currentUser != null
                            ? () => NoteService.likeNote(note.id, currentUser.id)
                            : null,
                        onComment: () => context.push('/note/${note.id}'),
                        onShare: () => ShareService().sharePost(note, author: author),
                        onMore: note.authorId == currentUser?.id
                            ? () => _showNoteOptions(context, note.id, currentUser!.id)
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const SkeletonLoadingWidget(
          itemCount: 5,
          skeleton: PostCardSkeleton(),
        ),
        error: (error, stack) => ErrorStateWidget(
          message: '加载失败: $error',
          onRetry: () => ref.refresh(notesStreamProvider),
        ),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, String noteId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('删除后无法恢复，确定要删除吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('删除', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await NoteService.deleteNote(noteId, userId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('取消'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
