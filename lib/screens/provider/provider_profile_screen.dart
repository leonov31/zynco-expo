
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('My Profile'), backgroundColor: ZyncoColors.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: ZyncoColors.gradient, border: Border.all(color: ZyncoColors.primary, width: 2)),
              child: const Icon(Icons.person, color: Colors.white, size: 44)),
            const SizedBox(height: 12),
            Text(auth.user?.displayName ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            Text(auth.user?.email ?? '', style: const TextStyle(color: ZyncoColors.textSecondary)),
            const SizedBox(height: 24),
            _MenuItem(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
            _MenuItem(icon: Icons.star_outline, label: 'Subscription Plan', onTap: () {}),
            _MenuItem(icon: Icons.logout, label: 'Sign Out', onTap: () => auth.signOut(), color: ZyncoColors.error),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: ZyncoColors.surface,
      leading: Icon(icon, color: color ?? ZyncoColors.primary),
      title: Text(label, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w600)),
      trailing: color == null ? const Icon(Icons.arrow_forward_ios, size: 14, color: ZyncoColors.textSecondary) : null,
      onTap: onTap,
    ),
  );
}
