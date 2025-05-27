// import 'package:flutter/material.dart';

// class About extends StatefulWidget {
//   const About({super.key});

//   @override
//   State<About> createState() => _AboutState();
// }

// class _AboutState extends State<About> {
//   @override
//   Widget build(BuildContext context) {
//     return intro();
//   }
// }

// Scaffold intro() {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
//     ),
//     body: SingleChildScrollView(
//       child: Column(
//         children: [
//           Center(
//             child: Column(
//               children: [
//                 const FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     "FLOMO SUPPORT",
//                     style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Image.asset('assets/images/images.jpg'),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           '我只是一个路过的flomo使用者,没有他们那么强大的力量制作高级的产品',
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Colors.blueAccent,
//                           ),
//                           softWrap: true,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 12),
//           nomalTextPadding("定制联系:\nQQ:3023713469\n微信:同号"),
//           nomalTextPadding("赞助我们:"),
//           showReceiptCode(),
//         ],
//       ),
//     ),
//   );
// }

// Flexible showReceiptCode() {
//   return Flexible(
//     child: Row(
//       children: [
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Image.asset(
//               'assets/images/1746434655157.jpg',
//               fit: BoxFit.contain, // 图片自适应大小，不裁剪
//               width: double.infinity, // 占满分配的空间
//             ),
//           ),
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Image.asset(
//               'assets/images/mm_facetoface_collect_qrcode_1746434636719.png',
//               fit: BoxFit.contain,
//               width: double.infinity,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Padding nomalTextPadding(String textinput) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 8.0), // 设置左右内边距
//     child: Align(
//       alignment: Alignment.topLeft, // 确保内容左对齐
//       child: Text(
//         textinput,
//         textAlign: TextAlign.left,
//         style: TextStyle(
//           fontSize: 21,
//           fontWeight: FontWeight.w600,
//           color: Colors.deepPurple,
//         ),
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';
// 确保导入你生成的本地化文件
import 'package:flomosupport/l10n/app_localizations.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    // 将 Scaffold 放在 build 方法内部，这样它可以访问 context
    // 同时可以获取 AppLocalizations 实例
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // 国际化 AppBar 标题
        title: Text(appLocalizations.aboutPageTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "FLOMO SUPPORT", // 这个可能保持英文或者根据 branding 决定
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // 让内容顶部对齐
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/images.jpg',
                          width: MediaQuery.of(context).size.width *
                              0.3, // 限制图片宽度，避免过大
                          height:
                              MediaQuery.of(context).size.width * 0.3, // 保持宽高比
                          fit: BoxFit.contain, // 确保图片能完整显示
                          errorBuilder: (context, error, stackTrace) {
                            // 添加错误构建器
                            return const Icon(Icons.error_outline,
                                color: Colors.red, size: 50);
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            // 国际化文本
                            appLocalizations
                                .aboutDeveloperIntro, // 需要在 arb 文件中添加此键
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.blueAccent,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 使用国际化文本和封装的 Padding Widget
            _NomalTextPadding(appLocalizations.contactInfo), // 需要在 arb 文件中添加此键
            _NomalTextPadding(appLocalizations.sponsorUs), // 需要在 arb 文件中添加此键
            _ShowReceiptCode(), // 调用新的函数来直接返回 Row，而不是 Flexible
            const SizedBox(height: 50), // 底部留白，确保内容不会顶到边缘
          ],
        ),
      ),
    );
  }
}

// 将 showReceiptCode() 和 nomalTextPadding() 也改为 Widget 类型
// 并修复 Flexible 的使用问题
Widget _ShowReceiptCode() {
  return Row(
    // 直接返回 Row，而不是 Flexible
    children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.asset(
            'assets/images/1746434655157.jpg',
            // 不再需要 width: double.infinity, fit: BoxFit.contain;
            // Expanded 会处理宽度，fit 可以根据需要调整
            fit: BoxFit.fitWidth, // 让图片宽度适应 Expanded 分配的空间
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error_outline,
                  color: Colors.red, size: 50);
            },
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.asset(
            'assets/images/mm_facetoface_collect_qrcode_1746434636719.png',
            fit: BoxFit.fitWidth, // 同上
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error_outline,
                  color: Colors.red, size: 50);
            },
          ),
        ),
      ),
    ],
  );
}

// 封装成 StatelessWidget，接收国际化字符串
class _NomalTextPadding extends StatelessWidget {
  final String textinput;
  const _NomalTextPadding(this.textinput);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // 设置左右内边距
      child: Align(
        alignment: Alignment.topLeft, // 确保内容左对齐
        child: Text(
          textinput,
          textAlign: TextAlign.left,
          style: const TextStyle(
            // 加上 const
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}
