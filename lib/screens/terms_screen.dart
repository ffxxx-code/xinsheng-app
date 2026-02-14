import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议'),
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
              '一、服务条款的接受',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '欢迎使用「心声」！本协议是您与心声之间关于使用心声服务所订立的协议。通过注册或使用我们的服务，您表示您已阅读、理解并同意接受本协议的所有条款和条件。',
            ),
            SizedBox(height: 16),
            Text(
              '二、服务说明',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '「心声」是一个极简的50字笔记社区，用户可以：\n• 发布不超过50字的文字动态\n• 浏览其他用户发布的动态\n• 对动态进行点赞、评论、收藏\n• 关注感兴趣的用户\n• 接收消息通知',
            ),
            SizedBox(height: 16),
            Text(
              '三、账号注册与安全',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '3.1 您需要提供真实、准确的个人信息进行注册。\n3.2 您有责任保护您的账号密码安全，对账号下的所有行为负责。\n3.3 如发现账号被盗用，请立即联系我们。\n3.4 我们有权对违反规定的账号进行封禁处理。',
            ),
            SizedBox(height: 16),
            Text(
              '四、用户行为规范',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '您在使用服务时应遵守法律法规，不得发布以下内容：\n• 违反国家法律法规的内容\n• 色情、暴力、恐怖、赌博相关内容\n• 侵犯他人知识产权的内容\n• 诽谤、侮辱、骚扰他人的内容\n• 垃圾广告、恶意营销内容\n• 诱导自杀、自残的内容',
            ),
            SizedBox(height: 16),
            Text(
              '五、内容规范',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '5.1 您发布的内容版权归您所有，但您授予我们全球范围内免费、非独家的使用权。\n5.2 我们有权对违规内容进行删除、隐藏或屏蔽处理。\n5.3 多次违规的用户将被永久封禁账号。',
            ),
            SizedBox(height: 16),
            Text(
              '六、服务变更与中断',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '6.1 我们保留随时修改或中断服务的权利，恕不另行通知。\n6.2 因系统维护、升级或其他原因需要中断服务时，我们将尽可能提前通知。',
            ),
            SizedBox(height: 16),
            Text(
              '七、免责声明',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '7.1 我们不对用户发布内容的真实性、准确性负责。\n7.2 用户使用本服务所产生的风险由用户自行承担。',
            ),
            SizedBox(height: 16),
            Text(
              '八、协议修改',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '我们有权随时修改本协议，修改后的协议将在平台上公布。继续使用服务即表示您接受修改后的协议。',
            ),
            SizedBox(height: 16),
            Text(
              '九、联系我们',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('如有任何问题或建议，请通过意见反馈功能与我们联系。'),
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
