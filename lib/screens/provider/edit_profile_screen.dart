import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/zynco_avatar.dart';
import '../../widgets/zynco_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _city = TextEditingController();
  final _catInput = TextEditingController();
  List<String> _categories = [];
  List<String> _gallery = [];
  String? _videoUrl;
  bool _isOnline = false;
  bool _loading = true;
  bool _saving = false;
  Map<String, dynamic>? _provider;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SupabaseService.getMyProvider();
    if (mounted) setState(() {
      _provider = p;
      _name.text = p?['display_name'] ?? '';
      _bio.text = p?['bio'] ?? '';
      _city.text = p?['city'] ?? '';
      _categories = ((p?['categories'] as List?) ?? []).cast<String>();
      _gallery = ((p?['gallery_urls'] as List?) ?? []).cast<String>();
      _videoUrl = p?['gallery_video_url'];
      _isOnline = p?['is_online'] ?? false;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final uid = Supabase.instance.client.auth.currentUser!.id;
    await Supabase.instance.client.from('providers').update({
      'display_name': _name.text.trim(),
      'bio': _bio.text.trim(),
      'city': _city.text.trim(),
      'categories': _categories,
      'is_online': _isOnline,
      'gallery_urls': _gallery,
      'gallery_video_url': _videoUrl,
    }).eq('user_id', uid);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: ZyncoColors.success));
    }
  }

  Future<void> _addPhoto() async {
    if (_gallery.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Free plan limit: 6 photos. Upgrade for unlimited.'), backgroundColor: Colors.orange));
      return;
    }
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img == null) return;
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final bytes = await File(img.path).readAsBytes();
    final path = 'gallery/$uid/photos/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await Supabase.instance.client.storage.from('gallery').uploadBinary(path, bytes);
    final url = Supabase.instance.client.storage.from('gallery').getPublicUrl(path);
    if (mounted) setState(() => _gallery.add(url));
  }

  Future<void> _addVideo() async {
    if (_videoUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Free plan limit: 1 video. Upgrade for unlimited.')));
      return;
    }
    final vid = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (vid == null) return;
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final bytes = await File(vid.path).readAsBytes();
    final path = 'gallery/$uid/video/${DateTime.now().millisecondsSinceEpoch}.mp4';
    await Supabase.instance.client.storage.from('gallery').uploadBinary(path, bytes);
    final url = Supabase.instance.client.storage.from('gallery').getPublicUrl(path);
    if (mounted) setState(() => _videoUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: ZyncoColors.background, body: Center(child: CircularProgressIndicator(color: ZyncoColors.primary)));
    final uid = Supabase.instance.client.auth.currentUser!.id;
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Edit Profile'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          Center(child: GestureDetector(
            onTap: () async {
              final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
              if (img == null) return;
              final bytes = await File(img.path).readAsBytes();
              final path = 'avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
              await Supabase.instance.client.storage.from('avatars').uploadBinary(path, bytes);
              final url = Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
              await Supabase.instance.client.from('users').update({'avatar_url': url}).eq('id', uid);
              await Supabase.instance.client.from('providers').update({'avatar_url': url}).eq('user_id', uid);
            },
            child: Stack(children: [
              ZyncoAvatar(url: _provider?['avatar_url'], name: _name.text, size: 80, showRing: true),
              Positioned(bottom: 0, right: 0, child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: ZyncoColors.primary, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, size: 12, color: Colors.white))),
            ]),
          )),
          const SizedBox(height: 24),
          // Online toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZyncoColors.border)),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _isOnline ? ZyncoColors.success : ZyncoColors.textSecondary, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              const Expanded(child: Text('Show as online')),
              Switch(value: _isOnline, onChanged: (v) => setState(() => _isOnline = v), activeColor: ZyncoColors.primary),
            ]),
          ),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Display Name')),
          const SizedBox(height: 12),
          TextField(controller: _bio, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio', alignLabelWithHint: true)),
          const SizedBox(height: 12),
          TextField(controller: _city, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city_outlined, color: ZyncoColors.textSecondary))),
          const SizedBox(height: 20),
          // Categories
          const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _catInput, decoration: const InputDecoration(hintText: 'Add category...', isDense: true))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () {
              if (_catInput.text.trim().isEmpty) return;
              setState(() => _categories.add(_catInput.text.trim()));
              _catInput.clear();
            }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)), child: const Text('+ Add')),
          ]),
          const SizedBox(height: 8),
          if (_categories.isNotEmpty) Wrap(spacing: 8, runSpacing: 4, children: _categories.map((c) => Chip(
            label: Text(c),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () => setState(() => _categories.remove(c)),
          )).toList()),
          const SizedBox(height: 20),
          // Gallery
          Row(children: [
            const Expanded(child: Text('Gallery', style: TextStyle(fontWeight: FontWeight.w600))),
            Text('${_gallery.length}/6 photos · ${_videoUrl != null ? 1 : 0}/1 video', style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 12)),
          ]),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: 6,
            itemBuilder: (_, i) {
              if (i < _gallery.length) {
                return Stack(fit: StackFit.expand, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_gallery[i], fit: BoxFit.cover)),
                  Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => _gallery.removeAt(i)),
                    child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: ZyncoColors.error, shape: BoxShape.circle), child: const Icon(Icons.close, size: 12, color: Colors.white)))),
                ]);
              }
              return GestureDetector(
                onTap: _addPhoto,
                child: Container(decoration: BoxDecoration(color: ZyncoColors.surface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: ZyncoColors.border, style: BorderStyle.solid)),
                  child: const Icon(Icons.add_photo_alternate_outlined, color: ZyncoColors.textSecondary)),
              );
            },
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _addVideo,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: ZyncoColors.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZyncoColors.border)),
              child: Row(children: [
                const Icon(Icons.videocam_outlined, color: ZyncoColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(_videoUrl != null ? 'Video uploaded ✓' : '📹 Intro video (mp4, max 50MB)', style: TextStyle(color: _videoUrl != null ? ZyncoColors.success : ZyncoColors.textSecondary))),
                if (_videoUrl != null) GestureDetector(onTap: () => setState(() => _videoUrl = null), child: const Icon(Icons.close, size: 18, color: ZyncoColors.error)),
              ]),
            ),
          ),
          const SizedBox(height: 28),
          ZyncoGradientButton(label: 'Save Changes', onPressed: _save, loading: _saving),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
