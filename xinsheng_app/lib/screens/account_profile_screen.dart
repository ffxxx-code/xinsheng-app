import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/utils.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/avatar_selector.dart';

class AccountProfileScreen extends ConsumerStatefulWidget {
  const AccountProfileScreen({super.key});

  @override
  ConsumerState<AccountProfileScreen> createState() =>
      _AccountProfileScreenState();
}

class _AccountProfileScreenState
    extends ConsumerState<AccountProfileScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isEditingUsername = false;
  bool _isEditingPhone = false;
  int _countdown = 0;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    final phone = _phoneController.text.trim();
    if (!isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的手机号')),
      );
      return;
    }

    setState(() => _countdown = 60);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _countdown--);
      }
      return _countdown > 0 && mounted;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('验证码'),
        content: const Text('验证码已发送：123456'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUsername() async {
    final newUsername = _usernameController.text.trim();
    final user = ref.read(authProvider).user;

    if (newUsername.isEmpty || newUsername.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户名至少3位')),
      );
      return;
    }

    if (user == null) return;

    try {
      await UserService.updateUsername(user.id, newUsername);
      await ref.read(authProvider.notifier).updateUser(
            user.copyWith(username: newUsername),
          );
      setState(() => _isEditingUsername = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('用户名修改成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _updatePhone() async {
    final code = _codeController.text.trim();
    final newPhone = _phoneController.text.trim();
    final user = ref.read(authProvider).user;

    if (code != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('验证码错误')),
      );
      return;
    }

    if (user == null) return;

    try {
      await UserService.updatePhone(user.id, newPhone);
      await ref.read(authProvider.notifier).updateUser(
            user.copyWith(phone: newPhone),
          );
      setState(() => _isEditingPhone = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('手机号换绑成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _updateAvatar(String avatarPath) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    try {
      await UserService.updateAvatar(user.id, avatarPath);
      await ref.read(authProvider.notifier).updateUser(
            user.copyWith(avatar: avatarPath),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像更新成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('头像更新失败: ${e.toString()}')),
        );
      }
    }
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
        title: const Text('账号资料'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar section
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showAvatarSelector(
                      context: context,
                      currentAvatar: user.avatar,
                      onAvatarSelected: (avatarPath) {
                        _updateAvatar(avatarPath);
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      AvatarWidget(
                        avatar: user.avatar,
                        fallbackText: user.nickname.isNotEmpty
                            ? user.nickname
                            : user.username,
                        size: 100,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.nickname.isNotEmpty ? user.nickname : user.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '点击头像更换',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '加入于 ${formatDate(user.createdAt)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Info items
          _buildInfoItem(
            icon: Icons.person_outline,
            label: '用户名',
            value: user.username,
            onEdit: () {
              _usernameController.text = user.username;
              setState(() => _isEditingUsername = true);
            },
          ),
          _buildInfoItem(
            icon: Icons.phone_outlined,
            label: '手机号',
            value: user.phone != null ? maskPhone(user.phone!) : '未绑定',
            onEdit: () {
              _phoneController.text = user.phone ?? '';
              setState(() => _isEditingPhone = true);
            },
          ),
          _buildInfoItem(
            icon: Icons.badge_outlined,
            label: '昵称',
            value: user.nickname.isNotEmpty ? user.nickname : '未设置',
            editable: false,
          ),
          _buildInfoItem(
            icon: Icons.numbers_outlined,
            label: '用户ID',
            value: user.id,
            editable: false,
          ),
        ],
      ),
      // Edit username dialog
      bottomSheet: _isEditingUsername
          ? _buildEditBottomSheet(
              title: '修改用户名',
              controller: _usernameController,
              hint: '请输入新用户名',
              onCancel: () => setState(() => _isEditingUsername = false),
              onConfirm: _updateUsername,
            )
          : _isEditingPhone
              ? _buildPhoneEditBottomSheet()
              : null,
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onEdit,
    bool editable = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(label),
        subtitle: Text(value),
        trailing: editable && onEdit != null
            ? TextButton(
                onPressed: onEdit,
                child: const Text('修改'),
              )
            : null,
      ),
    );
  }

  Widget _buildEditBottomSheet({
    required String title,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    child: const Text('确认'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneEditBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '换绑手机号',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '请输入新手机号',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '请输入验证码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _countdown > 0 ? null : _sendCode,
                  child: Text(_countdown > 0 ? '${_countdown}s' : '获取验证码'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isEditingPhone = false),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updatePhone,
                    child: const Text('确认'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
