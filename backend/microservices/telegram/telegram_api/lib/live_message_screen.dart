import 'package:flutter/material.dart';

class LiveMessageScreen extends StatelessWidget {
  const LiveMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listening for Messages...')),
      body: const Center(
        child: Text(
          'Messages will appear in backend logs.\n\n'
              'Backend is listening in real-time!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
