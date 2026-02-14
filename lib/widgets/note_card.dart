import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/note_model.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';
import 'avatar_widget.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final UserModel? author;
  final String? currentUserId;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMore;

  const NoteCard({
    super.key,
    required this.note,
    this.author,
    this.currentUserId,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLiked = note.likes.contains(currentUserId);
    final isFavorited = note.favorites.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/note/${note.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (author != null) {
                        context.push('/user/${author!.id}');
                      }
                    },
                    child: AvatarWidget(
                      avatar: author?.avatar,
                      fallbackText: author?.nickname ?? author?.username ?? 'U',
                      size: 40,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatTime(note.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onMore != null)
                    IconButton(
                      onPressed: onMore,
                      icon: const Icon(Icons.more_vert, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Content
              Text(
                note.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              // Location
              if (note.location != null && note.location!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      note.location!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // Actions
              Row(
                children: [
                  _buildActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    count: note.likes.length,
                    isActive: isLiked,
                    onTap: onLike,
                    activeColor: Colors.red,
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    count: note.comments,
                    onTap: onComment,
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    icon: isFavorited ? Icons.star : Icons.star_border,
                    count: note.favorites.length,
                    isActive: isFavorited,
                    onTap: () {}, // TODO: Implement favorite
                    activeColor: Colors.amber,
                  ),
                  const Spacer(),
                  if (onShare != null)
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      count: 0,
                      onTap: onShare,
                    ),
                ],
              ),
            ],
          ),
        ),
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
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
