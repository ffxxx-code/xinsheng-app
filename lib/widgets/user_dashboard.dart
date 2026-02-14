import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'animated_widgets.dart';

/// 用户数据看板
class UserDashboard extends ConsumerWidget {
  final UserModel user;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onLikesTap;
  final VoidCallback? onPostsTap;

  const UserDashboard({
    super.key,
    required this.user,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onLikesTap,
    this.onPostsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).value;
    final isCurrentUser = currentUser?.id == user.id;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头部信息
          _buildHeader(context),
          const Divider(height: 32),
          // 统计数据
          _buildStats(context),
          const SizedBox(height: 20),
          // 数据趋势
          _buildTrends(context),
          if (isCurrentUser) ...[
            const Divider(height: 32),
            // 快捷操作
            _buildQuickActions(context),
          ],
        ],
      ),
    );
  }

  /// 构建头部信息
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // 头像
        Hero(
          tag: 'user_avatar_${user.id}',
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.borderColor,
                width: 2,
              ),
              image: user.avatar != null
                  ? DecorationImage(
                      image: NetworkImage(user.avatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.avatar == null
                ? const Icon(
                    Icons.person,
                    size: 32,
                    color: AppTheme.textTertiary,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),
        // 用户信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.nickname,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  user.bio!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildBadge(
                    icon: Icons.verified,
                    label: '已认证',
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    icon: Icons.calendar_today,
                    label: '加入于 ${_formatJoinDate(user.createdAt)}',
                    color: AppTheme.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建徽章
  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计数据
  Widget _buildStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          value: user.followingCount.toString(),
          label: '关注',
          icon: Icons.people_outline,
          onTap: onFollowingTap,
        ),
        _buildDivider(),
        _buildStatItem(
          value: user.likesReceived.toString(),
          label: '获赞',
          icon: Icons.favorite_outline,
          color: AppTheme.dangerColor,
          onTap: onLikesTap,
        ),
        _buildDivider(),
        _buildStatItem(
          value: user.postsCount.toString(),
          label: '动态',
          icon: Icons.article_outlined,
          onTap: onPostsTap,
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.05) ?? AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color ?? AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color ?? AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.borderColor,
    );
  }

  /// 构建数据趋势
  Widget _buildTrends(BuildContext context) {
    // 计算增长率（模拟数据）
    final postsGrowth = _calculateGrowth(user.postsCount);
    final likesGrowth = _calculateGrowth(user.likesReceived);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '数据趋势',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTrendCard(
                title: '本周动态',
                value: '+${postsGrowth.toStringAsFixed(0)}',
                subtitle: '较上周',
                isPositive: postsGrowth > 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTrendCard(
                title: '本周获赞',
                value: '+${likesGrowth.toStringAsFixed(0)}',
                subtitle: '较上周',
                isPositive: likesGrowth > 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建趋势卡片
  Widget _buildTrendCard({
    required String title,
    required String value,
    required String subtitle,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppTheme.successColor : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_flat,
                size: 16,
                color: isPositive ? AppTheme.successColor : AppTheme.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建快捷操作
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionButton(
              icon: Icons.edit,
              label: '发布动态',
              onTap: () => Navigator.pushNamed(context, '/post/create'),
            ),
            _buildQuickActionButton(
              icon: Icons.settings,
              label: '账号设置',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            _buildQuickActionButton(
              icon: Icons.bookmark,
              label: '我的收藏',
              onTap: () => Navigator.pushNamed(context, '/bookmarks'),
            ),
            _buildQuickActionButton(
              icon: Icons.history,
              label: '浏览历史',
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建快捷操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化加入日期
  String _formatJoinDate(DateTime date) {
    return '${date.year}年${date.month}月';
  }

  /// 计算增长率（模拟）
  double _calculateGrowth(int value) {
    // 模拟增长率计算
    return value * 0.15;
  }
}

/// 迷你用户数据看板
class MiniUserDashboard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const MiniUserDashboard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FadeSlideAnimation(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: user.avatar != null
                        ? NetworkImage(user.avatar!)
                        : null,
                    backgroundColor: Colors.white24,
                    child: user.avatar == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nickname,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '查看详细数据',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('关注', user.followingCount.toString()),
                  _buildMiniStat('获赞', user.likesReceived.toString()),
                  _buildMiniStat('动态', user.postsCount.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
