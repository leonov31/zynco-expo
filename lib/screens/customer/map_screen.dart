import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/zynco_avatar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> _providers = [];
  bool _loading = true;
  String? _selectedCategory;
  final _categories = ['All', 'Beauty', 'Cleaning', 'Plumbing', 'Electrical', 'Tutoring', 'Fitness', 'Other'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getProviders(category: _selectedCategory == 'All' ? null : _selectedCategory);
    if (mounted) setState(() { _providers = data; _loading = false; });
  }

  Future<void> _locateMe() async {
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
      await Geolocator.getCurrentPosition();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated!'), backgroundColor: ZyncoColors.success));
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: Stack(
        children: [
          // Neon grid background (map placeholder — add Google Maps with API key)
          Container(
            color: const Color(0xFF0A0A15),
            child: CustomPaint(painter: _GridPainter(), size: Size.infinite),
          ),
          // Gradient overlay at bottom
          Positioned(
            bottom: 0, left: 0, right: 0, height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, ZyncoColors.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Top UI
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search bar
                    GestureDetector(
                      onTap: () => context.go('/explore'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: ZyncoColors.surface.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ZyncoColors.primary.withOpacity(0.3)),
                          boxShadow: [BoxShadow(color: ZyncoColors.primary.withOpacity(0.15), blurRadius: 12)],
                        ),
                        child: Row(children: [
                          const Icon(Icons.search, color: ZyncoColors.textSecondary),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Search providers...', style: TextStyle(color: ZyncoColors.textSecondary))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: ZyncoColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text('${_providers.length} nearby', style: const TextStyle(color: ZyncoColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Category chips
                    SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (_, i) {
                          final cat = _categories[i];
                          final sel = (_selectedCategory ?? 'All') == cat;
                          return GestureDetector(
                            onTap: () { setState(() => _selectedCategory = cat == 'All' ? null : cat); _load(); },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: sel ? ZyncoColors.gradient : null,
                                color: sel ? null : ZyncoColors.surface.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: sel ? Colors.transparent : ZyncoColors.border),
                              ),
                              child: Text(cat, style: TextStyle(color: sel ? Colors.white : ZyncoColors.textSecondary, fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Provider markers (simulated positions)
          if (!_loading)
            ..._providers.asMap().entries.where((e) => e.value['lat'] != null).map((e) {
              final size = MediaQuery.of(context).size;
              final x = 60.0 + (e.key * 97 + 40) % (size.width - 80);
              final y = 180.0 + (e.key * 113 + 60) % (size.height - 320);
              return Positioned(
                left: x, top: y,
                child: GestureDetector(
                  onTap: () => _showProviderPopup(context, e.value),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ZyncoColors.gradient,
                      boxShadow: [BoxShadow(color: ZyncoColors.primary.withOpacity(0.5), blurRadius: 8)],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ZyncoAvatar(url: e.value['avatar_url'], name: e.value['display_name'] ?? '?', size: 38),
                  ),
                ),
              );
            }),
          // Locate Me button — bottom: 96px above nav bar per TZ
          Positioned(
            bottom: 96,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'locate',
              onPressed: _locateMe,
              backgroundColor: ZyncoColors.surface,
              elevation: 4,
              child: const Icon(Icons.my_location, color: ZyncoColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showProviderPopup(BuildContext context, Map<String, dynamic> p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ZyncoColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            ZyncoAvatar(url: p['avatar_url'], name: p['display_name'] ?? '?', size: 56, showRing: true),
            const SizedBox(width: 16),
            Expanded(child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['display_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (p['city'] != null) Text(p['city'], style: const TextStyle(color: ZyncoColors.textSecondary)),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  Text(' ${(p['rating'] ?? 0).toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: ZyncoColors.textSecondary)),
                ]),
              ],
            )),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); context.push('/provider/${p['id']}'); },
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF7C3AED).withOpacity(0.07)..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Radial glow at center
    final glow = Paint()
      ..shader = RadialGradient(colors: [const Color(0xFF7C3AED).withOpacity(0.12), Colors.transparent])
          .createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width * 0.6));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glow);
  }
  @override bool shouldRepaint(_) => false;
}
