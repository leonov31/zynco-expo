
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('My Profile'), backgroundColor: ZyncoColors.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: ZyncoColors.gradient, border: Border.all(color: ZyncoColors.primary, width: 2)),
                  child: const Icon(Icons.person, color: Colors.white, size: 48),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(color: ZyncoColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(user?.displayName ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            Text(user?.email ?? '', style: const TextStyle(color: ZyncoColors.textSecondary)),
            const SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(labelText: 'Display Name', prefixIcon: const Icon(Icons.person_outline)),
              controller: TextEditingController(text: user?.displayName),
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined)),
              controller: TextEditingController(text: user?.email),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: ZyncoColors.gradient, borderRadius: BorderRadius.circular(12)),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {},
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), side: const BorderSide(color: ZyncoColors.error)),
              onPressed: () => auth.signOut(),
              child: const Text('Sign Out', style: TextStyle(color: ZyncoColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}
