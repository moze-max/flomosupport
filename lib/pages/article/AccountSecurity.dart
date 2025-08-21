// import 'package:flomosupport/components/get_avataimage.dart';
// import 'package:flutter/material.dart';

// class AccountsecurityPage extends StatefulWidget {
//   const AccountsecurityPage({super.key});

//   @override
//   State<AccountsecurityPage> createState() => _AccountsecurityPageState();
// }

// class _AccountsecurityPageState extends State<AccountsecurityPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text('个人信息')),
//         body: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // 头像部分
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text("头像"),
//                     UserAvatarManager(
//                       enableActions: true,
//                     ),
//                   ],
//                 ),

//                 const Divider(height: 1, color: Colors.grey),

//                 // 昵称部分
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text("昵称"),
//                   ],
//                 ),
//                 const Divider(height: 1, color: Colors.grey),
//               ],
//             )));
//   }
// }

import 'package:flomosupport/components/UserAvatarManager.dart';
import 'package:flomosupport/functions/image_file_manager.dart';
import 'package:flomosupport/functions/nickname_notifier.dart';
import 'package:flomosupport/pages/article/Nickname_Setting_Page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AccountsecurityPage extends StatefulWidget {
  const AccountsecurityPage({super.key});

  @override
  State<AccountsecurityPage> createState() => _AccountsecurityPageState();
}

class _AccountsecurityPageState extends State<AccountsecurityPage> {
  // 用于控制昵称输入框的控制器
  final TextEditingController _nicknameController = TextEditingController();

  // 假设的昵称值
  final String _nickname = '输入的昵称';

  @override
  void initState() {
    super.initState();
    _nicknameController.text = _nickname;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // 封装通用的信息行组件
  Widget _buildProfileItem({
    required String title,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    child,
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人信息')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // 头像部分
            _buildProfileItem(
              title: "头像",
              child: const UserAvatarManager(radius: 20, enableActions: true),
              onTap: () {
                pickImage(context, ImageSource.gallery);
              },
            ),

            const Divider(height: 1, color: Colors.grey),

            // 昵称部分
            Consumer<NicknameNotifier>(
              builder: (context, nicknameNotifier, child) {
                return _buildProfileItem(
                  title: "昵称",
                  child: Text(
                    nicknameNotifier.currentNickname ?? '未设置', // 使用 ?? 提供默认值
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    // 跳转到昵称设置页面，不再需要传递参数
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NicknameSettingPage(),
                      ),
                    );
                  },
                );
              },
            ),

            const Divider(height: 1, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
