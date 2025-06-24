import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Security extends StatefulWidget {
  const Security({super.key});

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context); // 在实际应用中，点击返回会退出当前页面
        },
      ),
      title: Center(
        child: Text(
          appLocalizations.personalInfoProtection,
        ),
      ),
      centerTitle: true,
    ));
  }
}
