import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Generalsettings extends StatefulWidget {
  const Generalsettings({super.key});

  @override
  State<Generalsettings> createState() => _GeneralsettingsState();
}

class _GeneralsettingsState extends State<Generalsettings> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.generalSettings,
        ),
      ),
    );
  }
}
