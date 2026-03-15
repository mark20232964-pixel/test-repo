import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isSent;
  const ChatMessage({required this.text, required this.isSent});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  
}