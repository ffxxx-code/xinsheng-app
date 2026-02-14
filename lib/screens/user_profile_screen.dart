import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/utils.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/note_card.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final notesAsync = ref.watch(userNotesStreamProvider(userId));

    return FutureBuilder(
      future: AuthService.getUserById(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isFollowing = currentUser?.following.contains(userId) ?? false;
        final isSelf = currentUser?.id == userId;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 180,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF333333),
                          const Color(0xFF333333).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              child: AvatarWidget(
                                avatar: user.avatar,
                                fallbackText: user.nickname.isNotEmpty
                                    ? user.nickname
                                    : user.username,
                                size: 80,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.nickname.isNotEmpty
                                        ? user.nickname
                                        : user.username,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${user.username}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isSelf)
                              ElevatedButton(
                                onPressed: currentUser != null
                                    ? () => UserService.followUser(
                                        currentUser.id, userId)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing
                                      ? Colors.grey[300]
                                      : const Color(0xFF2196F3),
                                  foregroundColor:
                                      isFollowing ? Colors.black : Colors.white,
                                ),
                                child: Text(isFollowing ? '已关注' : '关注'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                value: user.postCount.toString(),
                                label: '动态',
                              ),
                              _buildStatItem(
                                value: user.following.length.toString(),
                                label: '关注',
                              ),
                              _buildStatItem(
                                value: user.followers.length.toString(),
                                label: '粉丝',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              // User's notes
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '动态',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(top: 8)),
              notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('还没有动态',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = notes[index];
                        return NoteCard(
                          note: note,
                          author: user,
                          currentUserId: currentUser?.id,
                          onLike: currentUser != null
                              ? () => NoteService.likeNote(
                                  note.id, currentUser.id)
                              : null,
                          onComment: () => context.push(
                              '/note/${note.id}?return=/user/$userId'),
                        );
                      },
                      childCount: notes.length,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
