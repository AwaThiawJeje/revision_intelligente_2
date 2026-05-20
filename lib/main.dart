import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const RevisionApp(),
    ),
  );
}

class RevisionApp extends StatelessWidget {
  const RevisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Révision Intelligente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF65C3C8), // Cupcake primary (teal)
          onPrimary: Colors.white,
          secondary: Color(0xFFEF9FBC), // Cupcake secondary (pink)
          onSecondary: Colors.white,
          error: Color(0xFFF87272),
          onError: Colors.white,
          background: Color(0xFFFAF7F5), // Base 100
          onBackground: Color(0xFF291334), // Neutral text
          surface: Color(0xFFFAF7F5),
          onSurface: Color(0xFF291334),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF7F5),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF65C3C8), // Primary
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF291334), // Neutral text
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF291334),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF7F5),
          foregroundColor: Color(0xFF291334),
          elevation: 0,
          centerTitle: false,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
