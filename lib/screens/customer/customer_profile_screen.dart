import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../theme.dart';
import '../../widgets/zynco_avatar.dart';
import '../../widgets/zynco_button.dart';
import '../../providers/auth_provider.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late TextEditingController _name;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().userProfile;
    _name = TextEditingController(text: profile?['display_name'] ?? '');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final uid = Supabase.instance.client.auth.currentUser!.id;
    await Supabase.instance.client.from('users').update({'display_name': _name.text.trim()}).eq('id', uid);
    if (mounted) {
      await context.read<AuthProvider>().loadProfile();
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated'), backgroundColor: ZyncoColors.success));
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img == null) return;
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final bytes = await File(img.path).readAsBytes();
    final path = 'avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await Supabase.instance.client.storage.from('avatars').uploadBinary(path, bytes);
    final url = Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
    await Supabase.instance.client.from('users').update({'avatar_url': url}).eq('id', uid);
    if (mounted) await context.read<AuthProvider>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.userProfile;
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(children: [
                ZyncoAvatar(url: profile?['avatar_url'], name: profile?['display_name'] ?? '?', size: 88, showRing: true),
                Positioned(bottom: 0, right: 0, child: Container(
                  width: 26, height: 26,
                  decoration: const BoxDecoration(color: ZyncoColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                )),
              ]),
            ),
            const SizedBox(height: 8),
            Text(profile?['email'] ?? '', style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZyncoColors.border)),
              child: Column(children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Display Name', prefixIcon: Icon(Icons.badge_outlined, color: ZyncoColors.textSecondary))),
                const SizedBox(height: 16),
                TextField(
                  enabled: false,
                  controller: TextEditingController(text: profile?['email'] ?? ''),
                  decoration: const InputDecoration(labelText: 'Email (read-only)', prefixIcon: Icon(Icons.email_outlined, color: ZyncoColors.textSecondary)),
                ),
                const SizedBox(height: 20),
                ZyncoGradientButton(label: 'Save Changes', onPressed: _save, loading: _saving),
              ]),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, color: ZyncoColors.error),
              label: const Text('Sign Out', style: TextStyle(color: ZyncoColors.error)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: ZyncoColors.error), minimumSize: const Size(double.infinity, 48)),
            ),
          ],
        ),
      ),
    );
  }
}
