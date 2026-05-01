import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/provider_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Map<String, dynamic>> _favs = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await SupabaseService.getFavorites();
    if (mounted) setState(() { _favs = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Saved')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: ZyncoColors.primary))
          : _favs.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.favorite_border, size: 64, color: ZyncoColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('No saved providers', style: TextStyle(color: ZyncoColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => context.go('/explore'), child: const Text('Explore providers', style: TextStyle(color: ZyncoColors.primary))),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _favs.length,
                    itemBuilder: (_, i) {
                      final p = _favs[i]['providers'] as Map<String, dynamic>? ?? {};
                      return ProviderCard(
                        provider: p,
                        isFavorite: true,
                        onTap: () => context.push('/provider/${p['id']}'),
                        onFavorite: () async { await SupabaseService.toggleFavorite(p['id']); _load(); },
                      );
                    },
                  ),
                ),
    );
  }
}
