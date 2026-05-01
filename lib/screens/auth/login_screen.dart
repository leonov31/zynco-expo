import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import '../../widgets/zynco_button.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await SupabaseService.signIn(_email.text.trim(), _password.text);
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      await auth.loadProfile();
      if (!mounted) return;
      if (auth.isProvider) {
        context.go('/dashboard');
      } else {
        context.go('/map');
      }
    } on AuthException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Login failed. Please try again.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),
              ShaderMask(
                shaderCallback: (b) => ZyncoColors.gradient.createShader(b),
                child: const Icon(Icons.location_on, size: 56, color: Colors.white),
              ),
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (b) => ZyncoColors.gradient.createShader(b),
                child: const Text('Zynco', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 8),
              const Text('Welcome back', style: TextStyle(color: ZyncoColors.textSecondary)),
              const SizedBox(height: 40),
              // Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ZyncoColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ZyncoColors.border),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: ZyncoColors.textSecondary)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined, color: ZyncoColors.textSecondary),
                        suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: ZyncoColors.textSecondary), onPressed: () => setState(() => _obscure = !_obscure)),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: ZyncoColors.error, fontSize: 13)),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () => context.go('/forgot'), child: const Text('Forgot password?', style: TextStyle(color: ZyncoColors.primary))),
                    ),
                    const SizedBox(height: 8),
                    ZyncoGradientButton(label: 'Sign In', onPressed: _signIn, loading: _loading),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No account? ', style: TextStyle(color: ZyncoColors.textSecondary)),
                  GestureDetector(onTap: () => context.go('/register'), child: const Text('Sign up', style: TextStyle(color: ZyncoColors.primary, fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
