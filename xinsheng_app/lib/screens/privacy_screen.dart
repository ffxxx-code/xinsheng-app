import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '一、引言',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '「心声」非常重视您的隐私保护。本隐私政策说明我们如何收集、使用、存储和保护您的个人信息。请仔细阅读本政策，以便了解我们的做法。',
            ),
            SizedBox(height: 16),
            Text(
              '二、我们收集的信息',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '2.1 注册信息：用户名、手机号、密码（加密存储）\n2.2 个人资料：昵称、头像\n2.3 使用数据：发布的动态、评论、点赞、收藏记录\n2.4 设备信息：设备类型、操作系统版本（用于优化服务）\n2.5 日志信息：访问时间、操作记录（用于安全审计）',
            ),
            SizedBox(height: 16),
            Text(
              '三、信息的使用',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '我们使用您的信息用于以下目的：\n• 提供、维护和改进我们的服务\n• 验证您的身份，保护账号安全\n• 向您发送服务通知和更新\n• 处理您的反馈和投诉\n• 防止欺诈和滥用行为\n• 进行数据分析，优化用户体验',
            ),
            SizedBox(height: 16),
            Text(
              '四、信息的存储与保护',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '4.1 存储位置：您的数据存储在安全的服务器上。\n4.2 加密措施：密码采用加密存储，传输过程使用HTTPS加密。\n4.3 访问控制：只有授权人员才能访问用户数据。\n4.4 数据保留：我们会在您注销账号后保留必要的数据以遵守法律义务。',
            ),
            SizedBox(height: 16),
            Text(
              '五、信息共享',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '5.1 我们不会将您的个人信息出售给任何第三方。\n5.2 在以下情况下，我们可能会共享您的信息：\n• 获得您的明确同意\n• 应法律法规要求\n• 保护我们的合法权益\n• 与关联公司共享（仅在必要范围内）',
            ),
            SizedBox(height: 16),
            Text(
              '六、您的权利',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '您对自己的个人信息享有以下权利：\n• 访问权：查看您的个人信息\n• 更正权：修改不准确的信息\n• 删除权：要求删除您的个人信息\n• 撤回同意权：撤回对信息处理的同意\n• 注销账号权：申请注销账号',
            ),
            SizedBox(height: 16),
            Text(
              '七、Cookie和类似技术',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '我们使用Cookie和本地存储技术来改善您的使用体验，包括记住您的登录状态和偏好设置。您可以在浏览器设置中管理Cookie。',
            ),
            SizedBox(height: 16),
            Text(
              '八、未成年人保护',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '8.1 我们的服务不适合14岁以下未成年人使用。\n8.2 如果我们发现收集了未成年人的信息，将立即删除。',
            ),
            SizedBox(height: 16),
            Text(
              '九、隐私政策的更新',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '我们可能会不时更新本隐私政策。更新后的政策将在平台上公布，重大变更我们会通过适当方式通知您。',
            ),
            SizedBox(height: 16),
            Text(
              '十、联系我们',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('如果您对本隐私政策有任何疑问或建议，请通过意见反馈功能与我们联系。'),
            SizedBox(height: 32),
            Center(
              child: Text(
                '最后更新日期：2025年1月',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
