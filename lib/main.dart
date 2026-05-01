import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'theme.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Supabase.initialize(
    url: 'https://vydsipgzyomnosxxvdxi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5ZHNpcGd6eW9tbm9zeHh2ZHhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczNzU2NTAsImV4cCI6MjA5Mjk1MTY1MH0.qfr2wMtb0MI8l7JHLnyHlKAIhCqp6LM5lQT03HYG-fU',
  );

  final prefs = await SharedPreferences.getInstance();
  final ageConfirmed = prefs.getBool('age_confirmed') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: ZyncoApp(ageConfirmed: ageConfirmed),
    ),
  );
}

class ZyncoApp extends StatelessWidget {
  final bool ageConfirmed;
  const ZyncoApp({super.key, required this.ageConfirmed});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zynco',
      theme: ZyncoTheme.dark,
      routerConfig: createRouter(ageConfirmed),
      debugShowCheckedModeBanner: false,
    );
  }
}
