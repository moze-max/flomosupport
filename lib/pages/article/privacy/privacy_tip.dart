import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PrivacyTip extends StatefulWidget {
  const PrivacyTip({super.key});

  @override
  State<PrivacyTip> createState() => _PrivacyTipState();
}

class _PrivacyTipState extends State<PrivacyTip> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            appLocalizations.privacySettings,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }
}
