
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl = TabController(length: 4, vsync: this);
  List<BookingModel> _bookings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.id;
    if (uid == null) return;
    try {
      final res = await Supabase.instance.client.from('bookings').select().eq('customer_id', uid).order('scheduled_for', ascending: false);
      setState(() { _bookings = (res as List).map((e) => BookingModel.fromJson(e)).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  List<BookingModel> _filter(String? status) => status == null ? _bookings : _bookings.where((b) => b.status == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: ZyncoColors.background,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: ZyncoColors.primary,
          unselectedLabelColor: ZyncoColors.textSecondary,
          indicatorColor: ZyncoColors.primary,
          tabs: const [Tab(text: 'All'), Tab(text: 'Pending'), Tab(text: 'Confirmed'), Tab(text: 'Done')],
        ),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: ZyncoColors.primary))
        : TabBarView(
            controller: _tabCtrl,
            children: [
              _BookingList(bookings: _filter(null)),
              _BookingList(bookings: _filter('pending')),
              _BookingList(bookings: _filter('confirmed')),
              _BookingList(bookings: _filter('completed')),
            ],
          ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  const _BookingList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return const Center(child: Text('No bookings', style: TextStyle(color: ZyncoColors.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (c, i) {
        final b = bookings[i];
        final statusColor = b.status == 'confirmed' ? ZyncoColors.success : b.status == 'cancelled' ? ZyncoColors.error : ZyncoColors.primary;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZyncoColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(b.providerName ?? 'Provider', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(b.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today, size: 14, color: ZyncoColors.textSecondary),
                const SizedBox(width: 6),
                Text(DateFormat('MMM d, yyyy · HH:mm').format(b.scheduledFor), style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
              ]),
              if (b.note != null) ...[
                const SizedBox(height: 4),
                Text(b.note!, style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
              ],
            ],
          ),
        );
      },
    );
  }
}
