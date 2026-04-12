import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../utils/session_manager.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by main() before this runs.
  debugPrint('📩 Background FCM message: ${message.messageId}');
}

class FcmApi {
  static final _fcm = FirebaseMessaging.instance;

  /// Call once after Firebase.initializeApp() — requests permission, gets
  /// the device token and uploads it to our backend, then sets up listeners.
  static Future<void> init() async {
    // 1. Request notification permission (Android 13+ / iOS)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔔 FCM permission: ${settings.authorizationStatus}');

    // 2. Get the token and upload it
    await _uploadToken();

    // 3. Token may rotate — upload the new one when it does
    _fcm.onTokenRefresh.listen(_saveTokenToBackend);

    // 4. Foreground messages — just log (your polling already shows them)
    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint('📩 Foreground FCM: ${msg.notification?.title} — ${msg.notification?.body}');
    });

    // 5. App opened from a notification in the background
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('🚀 Notification tapped: ${msg.data}');
    });
  }

  /// Gets the current FCM token and saves it to the server.
  static Future<void> _uploadToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('❌ FCM token upload error: $e');
    }
  }

  /// Sends the FCM token to the backend linked to the logged-in user.
  static Future<void> _saveTokenToBackend(String token) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return; // not logged in yet
    try {
      await ApiService.saveFcmToken(userId, token);
      debugPrint('✅ FCM token saved for user $userId');
    } catch (e) {
      debugPrint('❌ Failed to save FCM token: $e');
    }
  }
}