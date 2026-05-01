import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/zynco_avatar.dart';
import '../../widgets/zynco_button.dart';

class ProviderProfileScreen extends StatefulWidget {
  final String providerId;
  const ProviderProfileScreen({super.key, required this.providerId});
  @override State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  Map<String, dynamic>? _provider;
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;
  bool _isFav = false;
  double _myRating = 0;
  final _reviewCtrl = TextEditingController();
  bool _submitting = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SupabaseService.getProvider(widget.providerId);
    final r = await SupabaseService.getReviews(widget.providerId);
    final favs = await SupabaseService.getFavorites();
    if (mounted) setState(() {
      _provider = p; _reviews = r;
      _isFav = favs.any((f) => f['provider_id'] == widget.providerId);
      _loading = false;
    });
  }

  Future<void> _book() async {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: ZyncoColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BookingSheet(providerId: widget.providerId),
    );
  }

  Future<void> _message() async {
    final chatId = await SupabaseService.getOrCreateChat(widget.providerId);
    if (mounted) context.push('/chat/$chatId');
  }

  Future<void> _submitReview() async {
    if (_myRating == 0 || _reviewCtrl.text.isEmpty) return;
    setState(() => _submitting = true);
    await SupabaseService.createReview(providerId: widget.providerId, rating: _myRating.toInt(), comment: _reviewCtrl.text.trim());
    _reviewCtrl.clear();
    setState(() { _myRating = 0; _submitting = false; });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: ZyncoColors.background, body: Center(child: CircularProgressIndicator(color: ZyncoColors.primary)));
    final p = _provider!;
    final categories = (p['categories'] as List?)?.cast<String>() ?? [];
    final gallery = (p['gallery_urls'] as List?)?.cast<String>() ?? [];
    final rating = (p['rating'] ?? 0.0).toDouble();

    return Scaffold(
      backgroundColor: ZyncoColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: ZyncoColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [ZyncoColors.primaryLight.withOpacity(0.3), ZyncoColors.primaryBlue.withOpacity(0.2)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
                Center(child: ZyncoAvatar(url: p['avatar_url'], name: p['display_name'] ?? '?', size: 88, showRing: true)),
              ]),
            ),
            actions: [
              IconButton(icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border, color: _isFav ? Colors.red : Colors.white), onPressed: () async { await SupabaseService.toggleFavorite(widget.providerId); _load(); }),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['display_name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                if (p['city'] != null) ...[const SizedBox(height: 4), Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: ZyncoColors.textSecondary), const SizedBox(width: 4), Text(p['city'], style: const TextStyle(color: ZyncoColors.textSecondary))])],
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 4),
                  Text('(${_reviews.length} reviews)', style: const TextStyle(color: ZyncoColors.textSecondary)),
                  if (p['is_online'] == true) ...[const SizedBox(width: 12), Container(width: 8, height: 8, decoration: const BoxDecoration(color: ZyncoColors.success, shape: BoxShape.circle)), const SizedBox(width: 4), const Text('Online', style: TextStyle(color: ZyncoColors.success, fontSize: 12))],
                ]),
                const SizedBox(height: 12),
                if (categories.isNotEmpty) Wrap(spacing: 8, runSpacing: 4, children: categories.map((c) => Chip(label: Text(c))).toList()),
                const SizedBox(height: 16),
                // Action buttons
                Row(children: [
                  Expanded(child: ElevatedButton.icon(onPressed: _book, icon: const Icon(Icons.calendar_today, size: 16), label: const Text('Book Now'))),
                  const SizedBox(width: 12),
                  Expanded(child: OutlinedButton.icon(onPressed: _message, icon: const Icon(Icons.chat_bubble_outline, size: 16), label: const Text('Message'))),
                ]),
                if (p['bio'] != null && p['bio'].isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(p['bio'], style: const TextStyle(color: ZyncoColors.textSecondary, height: 1.5)),
                ],
                // Gallery
                if (gallery.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      itemBuilder: (_, i) => Container(
                        width: 100, height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: ZyncoColors.surface),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(imageUrl: gallery[i], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
                // Reviews section
                const SizedBox(height: 24),
                const Text('Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                // Add review
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZyncoColors.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Leave a review', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    RatingBar.builder(
                      initialRating: _myRating,
                      minRating: 1, direction: Axis.horizontal, allowHalfRating: false, itemCount: 5, itemSize: 28,
                      itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (r) => setState(() => _myRating = r),
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: _reviewCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Share your experience...')),
                    const SizedBox(height: 8),
                    ZyncoButton(label: 'Submit Review', onPressed: _submitReview, loading: _submitting, width: double.infinity),
                  ]),
                ),
                const SizedBox(height: 16),
                // Review list
                ..._reviews.map((r) {
                  final user = r['users'] as Map<String, dynamic>? ?? {};
                  final rating = (r['rating'] ?? 0) as int;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZyncoColors.border)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        ZyncoAvatar(url: user['avatar_url'], name: user['display_name'] ?? '?', size: 32),
                        const SizedBox(width: 10),
                        Expanded(child: Text(user['display_name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600))),
                        Row(children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < rating ? Colors.amber : ZyncoColors.border))),
                      ]),
                      if (r['comment'] != null && r['comment'].isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(r['comment'], style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 13)),
                      ],
                    ]),
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  final String providerId;
  const _BookingSheet({required this.providerId});
  @override State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _note = TextEditingController();
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final scheduled = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    await SupabaseService.createBooking(providerId: widget.providerId, scheduledFor: scheduled, note: _note.text.trim().isEmpty ? null : _note.text.trim());
    if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking confirmed!'), backgroundColor: ZyncoColors.success)); }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Book Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
            if (d != null) setState(() => _date = d);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: ZyncoColors.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZyncoColors.border)),
            child: Row(children: [const Icon(Icons.calendar_today, color: ZyncoColors.primary, size: 18), const SizedBox(width: 10), Text('${_date.day}.${_date.month}.${_date.year}', style: const TextStyle(fontWeight: FontWeight.w500))]),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: _time);
            if (t != null) setState(() => _time = t);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: ZyncoColors.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZyncoColors.border)),
            child: Row(children: [const Icon(Icons.access_time, color: ZyncoColors.primary, size: 18), const SizedBox(width: 10), Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.w500))]),
          ),
        ),
        const SizedBox(height: 12),
        TextField(controller: _note, decoration: const InputDecoration(hintText: 'Note (optional)', prefixIcon: Icon(Icons.note_outlined, color: ZyncoColors.textSecondary))),
        const SizedBox(height: 20),
        ZyncoGradientButton(label: 'Confirm Booking', onPressed: _confirm, loading: _loading),
      ]),
    );
  }
}
