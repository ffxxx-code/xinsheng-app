import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatar;
  final String fallbackText;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const AvatarWidget({
    super.key,
    this.avatar,
    required this.fallbackText,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? Colors.grey[700]! : const Color(0xFF333333));
    final fgColor = textColor ?? Colors.white;

    if (avatar != null && avatar!.isNotEmpty) {
      // 判断是本地资源还是网络图片
      final isAsset = avatar!.startsWith('assets/');
      
      return ClipOval(
        child: isAsset
            ? Image.asset(
                avatar!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(bgColor, fgColor),
              )
            : Image.network(
                avatar!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(bgColor, fgColor),
              ),
      );
    }

    return _buildFallback(bgColor, fgColor);
  }

  Widget _buildFallback(Color bgColor, Color fgColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          fallbackText.isNotEmpty ? fallbackText[0] : '?',
          style: TextStyle(
            color: fgColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
