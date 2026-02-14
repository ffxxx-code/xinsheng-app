import 'package:flutter/material.dart';

/// 系统头像列表
const List<String> systemAvatars = [
  'assets/images/avatars/avatar_01.jpg',
  'assets/images/avatars/avatar_02.jpg',
  'assets/images/avatars/avatar_03.jpg',
  'assets/images/avatars/avatar_04.jpg',
  'assets/images/avatars/avatar_05.jpg',
  'assets/images/avatars/avatar_06.jpg',
  'assets/images/avatars/avatar_07.jpg',
  'assets/images/avatars/avatar_08.jpg',
  'assets/images/avatars/avatar_09.jpg',
  'assets/images/avatars/avatar_10.jpg',
  'assets/images/avatars/avatar_11.jpg',
  'assets/images/avatars/avatar_12.jpg',
];

/// 头像选择器组件
class AvatarSelector extends StatefulWidget {
  final String? currentAvatar;
  final Function(String) onAvatarSelected;

  const AvatarSelector({
    super.key,
    this.currentAvatar,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  String? selectedAvatar;

  @override
  void initState() {
    super.initState();
    selectedAvatar = widget.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择头像',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 头像网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: systemAvatars.length,
            itemBuilder: (context, index) {
              final avatar = systemAvatars[index];
              final isSelected = selectedAvatar == avatar;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAvatar = avatar;
                  });
                  widget.onAvatarSelected(avatar);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          )
                        : null,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // 确认按钮
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selectedAvatar != null
                  ? () {
                      widget.onAvatarSelected(selectedAvatar!);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('确认选择'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 显示头像选择器底部弹窗
void showAvatarSelector({
  required BuildContext context,
  String? currentAvatar,
  required Function(String) onAvatarSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AvatarSelector(
      currentAvatar: currentAvatar,
      onAvatarSelected: onAvatarSelected,
    ),
  );
}
