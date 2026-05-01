
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../models/app_models.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapCtrl = MapController();
  List<ProviderModel> _providers = [];
  ProviderModel? _selected;
  LatLng _center = const LatLng(51.5074, -0.1278);
  bool _loading = true;
  String? _filterCategory;

  @override
  void initState() { super.initState(); _loadProviders(); }

  Future<void> _loadProviders() async {
    try {
      final res = await Supabase.instance.client
        .from('providers').select().eq('is_hidden', false).not('lat', 'is', null);
      setState(() {
        _providers = (res as List).map((e) => ProviderModel.fromJson(e)).toList();
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _locateMe() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) await Geolocator.requestPermission();
    try {
      final pos = await Geolocator.getCurrentPosition();
      final ll = LatLng(pos.latitude, pos.longitude);
      _mapCtrl.move(ll, 14);
      setState(() => _center = ll);
    } catch (_) {}
  }

  List<ProviderModel> get _filtered => _filterCategory == null
    ? _providers
    : _providers.where((p) => p.categories.contains(_filterCategory)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(initialCenter: _center, initialZoom: 12, onTap: (_, __) => setState(() => _selected = null)),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              MarkerLayer(
                markers: _filtered.map((p) => Marker(
                  point: LatLng(p.lat!, p.lng!),
                  width: 40, height: 40,
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = p),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: ZyncoColors.gradient,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: ZyncoColors.primary.withOpacity(0.5), blurRadius: 8)],
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ZyncoColors.border)),
                      child: const Text('Zynco', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ZyncoColors.border)),
                    child: Text('${_filtered.length} nearby', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          // Locate me button - bottom 96px
          Positioned(
            right: 16, bottom: 96,
            child: GestureDetector(
              onTap: _locateMe,
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: ZyncoColors.gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: ZyncoColors.primary.withOpacity(0.4), blurRadius: 12)],
                ),
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ),
          // Provider popup
          if (_selected != null)
            Positioned(
              left: 16, right: 16, bottom: 16,
              child: _ProviderPopup(provider: _selected!, onClose: () => setState(() => _selected = null)),
            ),
        ],
      ),
    );
  }
}

class _ProviderPopup extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onClose;
  const _ProviderPopup({required this.provider, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZyncoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ZyncoColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: ZyncoColors.primary,
            backgroundImage: provider.avatarUrl != null ? NetworkImage(provider.avatarUrl!) : null,
            child: provider.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                if (provider.categories.isNotEmpty)
                  Text(provider.categories.take(2).join(' · '), style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 12)),
                if (provider.rating != null)
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(' ${provider.rating!.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, color: ZyncoColors.textSecondary), onPressed: onClose),
        ],
      ),
    );
  }
}
