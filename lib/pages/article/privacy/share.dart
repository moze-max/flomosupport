import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Share extends StatefulWidget {
  const Share({super.key});

  @override
  State<Share> createState() => _ShareState();
}

class _ShareState extends State<Share> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              appLocalizations.thirdPartyInfoSharing,
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '''我们承诺我们不会将你的数据交给第三方。\n 你的所有应用数据都储存在本地，不会链接云端，\n但是我们没有设计数据加密，保护本地数据是你的个人责任，我们不会为数据失窃负责。''',
                style: TextStyle(fontSize: 16),
                softWrap: true,
              ),
            )
          ],
        ));
  }
}
