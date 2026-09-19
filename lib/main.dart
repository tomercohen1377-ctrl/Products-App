import 'package:flutter/material.dart';

void main() {
  runApp(const MyloApp());
}

class MyloApp extends StatelessWidget {
  const MyloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Mylo'))),
    );
  }
}
