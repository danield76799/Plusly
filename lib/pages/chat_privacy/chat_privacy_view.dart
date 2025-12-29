import 'package:extera_next/pages/chat_privacy/chat_privacy.dart';
import 'package:extera_next/widgets/layouts/max_width_body.dart';
import 'package:flutter/material.dart';

class ChatPrivacyView extends StatelessWidget {
  final ChatPrivacyController controller;

  const ChatPrivacyView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat privacy settings"),
      ),
      body: MaxWidthBody(
        child: Column(
          
        ),
      ),
    );
  }
}