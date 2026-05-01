import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme.dart';
import '../../widgets/zynco_button.dart';

class AgeVerificationScreen extends StatelessWidget {
  const AgeVerificationScreen({super.key});

  Future<void> _confirmAge(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('age_confirmed', true);
    if (context.mounted) context.go('/login');
  }

  void _denyAge(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ZyncoColors.surface,
        title: const Text('Access Denied', style: TextStyle(color: Colors.white)),
        content: const Text('You must be 18 or older to use Zynco.', style: TextStyle(color: ZyncoColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit App', style: TextStyle(color: ZyncoColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Neon logo glow
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [ZyncoColors.primary.withOpacity(0.3), Colors.transparent]),
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (b) => ZyncoColors.gradient.createShader(b),
                    child: const Icon(Icons.location_on, size: 80, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (b) => ZyncoColors.gradient.createShader(b),
                child: const Text('Zynco', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 8),
              const Text('Local services, near you', style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 14)),
              const Spacer(),
              // Glass card
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: ZyncoColors.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: ZyncoColors.primary.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: ZyncoColors.primary.withOpacity(0.1), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: ZyncoColors.primary, size: 40),
                    const SizedBox(height: 16),
                    const Text('Are you 18 or older?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text('This app is intended for users 18 years and older only.', style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    ZyncoGradientButton(label: 'Yes, I am 18+', onPressed: () => _confirmAge(context)),
                    const SizedBox(height: 12),
                    ZyncoButton(label: 'No', onPressed: () => _denyAge(context), outlined: true, width: double.infinity),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('By continuing you agree to our Terms & Privacy Policy', style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 11), textAlign: TextAlign.center),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
