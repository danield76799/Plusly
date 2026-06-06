import 'package:flutter/material.dart';

class AiHubPage extends StatelessWidget {
  const AiHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('AI Features coming soon', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
