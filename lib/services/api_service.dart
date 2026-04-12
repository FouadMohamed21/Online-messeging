import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Production URL (Railway deployment)
  static const String _productionUrl =
      'https://online-messeging-production.up.railway.app';

  /// Returns the correct base URL depending on environment
  static String get baseUrl {
    // In release mode, always use production
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) return _productionUrl;
    // In debug mode, use local server
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  // ─── AUTH ──────────────────────────────────────────────────────────────────

  /// Login — returns the full user map {id, name, email}
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Invalid email or password');
  }

  /// Signup — returns the full user map {id, name, email}
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    if (res.statusCode == 409) {
      throw Exception('Email already registered');
    }
    throw Exception('Signup failed');
  }

  // ─── USERS ─────────────────────────────────────────────────────────────────

  /// Search users by name or email — returns a list of user maps
  static Future<List<dynamic>> searchUsers(String query) async {
    final res = await http.get(
      Uri.parse('$baseUrl/user/search?q=${Uri.encodeComponent(query)}'),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['users'] ?? [];
    }
    throw Exception('Search failed');
  }

  // ─── MESSAGES ──────────────────────────────────────────────────────────────

  /// Send a message — returns true on success
  static Future<bool> sendMessage(
    int senderId,
    int receiverId,
    String content,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
      }),
    );
    return res.statusCode == 201;
  }

  /// Get conversation messages between two users
  static Future<List<dynamic>> getMessages(int user1, int user2) async {
    final res = await http.get(
      Uri.parse('$baseUrl/message/$user1/$user2'),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['messages'] ?? [];
    }
    throw Exception('Failed to get messages');
  }

  /// Delete a message by id (only the sender can delete it)
  static Future<bool> deleteMessage(int messageId, int senderId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/message/$messageId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'senderId': senderId}),
    );
    return res.statusCode == 200;
  }

  /// Get all users who have had a conversation with [userId]
  static Future<List<dynamic>> getConversations(int userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/message/conversations/$userId'),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['contacts'] ?? [];
    }
    throw Exception('Failed to get conversations');
  }

  // ─── FCM ───────────────────────────────────────────────────────────────────

  /// Upload (or refresh) the FCM device token for [userId]
  static Future<void> saveFcmToken(int userId, String fcmToken) async {
    await http.post(
      Uri.parse('$baseUrl/user/fcm-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'fcmToken': fcmToken}),
    );
  }
}

