import 'package:flutter/material.dart';

class ZyncoColors {
  static const primary = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFFC850F0);
  static const primaryBlue = Color(0xFF38BDF8);
  static const background = Color(0xFF0F0F1A);
  static const surface = Color(0xFF1A1A2E);
  static const surface2 = Color(0xFF252540);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0A0B0);
  static const border = Color(0xFF2A2A4A);

  static const gradient = LinearGradient(
    colors: [primaryLight, primary, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ZyncoTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: ZyncoColors.background,
    colorScheme: const ColorScheme.dark(
      primary: ZyncoColors.primary,
      secondary: ZyncoColors.primaryBlue,
      surface: ZyncoColors.surface,
      error: ZyncoColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ZyncoColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ZyncoColors.background,
      foregroundColor: ZyncoColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ZyncoColors.surface,
      selectedItemColor: ZyncoColors.primary,
      unselectedItemColor: ZyncoColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ZyncoColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ZyncoColors.textPrimary,
        side: const BorderSide(color: ZyncoColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ZyncoColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ZyncoColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ZyncoColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ZyncoColors.primary),
      ),
      labelStyle: const TextStyle(color: ZyncoColors.textSecondary),
      hintStyle: const TextStyle(color: ZyncoColors.textSecondary),
    ),
    cardTheme: CardTheme(
      color: ZyncoColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ZyncoColors.border),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ZyncoColors.surface2,
      labelStyle: const TextStyle(color: ZyncoColors.textPrimary, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(color: ZyncoColors.border, thickness: 1),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: ZyncoColors.textPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: ZyncoColors.textPrimary, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: ZyncoColors.textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: ZyncoColors.textPrimary, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: ZyncoColors.textPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: ZyncoColors.textPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: ZyncoColors.textPrimary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: ZyncoColors.textPrimary),
      bodyMedium: TextStyle(color: ZyncoColors.textSecondary),
      bodySmall: TextStyle(color: ZyncoColors.textSecondary, fontSize: 12),
    ),
  );
}
