import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return intro();
  }
}

Scaffold intro() {
  return Scaffold(
    appBar: AppBar(
      title: const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    body: Column(
      children: [
        Center(
          child: Column(
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "FLOMO SUPPORT",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/images.jpg'),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '我只是一个路过的flomo使用者,没有他们那么强大的力量制作高级的产品',
                        style: TextStyle(
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
        SizedBox(height: 12),
        nomalTextPadding("定制联系:\nQQ:3023713469\n微信:同号"),
        nomalTextPadding("赞助我们:"),
        showReceiptCode(),
      ],
    ),
  );
}

Flexible showReceiptCode() {
  return Flexible(
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset(
              'assets/images/1746434655157.jpg',
              fit: BoxFit.contain, // 图片自适应大小，不裁剪
              width: double.infinity, // 占满分配的空间
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset(
              'assets/images/mm_facetoface_collect_qrcode_1746434636719.png',
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        ),
      ],
    ),
  );
}

Padding nomalTextPadding(String textinput) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0), // 设置左右内边距
    child: Align(
      alignment: Alignment.topLeft, // 确保内容左对齐
      child: Text(
        textinput,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple,
        ),
      ),
    ),
  );
}
