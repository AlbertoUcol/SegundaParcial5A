import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const InventoryManagementApp());
}

class InventoryManagementApp extends StatelessWidget {
  const InventoryManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF7041B8);
    const darkPurple = Color(0xFF4E2A82);
    const accentGreen = Color(0xFF2E8B57);
    const lightGreen = Color(0xFFE4F3E8);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primaryPurple,
          brightness: Brightness.light,
        ).copyWith(
          primary: darkPurple,
          secondary: accentGreen,
          secondaryContainer: lightGreen,
          tertiary: const Color(0xFF8C65C6),
          surface: const Color(0xFFFFFEFF),
        );

    return MaterialApp(
      title: 'Gestión de Productos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF7F5FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F5FA),
          foregroundColor: darkPurple,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: darkPurple.withValues(alpha: 0.09),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          margin: const EdgeInsets.symmetric(vertical: 5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE5DDED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: primaryPurple, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: darkPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentGreen,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
