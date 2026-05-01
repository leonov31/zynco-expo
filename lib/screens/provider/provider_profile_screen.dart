import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';
import '../../widgets/zynco_avatar.dart';
import '../../widgets/zynco_button.dart';
import '../../providers/auth_provider.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.userProfile;
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          ZyncoAvatar(url: profile?['avatar_url'], name: profile?['display_name'] ?? '?', size: 80, showRing: true),
          const SizedBox(height: 12),
          Text(profile?['display_name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(profile?['email'] ?? '', style: const TextStyle(color: ZyncoColors.textSecondary)),
          const SizedBox(height: 24),
          ZyncoGradientButton(label: 'Edit Profile', onPressed: () => context.push('/edit-profile')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout, color: ZyncoColors.error),
            label: const Text('Sign Out', style: TextStyle(color: ZyncoColors.error)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: ZyncoColors.error), minimumSize: const Size(double.infinity, 48)),
          ),
        ]),
      ),
    );
  }
}
