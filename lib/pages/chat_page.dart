import 'package:flutter/material.dart';

import '../widgets/chat_widget.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Explorer AI'),
      ),
      body: const ChatWidget(),
    );
  }
}
