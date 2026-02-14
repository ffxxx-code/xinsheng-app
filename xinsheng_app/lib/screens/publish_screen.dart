import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../services/note_service.dart';
import '../utils/utils.dart';

class PublishScreen extends ConsumerStatefulWidget {
  const PublishScreen({super.key});

  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  final _contentController = TextEditingController();
  String? _location;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final content = _contentController.text.trim();
    final user = ref.read(authProvider).user;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    if (content.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内容至少3个字')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await NoteService.createNote(
        authorId: user.id,
        content: content,
        location: _location,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentLength = _contentController.text.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('发布动态'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _publish,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('发布'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content input
            TextField(
              controller: _contentController,
              maxLines: 8,
              maxLength: maxNoteLength,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '此刻，你想说...',
                border: InputBorder.none,
                counterText: '',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            const Spacer(),
            // Location selector
            InkWell(
              onTap: () {
                // TODO: Implement location picker
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('定位地址'),
                          onTap: () {
                            setState(() => _location = '定位地址');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_city),
                          title: const Text('青岛'),
                          onTap: () {
                            setState(() => _location = '青岛');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_off),
                          title: const Text('不显示位置'),
                          onTap: () {
                            setState(() => _location = null);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: _location != null ? const Color(0xFF2196F3) : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _location ?? '添加位置',
                    style: TextStyle(
                      fontSize: 14,
                      color: _location != null ? const Color(0xFF2196F3) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Character count
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$contentLength',
                  style: TextStyle(
                    fontSize: 14,
                    color: contentLength > maxNoteLength ? Colors.red : Colors.grey,
                  ),
                ),
                Text(
                  '/$maxNoteLength',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
