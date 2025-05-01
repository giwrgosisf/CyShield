import 'package:flutter/material.dart';
import 'send_code_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SendCodeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
