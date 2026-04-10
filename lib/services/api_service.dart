import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  // --- AUTH MODULE ---
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  static Future<bool> signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return response.statusCode == 201;
  }

  // --- USER MODULE ---
  
  static Future<List<dynamic>> searchUsers(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/user/search?q=$query'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['users'] ?? [];
    } else {
      throw Exception('Search failed');
    }
  }

  // --- MESSAGE MODULE ---
  
  static Future<bool> sendMessage(int senderId, int receiverId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'senderId': senderId, 'receiverId': receiverId, 'content': content}),
    );
    return response.statusCode == 201;
  }

  static Future<List<dynamic>> getMessages(int user1, int user2) async {
    final response = await http.get(Uri.parse('$baseUrl/message/$user1/$user2'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['messages'] ?? [];
    } else {
      throw Exception('Failed to get messages');
    }
  }
}
