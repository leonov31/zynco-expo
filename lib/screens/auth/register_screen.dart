import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import '../../widgets/zynco_button.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  String _role = 'customer';
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _signUp() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await SupabaseService.signUp(_email.text.trim(), _password.text);
      final uid = res.user!.id;
      await SupabaseService.createUser(uid, _email.text.trim(), _name.text.trim(), _role);
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      await auth.loadProfile();
      if (!mounted) return;
      context.go(_role == 'provider' ? '/dashboard' : '/map');
    } on AuthException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Registration failed. Please try again.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Create Account'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/login'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Role selector
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZyncoColors.border)),
                child: Row(
                  children: [
                    _roleTab('Customer', 'customer', Icons.person_outline),
                    _roleTab('Provider', 'provider', Icons.business_center_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _role == 'customer' ? 'Find and book local services' : 'Offer your services to customers',
                style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: ZyncoColors.border)),
                child: Column(
                  children: [
                    TextField(controller: _name, decoration: const InputDecoration(labelText: 'Display Name', prefixIcon: Icon(Icons.badge_outlined, color: ZyncoColors.textSecondary))),
                    const SizedBox(height: 16),
                    TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: ZyncoColors.textSecondary))),
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
                    if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: ZyncoColors.error, fontSize: 13))],
                    const SizedBox(height: 24),
                    ZyncoGradientButton(label: 'Create Account', onPressed: _signUp, loading: _loading),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: ZyncoColors.textSecondary)),
                  GestureDetector(onTap: () => context.go('/login'), child: const Text('Sign in', style: TextStyle(color: ZyncoColors.primary, fontWeight: FontWeight.w600))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleTab(String label, String value, IconData icon) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? ZyncoColors.gradient : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : ZyncoColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: selected ? Colors.white : ZyncoColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}
