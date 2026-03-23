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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _controller.clear();
      _hasText = false;
      _isSending = true;
    });

    try {
      await _messageRepository.sendMessage(
        chatId: _chatId,
        senderId: _currentUserId,
        text: text,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.parse(timestamp as String);
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            Expanded(
              child: _isInitializing
                  ? const Center(
                  child: CircularProgressIndicator(color: _primary))
                  : _buildMessageList(),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28, color: _primary),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: _primary.withOpacity(0.1),
            child: Text(
              _otherPartyName.isNotEmpty
                  ? _otherPartyName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _otherPartyName.isNotEmpty ? _otherPartyName : '...',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _primary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _messageRepository.getMessages(_chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _primary));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Something went wrong',
                  style: TextStyle(color: Colors.grey.shade500)));
        }
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return Center(
            child: Text('No messages yet',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          );
        }
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (_, i) => _buildBubble(messages[i]),
        );
      },
    );
  }

  Widget _buildBubble(Map<String, dynamic> message) {
    final isOwn = message['senderId'] == _currentUserId;
    final text = message['text'] as String? ?? '';
    final time = _formatTime(message['timestamp']);

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isOwn ? _bubbleOwn : _bubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isOwn ? 18 : 4),
            bottomRight: Radius.circular(isOwn ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isOwn ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isOwn ? Colors.white60 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (v) =>
                    setState(() => _hasText = v.trim().isNotEmpty),
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle:
                  TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _hasText && !_isSending && !_isInitializing
                  ? _primary
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: _isSending
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
                : IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.send_rounded,
                  size: 20, color: Colors.white),
              onPressed: _hasText && !_isSending && !_isInitializing
                  ? _sendMessage
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}