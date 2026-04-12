import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'utils/session_manager.dart';
import 'fcm_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialise Firebase (required before any Firebase usage)
  await Firebase.initializeApp();

  // Register background message handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Check if there is already a saved session
  final loggedIn = await SessionManager.isLoggedIn();

  // If already logged in, upload FCM token silently (token may have rotated)
  if (loggedIn) {
    FcmApi.init(); // fire-and-forget; don't block startup
  }

  runApp(FouadMessengerApp(startLoggedIn: loggedIn));
}

class FouadMessengerApp extends StatelessWidget {
  final bool startLoggedIn;
  const FouadMessengerApp({super.key, required this.startLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fouad Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF14B8A6),
          surface: Color(0xFF1E293B),
        ),
      ),
      // Route directly to ChatList if already logged in, otherwise LoginScreen
      home: startLoggedIn ? const ChatListScreen() : const LoginScreen(),
    );
  }
}
