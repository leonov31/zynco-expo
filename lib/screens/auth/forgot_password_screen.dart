import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import '../../widgets/zynco_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  Future<void> _send() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(_email.text.trim());
      setState(() { _sent = true; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Reset Password'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/login'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.mark_email_read_outlined, color: ZyncoColors.success, size: 64),
                const SizedBox(height: 16),
                const Text('Check your email', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('We sent a reset link to ${_email.text}', style: const TextStyle(color: ZyncoColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ZyncoButton(label: 'Back to Login', onPressed: () => context.go('/login'), width: double.infinity),
              ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.lock_reset_outlined, color: ZyncoColors.primary, size: 64),
                const SizedBox(height: 16),
                const Text('Forgot your password?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Enter your email and we\'ll send you a reset link.', style: TextStyle(color: ZyncoColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: ZyncoColors.textSecondary))),
                const SizedBox(height: 24),
                ZyncoGradientButton(label: 'Send Reset Link', onPressed: _send, loading: _loading),
              ]),
      ),
    );
  }
}
