import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final String? payload;
  final Map<String, dynamic>? data;

  const SecondPage(this.payload, {this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Payload: $payload'),
            if (data != null) ...[
              Text('Data: $data'),
            ]
          ],
        ),
      ),
    );
  }
}
