mport 'package:flutter/material.dart';

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
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isSent: true));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}

final ScrollController _scrollController = ScrollController();

void _sendMessage() {
  final text = _controller.text.trim();
  if (text.isEmpty) return;
  setState(() {
    _messages.add(ChatMessage(text: text, isSent: true));
    _controller.clear();
  });
  Future.delayed(const Duration(milliseconds: 100), () {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  });
}

List<ChatMessage> _messages = [
  const ChatMessage(text: 'Hello!', isSent: true),
  const ChatMessage(text: 'How can I help you today?', isSent: false),
  const ChatMessage(
      text: 'Could you please provide me with some more details about the issue you\'re experiencing?',
      isSent: false),
  const ChatMessage(text: 'Sure', isSent: true),
  const ChatMessage(
      text: 'Whenever I try to view my workout history, the app freezes and crashes.',
      isSent: true),
  const ChatMessage(
      text: 'I\'m sorry to hear that. Let me check that for you. Have you tried restarting the app or your device to see if that resolves the issue?',
      isSent: false),
];

Widget _buildHeader(String name) {
  return Container(
    padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
    color: Colors.white,
    child: Row(
      children: [
        const BackButton(),
        const CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
        ),
        const SizedBox(width: 10),
        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

Widget _buildBubble(ChatMessage msg) {
  final isSent = msg.isSent;
  return Align(
    alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      decoration: BoxDecoration(
        color: isSent ? Colors.grey[600] : Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        msg.text,
        style: TextStyle(color: isSent ? Colors.white : Colors.black87, fontSize: 14),
      ),
    ),
  );
}

Widget _buildInputBar() {
  return Container(
    color: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.attach_file, color: Colors.white54), onPressed: () {}),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Write here...'),
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
        IconButton(icon: const Icon(Icons.mic, color: Colors.white54), onPressed: () {}),
        IconButton(icon: const Icon(Icons.send, color: Colors.white70), onPressed: _sendMessage),
      ],
    ),
  );
}

Widget _buildBottomNav() {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
      BottomNavigationBarItem(
        icon: CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
        ),
        label: '',
      ),
    ],
  );
}