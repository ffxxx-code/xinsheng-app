import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';
import '../providers/message_provider.dart';
import '../services/note_service.dart';
import '../services/auth_service.dart';
import '../services/share_service.dart';
import '../utils/utils.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/note_card.dart';
import '../widgets/user_dashboard.dart';
import '../widgets/animated_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('请先登录')),
      );
    }

    final notesAsync = ref.watch(userNotesStreamProvider(user.id));
    final unreadCount = ref.watch(unreadCountStreamProvider(user.id)).value ?? 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with settings button
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
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
            actions: [
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          // Profile info
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Avatar and name
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
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Stats
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
                            context,
                            value: user.following.length.toString(),
                            label: '关注',
                            onTap: () => context.push('/following'),
                          ),
                          _buildStatItem(
                            context,
                            value: user.followers.length.toString(),
                            label: '粉丝',
                            onTap: () {},
                          ),
                          _buildStatItem(
                            context,
                            value: '0', // TODO: Calculate total likes
                            label: '获赞',
                            onTap: () => context.push('/likes-received'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Menu items
                    _buildMenuItem(
                      context,
                      icon: Icons.article_outlined,
                      title: '我的发布',
                      onTap: () => context.push('/my-notes'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.favorite_outline,
                      title: '赞过与收藏',
                      onTap: () => context.push('/my-favorites'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.comment_outlined,
                      title: '我的评论',
                      onTap: () => context.push('/my-comments'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.share_outlined,
                      title: '分享给朋友',
                      onTap: () => ShareService().shareApp(),
                    ),
                    const SizedBox(height: 24),
                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('确认退出'),
                              content: const Text('确定要退出登录吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('退出',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await ref.read(authProvider.notifier).logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('退出登录'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Version info
                    Text(
                      '心声 v1.0.0\n此刻，你想说',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
