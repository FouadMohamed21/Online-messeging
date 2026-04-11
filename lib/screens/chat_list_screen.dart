import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/session_manager.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'search_user_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _myName = '';
  int? _myId;
  List<UserModel> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _myName = await SessionManager.getUserName() ?? 'You';
    _myId = await SessionManager.getUserId();
    await _loadContacts();
  }

  Future<void> _loadContacts() async {
    if (_myId == null) return;
    try {
      final raw = await ApiService.getConversations(_myId!);
      final contacts = raw
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${_myName.split(' ').first} 👋',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchUserScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.search,
                              color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: Colors.redAccent, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Contact list area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF6366F1)))
                      : _contacts.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadContacts,
                              color: const Color(0xFF6366F1),
                              backgroundColor: const Color(0xFF0F172A),
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 40),
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                itemCount: _contacts.length,
                                itemBuilder: (context, i) =>
                                    _buildContactTile(_contacts[i]),
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
      // FAB to start a new conversation
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchUserScreen()),
        ),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildContactTile(UserModel user) {
    final initials =
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final preview = (user.lastMessage != null && user.lastMessage!.isNotEmpty)
        ? user.lastMessage!
        : user.email;

    return Column(
      children: [
        InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(contact: user)),
            );
            // Refresh list when returning from chat (new messages may exist)
            _loadContacts();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              children: [
                // Avatar with gradient initial
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white24, size: 20),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          indent: 96,
          endIndent: 24,
          color: Colors.white.withOpacity(0.07),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 70, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 18),
          Text(
            'No conversations yet',
            style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 17,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap ✏️ to find someone and start chatting!',
            style: TextStyle(
                color: Colors.white.withOpacity(0.2), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
