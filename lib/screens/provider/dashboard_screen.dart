
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bookings = 0, _chats = 0;
  double _rating = 0;
  List<BookingModel> _recent = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.id;
    if (uid == null) return;
    try {
      final prov = context.read<AuthProvider>().providerProfile;
      if (prov == null) return;
      final bookRes = await Supabase.instance.client.from('bookings').select().eq('provider_id', prov.id).order('created_at', ascending: false).limit(5);
      setState(() {
        _recent = (bookRes as List).map((e) => BookingModel.fromJson(e)).toList();
        _bookings = _recent.length;
        _rating = prov.rating ?? 0;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = auth.providerProfile;
    final plan = ['Free', 'Boost', 'Top'][prov?.subscriptionLevel ?? 0];
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, ${auth.user?.displayName ?? ''}!', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const Text('Your provider dashboard', style: TextStyle(color: ZyncoColors.textSecondary)),
              const SizedBox(height: 24),
              // Plan card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: ZyncoColors.gradient, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('CURRENT PLAN', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      Text(plan, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    ]),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: ZyncoColors.primary, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                      onPressed: () {},
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Stats
              Row(children: [
                _Stat(label: 'BOOKINGS', value: '$_bookings', icon: Icons.calendar_today),
                const SizedBox(width: 12),
                _Stat(label: 'RATING', value: _rating > 0 ? _rating.toStringAsFixed(1) : 'N/A', icon: Icons.star),
              ]),
              const SizedBox(height: 20),
              const Text('Recent Bookings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._recent.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: ZyncoColors.border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(b.customerName ?? 'Customer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: ZyncoColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(b.status.toUpperCase(), style: const TextStyle(color: ZyncoColors.primary, fontSize: 11)),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 20),
              const Text('Coming Soon', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['📊 Analytics', '📣 Promotions', '✅ Verified Badge', '📅 Calendar Sync'].map((s) =>
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: ZyncoColors.border)),
                    child: Text(s, style: const TextStyle(color: ZyncoColors.textSecondary)),
                  ),
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Stat({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZyncoColors.border)),
      child: Column(
        children: [
          Icon(icon, color: ZyncoColors.primary),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 11)),
        ],
      ),
    ),
  );
}
