import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/provider_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Map<String, dynamic>> _providers = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();
  String? _category;
  final _categories = ['Beauty', 'Cleaning', 'Plumbing', 'Electrical', 'Tutoring', 'Fitness', 'Other'];
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _load();
    _loadFavorites();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getProviders(category: _category);
    if (mounted) setState(() { _providers = data; _applyFilter(); _loading = false; });
  }

  Future<void> _loadFavorites() async {
    final favs = await SupabaseService.getFavorites();
    if (mounted) setState(() => _favorites = favs.map((f) => f['provider_id'] as String).toSet());
  }

  void _applyFilter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = _providers.where((p) {
        final name = (p['display_name'] ?? '').toLowerCase();
        final city = (p['city'] ?? '').toLowerCase();
        return name.contains(q) || city.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _search,
                    onChanged: (_) => _applyFilter(),
                    decoration: const InputDecoration(
                      hintText: 'Search providers...',
                      prefixIcon: Icon(Icons.search, color: ZyncoColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final sel = _category == cat;
                        return GestureDetector(
                          onTap: () { setState(() => _category = sel ? null : cat); _load(); },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: sel ? ZyncoColors.gradient : null,
                              color: sel ? null : ZyncoColors.surface,
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
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: ZyncoColors.primary))
                  : _filtered.isEmpty
                      ? const Center(child: Text('No providers found', style: TextStyle(color: ZyncoColors.textSecondary)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => ProviderCard(
                              provider: _filtered[i],
                              isFavorite: _favorites.contains(_filtered[i]['id']),
                              onTap: () => context.push('/provider/${_filtered[i]['id']}'),
                              onFavorite: () async {
                                await SupabaseService.toggleFavorite(_filtered[i]['id']);
                                _loadFavorites();
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
