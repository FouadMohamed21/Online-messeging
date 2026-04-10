import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/chat_list_screen.dart';

void main() {
  // Enforce transparent status bar with light icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FouadMessengerApp());
}

class FouadMessengerApp extends StatelessWidget {
  const FouadMessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fouad Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Premium Slate 900
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1), // Vibrant Indigo 500
          secondary: Color(0xFF14B8A6), // Vibrant Teal 500
          surface: Color(0xFF1E293B), // Slate 800
        ),
      ),
      home: const ChatListScreen(),
    );
  }
}
