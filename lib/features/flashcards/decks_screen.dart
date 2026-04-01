import 'package:flutter/material.dart';

class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karteikarten')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Karteikarten kommen bald...'),
          ],
        ),
      ),
    );
  }
}
