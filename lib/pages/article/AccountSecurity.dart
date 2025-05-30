import 'package:flutter/material.dart';

class AccountsecurityPage extends StatefulWidget {
  const AccountsecurityPage({super.key});

  @override
  State<AccountsecurityPage> createState() => _AccountsecurityPageState();
}

class _AccountsecurityPageState extends State<AccountsecurityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AccountSecutity')),
      body: Text("This is AccountSecurity Page."),
    );
  }
}
