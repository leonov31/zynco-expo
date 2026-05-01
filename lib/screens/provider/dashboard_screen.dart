import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/supabase_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/zynco_avatar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _provider;
  List<Map<String, dynamic>> _recentBookings = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SupabaseService.getMyProvider();
    final b = await SupabaseService.getBookings(role: 'provider');
    if (mounted) setState(() { _provider = p; _recentBookings = b.take(5).toList(); _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.userProfile;
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: ZyncoColors.primary))
            : RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Header
                    Row(children: [
                      ZyncoAvatar(url: profile?['avatar_url'], name: profile?['display_name'] ?? '?', size: 48),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Hi, ${profile?['display_name'] ?? ''}! 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Your provider dashboard', style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
                      ])),
                    ]),
                    const SizedBox(height: 20),
                    // Plan card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(gradient: ZyncoColors.gradient, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        const Icon(Icons.star, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('FREE PLAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Upgrade to get more visibility', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ])),
                        ElevatedButton(onPressed: () => context.go('/plan'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: ZyncoColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), child: const Text('Upgrade', style: TextStyle(fontSize: 12))),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    // Stats
                    GridView.count(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2, childAspectRatio: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                      children: [
                        _StatCard(icon: Icons.favorite, label: 'Favorites', value: '0', color: Colors.red),
                        _StatCard(icon: Icons.chat_bubble, label: 'Chats', value: '0', color: ZyncoColors.primaryBlue),
                        _StatCard(icon: Icons.calendar_today, label: 'Bookings', value: '${_recentBookings.length}', color: ZyncoColors.primary),
                        _StatCard(icon: Icons.star, label: 'Rating', value: '${(_provider?['rating'] ?? 0.0).toStringAsFixed(1)}', color: Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick actions
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(onPressed: () => context.push('/edit-profile'), icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit Profile'))),
                      const SizedBox(width: 12),
                      Expanded(child: OutlinedButton.icon(onPressed: () => context.go('/plan'), icon: const Icon(Icons.upgrade_outlined, size: 16), label: const Text('Subscription'))),
                    ]),
                    const SizedBox(height: 20),
                    // Recent bookings
                    if (_recentBookings.isNotEmpty) ...[
                      const Text('Recent Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      ..._recentBookings.map((b) {
                        final user = b['users'] as Map<String, dynamic>? ?? {};
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: ZyncoAvatar(url: user['avatar_url'], name: user['display_name'] ?? '?', size: 40),
                            title: Text(user['display_name'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: ZyncoColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                              child: Text(b['status']?.toString().toUpperCase() ?? '', style: const TextStyle(color: ZyncoColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 20),
                    // Coming soon
                    const Text('Coming Soon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...[
                      ('📊', 'Analytics', 'Track your performance'),
                      ('📣', 'Promotions', 'Boost your visibility'),
                      ('✅', 'Verified Badge', 'Build trust with customers'),
                      ('📅', 'Calendar Sync', 'Sync with your calendar'),
                    ].map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(item.$1, style: const TextStyle(fontSize: 24)),
                        title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(item.$3, style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 12)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: ZyncoColors.surface2, borderRadius: BorderRadius.circular(8)),
                          child: const Text('SOON', style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 10)),
                        ),
                      ),
                    )),
                  ]),
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZyncoColors.border)),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 11)),
        ]),
      ]),
    );
  }
}
