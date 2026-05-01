
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});
  @override State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);
  List<BookingModel> _bookings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prov = context.read<AuthProvider>().providerProfile;
    if (prov == null) return;
    try {
      final res = await Supabase.instance.client.from('bookings').select().eq('provider_id', prov.id).order('scheduled_for', ascending: false);
      setState(() { _bookings = (res as List).map((e) => BookingModel.fromJson(e)).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _updateStatus(String id, String status) async {
    await Supabase.instance.client.from('bookings').update({'status': status}).eq('id', id);
    _load();
  }

  List<BookingModel> _filter(String? s) => s == null ? _bookings : _bookings.where((b) => b.status == s).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: ZyncoColors.background,
        bottom: TabBar(
          controller: _tab,
          labelColor: ZyncoColors.primary,
          unselectedLabelColor: ZyncoColors.textSecondary,
          indicatorColor: ZyncoColors.primary,
          tabs: const [Tab(text: 'All'), Tab(text: 'Pending'), Tab(text: 'Confirmed'), Tab(text: 'Done')],
        ),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator(color: ZyncoColors.primary))
        : TabBarView(
            controller: _tab,
            children: [
              _BookingList(bookings: _filter(null), onUpdate: _updateStatus),
              _BookingList(bookings: _filter('pending'), onUpdate: _updateStatus),
              _BookingList(bookings: _filter('confirmed'), onUpdate: _updateStatus),
              _BookingList(bookings: _filter('completed'), onUpdate: _updateStatus),
            ],
          ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final Function(String, String) onUpdate;
  const _BookingList({required this.bookings, required this.onUpdate});
  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return const Center(child: Text('No bookings', style: TextStyle(color: ZyncoColors.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (c, i) {
        final b = bookings[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZyncoColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.customerName ?? 'Customer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(DateFormat('MMM d, yyyy · HH:mm').format(b.scheduledFor), style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
              if (b.note != null) Text(b.note!, style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
              if (b.status == 'pending') ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: ZyncoColors.success, minimumSize: const Size(0, 38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () => onUpdate(b.id, 'confirmed'),
                      child: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: ZyncoColors.error), minimumSize: const Size(0, 38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () => onUpdate(b.id, 'cancelled'),
                      child: const Text('Cancel', style: TextStyle(color: ZyncoColors.error)),
                    ),
                  ),
                ]),
              ],
            ],
          ),
        );
      },
    );
  }
}
