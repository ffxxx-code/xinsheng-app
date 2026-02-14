import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../widgets/avatar_widget.dart';

class FollowingScreen extends ConsumerStatefulWidget {
  const FollowingScreen({super.key});

  @override
  ConsumerState<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends ConsumerState<FollowingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('请先登录')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('关注'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '关注 (${user.following.length})'),
            Tab(text: '粉丝 (${user.followers.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowingList(user.id),
          _buildFollowersList(user.id),
        ],
      ),
    );
  }

  Widget _buildFollowingList(String userId) {
    return FutureBuilder(
      future: UserService.getFollowingUsers(userId),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('还没有关注任何人', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Text('去发现有趣的用户吧',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserItem(user, true);
          },
        );
      },
    );
  }

  Widget _buildFollowersList(String userId) {
    return FutureBuilder(
      future: UserService.getFollowers(userId),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('还没有粉丝', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Text('多发动态，吸引更多关注',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserItem(user, false);
          },
        );
      },
    );
  }

  Widget _buildUserItem(dynamic user, bool isFollowing) {
    final currentUser = ref.watch(authProvider).user;
    final isSelf = currentUser?.id == user.id;

    return ListTile(
      leading: GestureDetector(
        onTap: () => context.push('/user/${user.id}'),
        child: AvatarWidget(
          avatar: user.avatar,
          fallbackText: user.nickname.isNotEmpty ? user.nickname : user.username,
          size: 48,
        ),
      ),
      title: GestureDetector(
        onTap: () => context.push('/user/${user.id}'),
        child: Text(user.nickname.isNotEmpty ? user.nickname : user.username),
      ),
      subtitle: Text('@${user.username}'),
      trailing: isSelf
          ? null
          : ElevatedButton(
              onPressed: currentUser != null
                  ? () => UserService.followUser(currentUser.id, user.id)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[300] : const Color(0xFF2196F3),
                foregroundColor: isFollowing ? Colors.black : Colors.white,
              ),
              child: Text(isFollowing ? '已关注' : '关注'),
            ),
    );
  }
}
