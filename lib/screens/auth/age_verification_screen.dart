
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';

class AgeVerificationScreen extends StatelessWidget {
  const AgeVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ZyncoColors.gradient,
                  boxShadow: [BoxShadow(color: ZyncoColors.primary.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                ),
                child: const Icon(Icons.location_on, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 24),
              // App name
              ShaderMask(
                shaderCallback: (b) => ZyncoColors.gradient.createShader(b),
                child: const Text('Zynco', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(height: 8),
              const Text('Connect with local services', style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 16)),
              const Spacer(flex: 2),
              // Age question
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ZyncoColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ZyncoColors.border),
                ),
                child: Column(
                  children: [
                    const Text('Are you 18 or older?',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    const Text('This app is intended only for users aged 18 and above.',
                      style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 14),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    // Yes button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: ZyncoColors.gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          await context.read<AuthProvider>().confirmAge();
                          if (context.mounted) context.go('/login');
                        },
                        child: const Text('Yes, I am 18+',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // No button
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: ZyncoColors.surface,
                            title: const Text('Access Denied', style: TextStyle(color: Colors.white)),
                            content: const Text('You must be 18 or older to use Zynco.',
                              style: TextStyle(color: ZyncoColors.textSecondary)),
                            actions: [
                              TextButton(
                                onPressed: () => SystemNavigator.pop(),
                                child: const Text('Close App', style: TextStyle(color: ZyncoColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('No'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text('By continuing you agree to our Terms & Privacy Policy',
                style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
