// 个人信息收集清单

import 'package:flutter/material.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 返回按钮
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('个人信息收集清单'),
        centerTitle: true, // 标题居中
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 用户基本信息
            _buildExpansionTile(
              context,
              title: '用户基本信息',
              subtitle: '个人姓名、性别、生日等',
              content:
                  '当您注册或使用我们的服务时，我们可能会收集您的姓名、性别、生日、手机号码、电子邮件地址等信息，以便为您提供个性化的服务。',
            ),
            // 用户私密信息
            _buildExpansionTile(
              context,
              title: '用户私密信息',
              subtitle: '个人运动信息等',
              content: '为了提供健康管理或运动辅助功能，我们可能会收集您的步数、心率、睡眠数据、位置信息等，这些信息会受到严格保护。',
            ),
            // 其他背景审核资料
            _buildExpansionTile(
              context,
              title: '其他背景审核资料',
              subtitle: '学历、学校经历、工作经历等',
              content:
                  '在您申请特定服务或参与某些活动时，我们可能会在征得您同意后，收集您的学历、学校经历、工作经历等背景信息进行审核。',
            ),
            // 用户网络身份标识和鉴权信息
            _buildExpansionTile(
              context,
              title: '用户网络身份标识和鉴权信息',
              subtitle: '头像、昵称等',
              content: '为了识别您的身份，我们可能会收集您的头像、昵称、登录账号、密码等信息，用于账户管理和安全验证。',
            ),
            // 用户使用信息
            _buildExpansionTile(
              context,
              title: '用户使用信息',
              subtitle: '相册、多媒体文件等',
              content: '在您使用我们的服务上传图片、视频或语音时，我们可能会请求访问您的相册或多媒体文件，并收集相关内容。',
            ),
            // 联系人信息
            _buildExpansionTile(
              context,
              title: '联系人信息',
              subtitle: '通讯录信息等',
              content: '在您使用某些社交功能时，我们可能会在征得您同意后，访问您的通讯录信息，以便帮助您查找好友或推荐联系人。',
            ),
            // 设备属性信息
            _buildExpansionTile(
              context,
              title: '设备属性信息',
              subtitle: '硬件型号、操作系统版本、唯一设备标识符等',
              content:
                  '为了优化产品性能和提供更好的服务，我们可能会收集您的设备型号、操作系统版本、唯一设备标识符（如IMEI/Mac地址）、网络类型等信息。',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1.0), // 每个Tile之间只有1像素的间隔，模拟图片中的效果
      // color: const Color.fromARGB(255, 235, 234, 234), // Tile 的背景色比页面背景稍浅一点
      child: Theme(
        // 重写 ExpansionTile 的主题，来改变其默认箭头颜色等
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // 移除Tile展开时的分隔线
          expansionTileTheme: const ExpansionTileThemeData(
            iconColor: Color.fromARGB(255, 60, 107, 195), // 展开时的箭头图标颜色
            collapsedIconColor: Color.fromARGB(255, 60, 107, 195), // 收起时的箭头图标颜色
          ),
        ),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              // color: Colors.black, // 标题文本颜色
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              // color: Colors.black12, // 副标题颜色稍微暗一点
            ),
          ),
          // controlAffinity: ListTileControlAffinity.trailing, // 控制图标位置
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                content,
                style: TextStyle(fontSize: 20), // 正文内容颜色
              ),
            ),
          ],
        ),
      ),
    );
  }
}
