import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_widgets.dart';
import 'skeleton_widgets.dart';

/// 下拉刷新包装器
class PullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppTheme.primaryColor,
      backgroundColor: backgroundColor ?? Colors.white,
      strokeWidth: 3,
      displacement: 50,
      edgeOffset: 0,
      child: child,
    );
  }
}

/// 带加载状态的列表
class LoadMoreList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final EdgeInsets padding;
  final Widget? emptyWidget;
  final Widget? header;
  final Widget? separator;

  const LoadMoreList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.hasMore,
    this.isLoading = false,
    this.padding = const EdgeInsets.all(16),
    this.emptyWidget,
    this.header,
    this.separator,
  });

  @override
  State<LoadMoreList<T>> createState() => _LoadMoreListState<T>();
}

class _LoadMoreListState<T> extends State<LoadMoreList<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.hasMore || widget.isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    await widget.onLoadMore();

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return PullToRefresh(
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            widget.emptyWidget ?? const EmptyStateWidget(),
          ],
        ),
      );
    }

    return PullToRefresh(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.items.length + (_hasFooter ? 1 : 0) + (widget.header != null ? 1 : 0),
        itemBuilder: (context, index) {
          // 头部
          if (widget.header != null && index == 0) {
            return widget.header!;
          }

          final actualIndex = widget.header != null ? index - 1 : index;

          // 列表项
          if (actualIndex < widget.items.length) {
            final item = widget.items[actualIndex];
            return Column(
              children: [
                widget.itemBuilder(context, item, actualIndex),
                if (widget.separator != null && actualIndex < widget.items.length - 1)
                  widget.separator!,
              ],
            );
          }

          // 底部加载指示器
          return _buildFooter();
        },
      ),
    );
  }

  bool get _hasFooter {
    return widget.hasMore || _isLoadingMore;
  }

  Widget _buildFooter() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: LoadingAnimation(size: 24),
        ),
      );
    }

    if (widget.hasMore) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          '已经到底了',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// 带加载状态的网格
class LoadMoreGrid<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsets padding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final Widget? emptyWidget;

  const LoadMoreGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.hasMore,
    this.isLoading = false,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16),
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
    this.emptyWidget,
  });

  @override
  State<LoadMoreGrid<T>> createState() => _LoadMoreGridState<T>();
}

class _LoadMoreGridState<T> extends State<LoadMoreGrid<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.hasMore || widget.isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    await widget.onLoadMore();

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return PullToRefresh(
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            widget.emptyWidget ?? const EmptyStateWidget(),
          ],
        ),
      );
    }

    return PullToRefresh(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: widget.padding,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                childAspectRatio: widget.childAspectRatio,
                crossAxisSpacing: widget.crossAxisSpacing,
                mainAxisSpacing: widget.mainAxisSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < widget.items.length) {
                    return widget.itemBuilder(context, widget.items[index], index);
                  }
                  return null;
                },
                childCount: widget.items.length,
              ),
            ),
          ),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: LoadingAnimation(size: 24),
                ),
              ),
            ),
          if (!widget.hasMore && widget.items.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '已经到底了',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 空状态组件
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = '暂无内容',
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 错误状态组件
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.message = '加载失败',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.dangerColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 加载状态组件
class LoadingStateWidget extends StatelessWidget {
  final String? message;

  const LoadingStateWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingAnimation(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 骨架屏加载状态
class SkeletonLoadingWidget extends StatelessWidget {
  final int itemCount;
  final Widget skeleton;

  const SkeletonLoadingWidget({
    super.key,
    this.itemCount = 5,
    this.skeleton = const PostCardSkeleton(),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: skeleton,
        );
      },
    );
  }
}

/// 智能加载组件
/// 根据状态自动显示加载中、空状态、错误状态或内容
class SmartLoadWidget<T> extends StatelessWidget {
  final LoadStatus status;
  final List<T>? data;
  final Widget Function(List<T> data) builder;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final String? errorMessage;
  final String? loadingMessage;

  const SmartLoadWidget({
    super.key,
    required this.status,
    this.data,
    required this.builder,
    this.onRetry,
    this.emptyMessage,
    this.errorMessage,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LoadStatus.loading:
        return LoadingStateWidget(message: loadingMessage);
      case LoadStatus.empty:
        return EmptyStateWidget(
          subtitle: emptyMessage,
        );
      case LoadStatus.error:
        return ErrorStateWidget(
          message: errorMessage ?? '加载失败',
          onRetry: onRetry,
        );
      case LoadStatus.success:
        if (data == null || data!.isEmpty) {
          return EmptyStateWidget(
            subtitle: emptyMessage,
          );
        }
        return builder(data!);
    }
  }
}

/// 加载状态枚举
enum LoadStatus {
  loading,
  empty,
  error,
  success,
}

/// 加载控制器
class LoadController extends ChangeNotifier {
  LoadStatus _status = LoadStatus.loading;
  String? _errorMessage;

  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LoadStatus.loading;
  bool get isSuccess => _status == LoadStatus.success;
  bool get isError => _status == LoadStatus.error;
  bool get isEmpty => _status == LoadStatus.empty;

  void setLoading() {
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void setSuccess() {
    _status = LoadStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void setEmpty() {
    _status = LoadStatus.empty;
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _status = LoadStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
