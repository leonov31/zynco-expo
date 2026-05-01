import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../services/supabase_service.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});
  @override State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _statuses = ['all', 'pending', 'confirmed', 'completed'];
  final _labels = ['All', 'Pending', 'Confirmed', 'Completed'];

  @override void initState() { super.initState(); _tabs = TabController(length: 4, vsync: this); }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: ZyncoColors.primary,
          labelColor: ZyncoColors.primary,
          unselectedLabelColor: ZyncoColors.textSecondary,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: _statuses.map((s) => _BookingsList(status: s == 'all' ? null : s)).toList(),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final String? status;
  const _BookingsList({this.status});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SupabaseService.getBookings(role: 'customer', status: status),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: ZyncoColors.primary));
        final bookings = snap.data ?? [];
        if (bookings.isEmpty) return const Center(child: Text('No bookings', style: TextStyle(color: ZyncoColors.textSecondary)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (_, i) {
            final b = bookings[i];
            final provider = b['providers'] as Map<String, dynamic>? ?? {};
            final date = DateTime.tryParse(b['scheduled_for'] ?? '') ?? DateTime.now();
            final status = b['status'] as String;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(provider['display_name'] ?? 'Provider', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                    _StatusBadge(status: status),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.calendar_today, size: 14, color: ZyncoColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(DateFormat('MMM d, yyyy • HH:mm').format(date), style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
                  ]),
                  if (b['note'] != null && b['note'].isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(b['note'], style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
                  ],
                ]),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final colors = {
      'pending': Colors.orange, 'confirmed': ZyncoColors.success,
      'cancelled': ZyncoColors.error, 'completed': ZyncoColors.primary,
    };
    final color = colors[status] ?? ZyncoColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
