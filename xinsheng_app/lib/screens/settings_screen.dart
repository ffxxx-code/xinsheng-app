import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/theme_provider.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('账号'),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: '账号资料',
            onTap: () => context.push('/account-profile'),
          ),
          _buildSectionTitle('关于'),
          _buildSettingItem(
            icon: Icons.description_outlined,
            title: '用户协议',
            onTap: () => context.push('/terms'),
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: '隐私政策',
            onTap: () => context.push('/privacy'),
          ),
          _buildSettingItem(
            icon: Icons.feedback_outlined,
            title: '意见反馈',
            onTap: () async {
              // Navigate to feedback note
              final feedbackNote = await FirebaseService.notesCollection
                  .where('isSystem', isEqualTo: true)
                  .limit(1)
                  .get();
              if (feedbackNote.docs.isNotEmpty && context.mounted) {
                context.push('/note/${feedbackNote.docs.first.id}?return=/settings');
              }
            },
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: '关于心声',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '心声',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF333333), Color(0xFF666666)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '声',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                children: [
                  const Text('此刻，你想说'),
                ],
              );
            },
          ),
          _buildSectionTitle('外观'),
          SwitchListTile(
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('深色模式'),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setDarkMode(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
