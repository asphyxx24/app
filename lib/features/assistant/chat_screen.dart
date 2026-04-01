import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Claude')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Claude-Assistent kommt bald...'),
          ],
        ),
      ),
    );
  }
}
