import 'package:flutter/material.dart';
import 'package:flomosupport/l10n/app_localizations.dart';

class Notificationsetting extends StatefulWidget {
  const Notificationsetting({super.key});

  @override
  State<Notificationsetting> createState() => _NotificationsettingState();
}

class _NotificationsettingState extends State<Notificationsetting> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.notificationPageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Text('notification setting page.'),
      ),
    );
  }
}
