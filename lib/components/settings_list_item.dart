// lib/widgets/settings_list_item.dart
import 'package:flutter/material.dart';

class SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? subtitle; // Add this line for the subtitle

  const SettingsListItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: subtitle,
          trailing: trailing ?? const Icon(Icons.keyboard_arrow_right),
          onTap: onTap,
        ),
      ],
    );
  }
}
