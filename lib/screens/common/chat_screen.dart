import 'package:flutter/material.dart';
import 'package:roadresq/repositories/chat_message_repository.dart';
import 'package:roadresq/repositories/chat_repository.dart';
import 'package:roadresq/repositories/user_repository.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;

  const ChatScreen({super.key, required this.schedule});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _primary = Color(0xFF1B1B4B);
  static const _bubbleOwn = Color(0xFF1B1B4B);
  static const _bubbleOther = Color(0xFFF5F5F7);

  final _messageRepository = ChatMessageRepository();
  final _chatRepository = ChatRepository();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _hasText = false;
  bool _isSending = false;
  bool _isInitializing = true;

  String _chatId = '';
  String _otherPartyName = '';
  late final String _requestId;
  late final String _currentUserId;
  late final String _otherUserId;

  @override
  void initState() {
    super.initState();
    _requestId = widget.schedule['id'] as String? ?? '';
    _currentUserId = widget.schedule['providerId'] ?? '';

    final userId = widget.schedule['userId'] as String? ?? '';
    final providerId = widget.schedule['providerId'] as String? ?? '';
    _otherUserId = _currentUserId == providerId ? userId : providerId;

    _initChat();
  }

  Future<void> _initChat() async {
    try {
      final userId = widget.schedule['userId'] as String? ?? '';
      final providerId = widget.schedule['providerId'] as String? ?? '';

      final results = await Future.wait([
        _chatRepository.getOrCreateChat(
          userId: userId,
          providerId: providerId,
          requestId: _requestId,
        ),
        UserRepository().getUser(_otherUserId),
      ]);

      final chat = results[0] as Map<String, dynamic>;
      final otherUser = results[1];

      if (mounted) {
        setState(() {
          _chatId = chat['id'] as String? ?? '';
          _otherPartyName = otherUser?['name'] as String? ?? 'User';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}