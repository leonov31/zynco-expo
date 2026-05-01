
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  bool _isOnline = false;
  List<String> _categories = [];
  List<String> _gallery = [];
  String? _videoUrl;
  bool _loading = false;
  final _picker = ImagePicker();
  final _sb = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    final p = context.read<AuthProvider>().providerProfile;
    if (p != null) {
      _nameCtrl.text = p.displayName;
      _bioCtrl.text = p.bio ?? '';
      _cityCtrl.text = p.city ?? '';
      _isOnline = p.isOnline;
      _categories = List.from(p.categories);
      _gallery = List.from(p.galleryUrls);
      _videoUrl = p.galleryVideoUrl;
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _bioCtrl.dispose(); _cityCtrl.dispose(); _catCtrl.dispose(); super.dispose(); }

  Future<void> _uploadPhoto() async {
    if (_gallery.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Free plan limit: 6 photos. Upgrade for unlimited.'),
        backgroundColor: ZyncoColors.error));
      return;
    }
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final uid = context.read<AuthProvider>().user!.id;
    final path = 'gallery/$uid/photos/${const Uuid().v4()}.jpg';
    await _sb.storage.from('gallery').upload(path, File(file.path));
    final url = _sb.storage.from('gallery').getPublicUrl(path);
    setState(() => _gallery.add(url));
  }

  Future<void> _uploadVideo() async {
    if (_videoUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Free plan limit: 1 video. Upgrade for unlimited.'),
        backgroundColor: ZyncoColors.error));
      return;
    }
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    final uid = context.read<AuthProvider>().user!.id;
    final path = 'gallery/$uid/video/${const Uuid().v4()}.mp4';
    await _sb.storage.from('gallery').upload(path, File(file.path));
    final url = _sb.storage.from('gallery').getPublicUrl(path);
    setState(() => _videoUrl = url);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final uid = context.read<AuthProvider>().user!.id;
    try {
      // ALWAYS use user_id, NOT id!
      await _sb.from('providers').update({
        'display_name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'is_online': _isOnline,
        'categories': _categories,
        'gallery_urls': _gallery,
        'gallery_video_url': _videoUrl,
      }).eq('user_id', uid);
      await context.read<AuthProvider>().refreshProviderProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!'), backgroundColor: ZyncoColors.success));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: ZyncoColors.error));
    }
    setState(() => _loading = false);
  }

  void _addCategory() {
    final cat = _catCtrl.text.trim();
    if (cat.isEmpty) return;
    setState(() { _categories.add(cat); _catCtrl.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: ZyncoColors.background,
        actions: [
          TextButton(onPressed: _loading ? null : _save,
            child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save', style: TextStyle(color: ZyncoColors.primary, fontWeight: FontWeight.w700))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Online toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: ZyncoColors.border)),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: _isOnline ? ZyncoColors.success : ZyncoColors.textSecondary, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  const Text('Show as online', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Switch(value: _isOnline, onChanged: (v) => setState(() => _isOnline = v), activeColor: ZyncoColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Display Name', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 16),
            TextField(controller: _bioCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio', prefixIcon: Icon(Icons.description_outlined))),
            const SizedBox(height: 16),
            TextField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city_outlined))),
            const SizedBox(height: 24),
            // Categories
            const Text('Categories', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: _catCtrl, decoration: const InputDecoration(hintText: 'Add category (e.g. Massage, Cleaning...)'))),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: ZyncoColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), minimumSize: const Size(50, 50)),
                onPressed: _addCategory,
                child: const Icon(Icons.add),
              ),
            ]),
            if (_categories.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: _categories.map((c) => Chip(
                label: Text(c, style: const TextStyle(color: Colors.white)),
                backgroundColor: ZyncoColors.surface2,
                side: const BorderSide(color: ZyncoColors.primary),
                deleteIcon: const Icon(Icons.close, size: 14, color: ZyncoColors.textSecondary),
                onDeleted: () => setState(() => _categories.remove(c)),
              )).toList()),
            ],
            const SizedBox(height: 24),
            // Gallery
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              Text('${_gallery.length}/6 photos · ${_videoUrl != null ? 1 : 0}/1 video',
                style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: 6,
              itemBuilder: (c, i) {
                final hasPhoto = i < _gallery.length;
                return GestureDetector(
                  onTap: hasPhoto ? null : _uploadPhoto,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ZyncoColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: hasPhoto ? ZyncoColors.primary : ZyncoColors.border),
                      image: hasPhoto ? DecorationImage(image: NetworkImage(_gallery[i]), fit: BoxFit.cover) : null,
                    ),
                    child: hasPhoto
                      ? Align(alignment: Alignment.topRight, child: GestureDetector(
                          onTap: () => setState(() => _gallery.removeAt(i)),
                          child: Container(margin: const EdgeInsets.all(4), padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: ZyncoColors.error, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 12))))
                      : const Icon(Icons.add_photo_alternate_outlined, color: ZyncoColors.textSecondary),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Video slot
            GestureDetector(
              onTap: _uploadVideo,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ZyncoColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _videoUrl != null ? ZyncoColors.primary : ZyncoColors.border),
                ),
                child: Row(children: [
                  Icon(Icons.videocam_outlined, color: _videoUrl != null ? ZyncoColors.primary : ZyncoColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_videoUrl != null ? 'Video uploaded ✓' : '📹 Intro video (mp4, max 50MB)',
                    style: TextStyle(color: _videoUrl != null ? ZyncoColors.primary : ZyncoColors.textSecondary))),
                  if (_videoUrl != null) GestureDetector(onTap: () => setState(() => _videoUrl = null),
                    child: const Icon(Icons.close, color: ZyncoColors.error, size: 18)),
                ]),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
