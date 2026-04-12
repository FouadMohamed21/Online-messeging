import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/session_manager.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final UserModel contact;
  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int? _myId;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _myId = await SessionManager.getUserId();
    await _loadMessages();
    // Poll for new messages every 3 seconds
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _loadMessages());
  }

  Future<void> _loadMessages() async {
    if (_myId == null) return;
    try {
      final raw = await ApiService.getMessages(_myId!, widget.contact.id);
      final msgs = raw
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _messages = msgs;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageCtrl.text.trim();
    if (content.isEmpty || _myId == null) return;
    _messageCtrl.clear();
    setState(() => _isSending = true);
    try {
      await ApiService.sendMessage(_myId!, widget.contact.id, content);
      await _loadMessages();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send message.'),
            backgroundColor: Colors.redAccent.shade200,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// Shows a confirmation dialog, then deletes the message from the server.
  Future<void> _deleteMessage(MessageModel msg) async {
    if (_myId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete message?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This message will be permanently removed.',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF818CF8))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ApiService.deleteMessage(msg.id, _myId!);
    if (success) {
      // Optimistically remove from list
      setState(() => _messages.removeWhere((m) => m.id == msg.id));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete message.'),
            backgroundColor: Colors.redAccent.shade200,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Formats a DateTime for display under the bubble (e.g. "3:45 PM").
  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  /// Returns a human-readable date label for a separator.
  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.contact.name.isNotEmpty
        ? widget.contact.name[0].toUpperCase()
        : '?';
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF6366F1).withOpacity(0.25),
              child: Text(
                initials,
                style: const TextStyle(
                    color: Color(0xFF818CF8),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text(
                  'Tap to view profile',
                  style:
                      TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded,
                color: Colors.white54, size: 26),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white54, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF6366F1)))
                : _messages.isEmpty
                    ? _buildEmptyChat()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          final isMe = msg.senderId == _myId;

                          // Date separator logic
                          final dt = msg.parsedCreatedAt;
                          bool showSeparator = false;
                          if (i == 0) {
                            showSeparator = true;
                          } else {
                            final prev = _messages[i - 1].parsedCreatedAt;
                            if (dt != null && prev != null) {
                              final a = DateTime(dt.year, dt.month, dt.day);
                              final b = DateTime(prev.year, prev.month, prev.day);
                              showSeparator = a != b;
                            }
                          }

                          return Column(
                            children: [
                              if (showSeparator)
                                _buildDateSeparator(
                                    dt != null ? _dateLabel(dt) : 'Today'),
                              _buildBubble(context, msg, isMe),
                            ],
                          );
                        },
                      ),
          ),
          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 52,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No messages yet',
            style: TextStyle(
                color: Colors.white.withOpacity(0.35), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Say hi to ${widget.contact.name.split(' ').first} 👋',
            style: TextStyle(
                color: Colors.white.withOpacity(0.25), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context, MessageModel msg, bool isMe) {
    final timeStr = _formatTime(msg.parsedCreatedAt);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        // Long-press to delete (only for the user's own messages)
        onLongPress: isMe ? () => _deleteMessage(msg) : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.76),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isMe ? null : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isMe
                        ? const Radius.circular(20)
                        : const Radius.circular(4),
                    bottomRight: isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? const Color(0xFF6366F1).withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
              if (timeStr.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Text(
                    timeStr,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFF1E293B)),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.35)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
