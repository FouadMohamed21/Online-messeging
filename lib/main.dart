import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'utils/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  // Check if there is already a saved session
  final loggedIn = await SessionManager.isLoggedIn();
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
