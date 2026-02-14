import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/note_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';
import '../services/note_service.dart';
import '../services/auth_service.dart';
import '../utils/utils.dart';
import '../widgets/avatar_widget.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final String noteId;
  final String returnPath;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
    required this.returnPath,
  });

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    final user = ref.read(authProvider).user;

    if (content.isEmpty) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    await NoteService.addComment(
      noteId: widget.noteId,
      authorId: user.id,
      content: content,
    );

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(noteByIdProvider(widget.noteId));
    final currentUser = ref.watch(authProvider).user;
    final commentsAsync = ref.watch(commentsStreamProvider(widget.noteId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(widget.returnPath),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: noteAsync.when(
        data: (note) {
          if (note == null) {
            return const Center(child: Text('动态不存在'));
          }

          return FutureBuilder(
            future: AuthService.getUserById(note.authorId),
            builder: (context, snapshot) {
              final author = snapshot.data;
              final isLiked = note.likes.contains(currentUser?.id);
              final isFavorited = note.favorites.contains(currentUser?.id);

              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        // Note content
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Author
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (author != null) {
                                          context.push('/user/${author.id}');
                                        }
                                      },
                                      child: AvatarWidget(
                                        avatar: author?.avatar,
                                        fallbackText: author?.nickname ??
                                            author?.username ??
                                            'U',
                                        size: 44,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            author?.nickname ??
                                                author?.username ??
                                                '未知用户',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            formatTime(note.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Content
                                Text(
                                  note.content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                ),
                                // Location
                                if (note.location != null &&
                                    note.location!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        note.location!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),
                                // Actions
                                Row(
                                  children: [
                                    _buildActionButton(
                                      icon: isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      count: note.likes.length,
                                      isActive: isLiked,
                                      onTap: currentUser != null
                                          ? () => NoteService.likeNote(
                                              note.id, currentUser.id)
                                          : null,
                                      activeColor: Colors.red,
                                    ),
                                    const SizedBox(width: 24),
                                    _buildActionButton(
                                      icon: Icons.chat_bubble_outline,
                                      count: note.comments,
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 24),
                                    _buildActionButton(
                                      icon: isFavorited
                                          ? Icons.star
                                          : Icons.star_border,
                                      count: note.favorites.length,
                                      isActive: isFavorited,
                                      onTap: currentUser != null
                                          ? () => NoteService.favoriteNote(
                                              note.id, currentUser.id)
                                          : null,
                                      activeColor: Colors.amber,
                                    ),
                                  ],
                                ),
                                const Divider(height: 48),
                                // Comments header
                                const Text(
                                  '评论',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        // Comments list
                        commentsAsync.when(
                          data: (comments) {
                            if (comments.isEmpty) {
                              return const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_bubble_outline,
                                          size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('还没有评论',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final comment = comments[index];
                                  return FutureBuilder(
                                    future: AuthService.getUserById(
                                        comment.authorId),
                                    builder: (context, snapshot) {
                                      final author = snapshot.data;
                                      return _buildCommentItem(
                                          context, comment, author);
                                    },
                                  );
                                },
                                childCount: comments.length,
                              ),
                            );
                          },
                          loading: () => const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stack) => SliverFillRemaining(
                            child: Center(child: Text('加载失败: $error')),
                          ),
                        ),
                        const SliverPadding(
                            padding: EdgeInsets.only(bottom: 80)),
                      ],
                    ),
                  ),
                  // Comment input
                  Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: MediaQuery.of(context).padding.bottom + 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: '写下你的评论...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _addComment(),
                          ),
                        ),
                        IconButton(
                          onPressed: _addComment,
                          icon: const Icon(Icons.send),
                          color: const Color(0xFF2196F3),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    bool isActive = false,
    VoidCallback? onTap,
    Color? activeColor,
  }) {
    final color = isActive ? activeColor : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 15,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(
      BuildContext context, dynamic comment, UserModel? author) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (author != null) {
                context.push('/user/${author.id}');
              }
            },
            child: AvatarWidget(
              avatar: author?.avatar,
              fallbackText:
                  author?.nickname ?? author?.username ?? 'U',
              size: 36,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author?.nickname ?? author?.username ?? '未知用户',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 4),
                Text(
                  formatTime(comment.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
