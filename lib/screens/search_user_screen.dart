import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/session_manager.dart';
import 'chat_screen.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  int? _myId;

  @override
  void initState() {
    super.initState();
    _loadMyId();
  }

  Future<void> _loadMyId() async {
    _myId = await SessionManager.getUserId();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final raw = await ApiService.searchUsers(query.trim());
      setState(() {
        _results = raw
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .where((u) => u.id != _myId) // exclude self
            .toList();
        _hasSearched = true;
      });
    } catch (_) {
      setState(() => _hasSearched = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 16),
          ),
        ),
        title: const Text(
          'New Message',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white38),
                        onPressed: () {
                          _searchCtrl.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: Color(0xFF6366F1), width: 1.5),
                ),
              ),
            ),
          ),
          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF6366F1)))
                : !_hasSearched
                    ? _buildEmptyHint()
                    : _results.isEmpty
                        ? _buildNoResults()
                        : ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _results.length,
                            itemBuilder: (context, i) =>
                                _buildUserTile(_results[i]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Color(0xFF818CF8),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        user.email,
        style:
            TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.3), width: 1),
        ),
        child: const Text(
          'Message',
          style: TextStyle(
              color: Color(0xFF818CF8),
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
      ),
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(contact: user)),
      ),
    );
  }

  Widget _buildEmptyHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded,
              size: 70, color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 18),
          Text(
            'Search for people to message',
            style: TextStyle(
                color: Colors.white.withOpacity(0.35), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 70, color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 18),
          Text(
            'No users found',
            style: TextStyle(
                color: Colors.white.withOpacity(0.35), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
