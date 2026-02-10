import 'package:flutter/material.dart';

/// Centralised theme for Travel Fleet Management.
class AppTheme {
  AppTheme._();

  // ── Colours ───────────────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF1565C0); // Blue 800
  static const Color accentColor = Color(0xFF42A5F5); // Blue 400
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color bgColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;

  // ── Text Styles ───────────────────────────────────────────────────────────
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );
  static const TextStyle subHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF424242),
  );
  static const TextStyle body = TextStyle(fontSize: 14, color: Color(0xFF616161));
  static const TextStyle caption = TextStyle(fontSize: 12, color: Color(0xFF9E9E9E));

  // ── Theme Data ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: bgColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    cardTheme: const CardThemeData(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
