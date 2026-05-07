import 'package:flutter/material.dart';
import 'package:leafloop/starting/landing_page.dart';

// Global notifier to manage theme state across the app
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() => runApp(const LeafLoopApp());

class LeafLoopApp extends StatelessWidget {
  const LeafLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LeafLoop',
          themeMode: currentMode,
          // Light Theme Configuration
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamily: 'sans-serif',
            scaffoldBackgroundColor: const Color(0xFFF1F4F0),
            primaryColor: const Color(0xFF3B5236),
            cardColor: Colors.white,
          ),
          // Dark Theme Configuration
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'sans-serif',
            scaffoldBackgroundColor: const Color(0xFF1A1C19),
            primaryColor: const Color(
              0xFF8BAE7E,
            ), // A lighter green for better contrast in dark mode
            cardColor: const Color(0xFF2D2F2C),
          ),
          home: const LandingPage(),
        );
      },
    );
  }
}
