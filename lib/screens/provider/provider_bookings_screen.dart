import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/zynco_avatar.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});
  @override State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override void initState() { super.initState(); _tabs = TabController(length: 4, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(
        title: const Text('Bookings'),
        bottom: TabBar(controller: _tabs, indicatorColor: ZyncoColors.primary, labelColor: ZyncoColors.primary, unselectedLabelColor: ZyncoColors.textSecondary,
          tabs: const [Tab(text: 'All'), Tab(text: 'Pending'), Tab(text: 'Confirmed'), Tab(text: 'Done')]),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [null, 'pending', 'confirmed', 'completed'].map((s) => _ProviderBookingsList(status: s)).toList(),
      ),
    );
  }
}

class _ProviderBookingsList extends StatefulWidget {
  final String? status;
  const _ProviderBookingsList({this.status});
  @override State<_ProviderBookingsList> createState() => _ProviderBookingsListState();
}

class _ProviderBookingsListState extends State<_ProviderBookingsList> {
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await SupabaseService.getBookings(role: 'provider', status: widget.status);
    if (mounted) setState(() { _bookings = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: ZyncoColors.primary));
    if (_bookings.isEmpty) return const Center(child: Text('No bookings', style: TextStyle(color: ZyncoColors.textSecondary)));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (_, i) {
          final b = _bookings[i];
          final user = b['users'] as Map<String, dynamic>? ?? {};
          final date = DateTime.tryParse(b['scheduled_for'] ?? '') ?? DateTime.now();
          final status = b['status'] as String;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  ZyncoAvatar(url: user['avatar_url'], name: user['display_name'] ?? '?', size: 40),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user['display_name'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(DateFormat('MMM d, yyyy • HH:mm').format(date), style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 12)),
                  ])),
                  _StatusChip(status: status),
                ]),
                if (b['note'] != null && b['note'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: ZyncoColors.surface2, borderRadius: BorderRadius.circular(8)),
                    child: Text(b['note'], style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13))),
                ],
                if (status == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: ElevatedButton(onPressed: () async { await SupabaseService.updateBookingStatus(b['id'], 'confirmed'); _load(); }, style: ElevatedButton.styleFrom(backgroundColor: ZyncoColors.success), child: const Text('Confirm'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: () async { await SupabaseService.updateBookingStatus(b['id'], 'cancelled'); _load(); }, style: OutlinedButton.styleFrom(side: const BorderSide(color: ZyncoColors.error), foregroundColor: ZyncoColors.error), child: const Text('Cancel'))),
                  ]),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    final colors = {'pending': Colors.orange, 'confirmed': ZyncoColors.success, 'cancelled': ZyncoColors.error, 'completed': ZyncoColors.primary};
    final color = colors[status] ?? ZyncoColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
