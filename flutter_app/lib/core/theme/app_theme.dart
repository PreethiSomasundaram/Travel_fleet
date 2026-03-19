import 'package:flutter/material.dart';

class AppTheme {
  static const _brandBlue = Color(0xFF0E7490);
  static const _brandMint = Color(0xFF34D399);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandBlue,
      secondary: _brandMint,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F7FA),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF0F172A),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brandBlue, width: 1.2),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFFF0F5F9),
      selectedIconTheme: IconThemeData(color: Color(0xFF0E7490)),
      indicatorColor: Color(0xFFD7EEF3),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFF8FBFD)),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandMint,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF061018),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.all(8),
      color: Color(0xFF0C1A24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF11202B),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brandMint, width: 1.2),
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF0B1822)),
  );
}
