
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../models/app_models.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  List<ProviderModel> _providers = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await Supabase.instance.client.from('providers').select().eq('is_hidden', false);
      setState(() { _providers = (res as List).map((e) => ProviderModel.fromJson(e)).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  List<ProviderModel> get _filtered => _search.isEmpty ? _providers
    : _providers.where((p) => p.displayName.toLowerCase().contains(_search.toLowerCase())
      || p.categories.any((c) => c.toLowerCase().contains(_search.toLowerCase()))).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: const Icon(Icons.search, color: ZyncoColors.textSecondary),
                  suffixIcon: _search.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); }) : null,
                ),
              ),
            ),
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator(color: ZyncoColors.primary))
                : _filtered.isEmpty
                  ? const Center(child: Text('No providers found', style: TextStyle(color: ZyncoColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (c, i) => _ProviderCard(provider: _filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZyncoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZyncoColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: ZyncoColors.gradient,
              border: Border.all(color: ZyncoColors.primary, width: 2)),
            child: ClipOval(child: provider.avatarUrl != null
              ? CachedNetworkImage(imageUrl: provider.avatarUrl!, fit: BoxFit.cover)
              : const Icon(Icons.person, color: Colors.white, size: 30)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(provider.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  if (provider.isOnline)
                    Container(width: 8, height: 8,
                      decoration: const BoxDecoration(color: ZyncoColors.success, shape: BoxShape.circle)),
                ]),
                if (provider.categories.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(spacing: 4, children: provider.categories.take(3).map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: ZyncoColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(c, style: const TextStyle(color: ZyncoColors.primary, fontSize: 11)),
                  )).toList()),
                ],
                if (provider.rating != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(' ${provider.rating!.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    if (provider.city != null) Text(' · ${provider.city}', style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 12)),
                  ]),
                ],
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: ZyncoColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}
