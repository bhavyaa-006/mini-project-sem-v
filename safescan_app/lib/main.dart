import 'package:flutter/material.dart';

void main() {
  runApp(const SafeScanApp());
}

class SafeScanApp extends StatelessWidget {
  const SafeScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeScan & PackCheck',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14683F)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('SafeScan & PackCheck Ready'),
        ),
      ),
    );
  }
}
