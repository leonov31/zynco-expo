
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'router.dart';
import 'providers/auth_provider.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: AppConstants.supabaseUrl, anonKey: AppConstants.supabaseAnonKey);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  runApp(const ZyncoApp());
}

class ZyncoApp extends StatelessWidget {
  const ZyncoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..initialize(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => MaterialApp.router(
          title: 'Zynco',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          routerConfig: buildRouter(auth),
        ),
      ),
    );
  }

  ThemeData _buildTheme() => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: ZyncoColors.primary,
      secondary: ZyncoColors.accent,
      surface: ZyncoColors.surface,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: ZyncoColors.background,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: ZyncoColors.background, elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ZyncoColors.primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white, side: const BorderSide(color: ZyncoColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: ZyncoColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ZyncoColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ZyncoColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ZyncoColors.primary, width: 2)),
      labelStyle: const TextStyle(color: ZyncoColors.textSecondary),
      hintStyle: const TextStyle(color: ZyncoColors.textSecondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ZyncoColors.surface, selectedItemColor: ZyncoColors.primary,
      unselectedItemColor: ZyncoColors.textSecondary, type: BottomNavigationBarType.fixed, elevation: 0,
    ),
  );
}

class ZyncoColors {
  static const primary = Color(0xFF7C3AED);
  static const accent = Color(0xFF38BDF8);
  static const gradient1 = Color(0xFFC850F0);
  static const background = Color(0xFF0F0F1A);
  static const surface = Color(0xFF1A1A2E);
  static const surface2 = Color(0xFF252540);
  static const border = Color(0xFF2A2A4A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0A0B0);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);

  static const gradient = LinearGradient(
    colors: [gradient1, primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
