import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// 骨架屏基类
class SkeletonWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.skeletonBase,
      highlightColor: AppColors.skeletonHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// 圆形骨架屏
class CircleSkeleton extends StatelessWidget {
  final double size;

  const CircleSkeleton({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.skeletonBase,
      highlightColor: AppColors.skeletonHighlight,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// 文字骨架屏
class TextSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const TextSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonWidget(
      width: width,
      height: height,
      borderRadius: 4,
    );
  }
}

/// 动态卡片骨架屏
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：头像和用户名
          Row(
            children: [
              const CircleSkeleton(size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextSkeleton(width: 100, height: 16),
                    const SizedBox(height: 6),
                    TextSkeleton(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 内容
          const TextSkeleton(height: 14),
          const SizedBox(height: 8),
          const TextSkeleton(height: 14),
          const SizedBox(height: 8),
          TextSkeleton(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 14,
          ),
          const SizedBox(height: 16),
          // 图片区域
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const SkeletonWidget(
              width: double.infinity,
              height: 200,
            ),
          ),
          const SizedBox(height: 16),
          // 底部操作栏
          Row(
            children: [
              const SkeletonWidget(width: 60, height: 28, borderRadius: 14),
              const SizedBox(width: 16),
              const SkeletonWidget(width: 60, height: 28, borderRadius: 14),
              const Spacer(),
              const SkeletonWidget(width: 40, height: 28, borderRadius: 14),
            ],
          ),
        ],
      ),
    );
  }
}

/// 动态列表骨架屏
class PostListSkeleton extends StatelessWidget {
  final int itemCount;

  const PostListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const PostCardSkeleton(),
    );
  }
}

/// 用户卡片骨架屏
class UserCardSkeleton extends StatelessWidget {
  const UserCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const CircleSkeleton(size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextSkeleton(width: 120, height: 16),
                const SizedBox(height: 6),
                TextSkeleton(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 12,
                ),
              ],
            ),
          ),
          const SkeletonWidget(width: 70, height: 32, borderRadius: 16),
        ],
      ),
    );
  }
}

/// 用户列表骨架屏
class UserListSkeleton extends StatelessWidget {
  final int itemCount;

  const UserListSkeleton({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => const UserCardSkeleton(),
    );
  }
}

/// 评论骨架屏
class CommentSkeleton extends StatelessWidget {
  const CommentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleSkeleton(size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const TextSkeleton(width: 80, height: 14),
                    const SizedBox(width: 8),
                    TextSkeleton(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const TextSkeleton(height: 12),
                const SizedBox(height: 6),
                TextSkeleton(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 评论列表骨架屏
class CommentListSkeleton extends StatelessWidget {
  final int itemCount;

  const CommentListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => const CommentSkeleton(),
    );
  }
}

/// 个人资料骨架屏
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 头部背景
        Container(
          height: 150,
          width: double.infinity,
          color: AppColors.skeletonBase,
        ),
        // 头像
        Transform.translate(
          offset: const Offset(0, -40),
          child: const CircleSkeleton(size: 80),
        ),
        // 用户名
        const TextSkeleton(width: 150, height: 20),
        const SizedBox(height: 8),
        // 简介
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TextSkeleton(
            width: double.infinity,
            height: 14,
          ),
        ),
        const SizedBox(height: 24),
        // 统计栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const SkeletonWidget(width: 50, height: 24, borderRadius: 4),
                  const SizedBox(height: 4),
                  SkeletonWidget(
                    width: 40,
                    height: 12,
                    borderRadius: 2,
                  ),
                ],
              ),
              Column(
                children: [
                  const SkeletonWidget(width: 50, height: 24, borderRadius: 4),
                  const SizedBox(height: 4),
                  SkeletonWidget(
                    width: 40,
                    height: 12,
                    borderRadius: 2,
                  ),
                ],
              ),
              Column(
                children: [
                  const SkeletonWidget(width: 50, height: 24, borderRadius: 4),
                  const SizedBox(height: 4),
                  SkeletonWidget(
                    width: 40,
                    height: 12,
                    borderRadius: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 操作按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: SkeletonWidget(
                  width: double.infinity,
                  height: 40,
                  borderRadius: 20,
                ),
              ),
              const SizedBox(width: 12),
              const SkeletonWidget(width: 44, height: 40, borderRadius: 20),
            ],
          ),
        ),
      ],
    );
  }
}

/// 通知骨架屏
class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleSkeleton(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextSkeleton(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                TextSkeleton(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 14,
                ),
                const SizedBox(height: 8),
                SkeletonWidget(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: 12,
                  borderRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 通知列表骨架屏
class NotificationListSkeleton extends StatelessWidget {
  final int itemCount;

  const NotificationListSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => const NotificationSkeleton(),
    );
  }
}

/// 网格骨架屏
class GridSkeleton extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double childAspectRatio;

  const GridSkeleton({
    super.key,
    this.crossAxisCount = 3,
    this.itemCount = 9,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonWidget(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
