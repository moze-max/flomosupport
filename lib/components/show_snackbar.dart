import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message,
    {bool isError = false}) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }
}
