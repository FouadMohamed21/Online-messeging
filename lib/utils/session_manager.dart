import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyId = 'user_id';
  static const _keyName = 'user_name';
  static const _keyEmail = 'user_email';

  /// Save the logged-in user to local storage
  static Future<void> saveUser(int id, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
  }

  /// Returns true if a user session exists
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyId);
  }

  /// Get the saved user id
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyId);
  }

  /// Get the saved user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  /// Get the saved user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Clear the saved session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
