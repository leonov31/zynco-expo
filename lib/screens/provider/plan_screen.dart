
import 'package:flutter/material.dart';
import '../../main.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Subscription Plans'), backgroundColor: ZyncoColors.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _PlanCard(name: 'Free', price: '€0', features: ['1 video + 6 photos', 'Basic listing', 'Customer messages'], isActive: true),
            const SizedBox(height: 16),
            _PlanCard(name: 'Boost', price: '€9.99/mo', features: ['Everything in Free', 'Priority listing', 'Unlimited gallery', 'Analytics'], isActive: false),
            const SizedBox(height: 16),
            _PlanCard(name: 'Top', price: '€19.99/mo', features: ['Everything in Boost', 'Featured placement', 'Verified badge', 'Promotions'], isActive: false),
            const SizedBox(height: 32),
            const Text('Coming Soon for Customers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8,
              children: ['💰 Wallet', '🎯 Loyalty Points', '👥 Group Bookings', '🎁 Gift Cards'].map((s) =>
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: ZyncoColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: ZyncoColors.border)),
                  child: Text(s, style: const TextStyle(color: ZyncoColors.textSecondary)))).toList()),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name, price;
  final List<String> features;
  final bool isActive;
  const _PlanCard({required this.name, required this.price, required this.features, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isActive ? ZyncoColors.gradient : null,
        color: isActive ? null : ZyncoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.transparent : ZyncoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(price, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(f, style: const TextStyle(color: Colors.white)),
            ]),
          )),
          if (!isActive) ...[
            const SizedBox(height: 12),
            Container(width: double.infinity, decoration: BoxDecoration(gradient: ZyncoColors.gradient, borderRadius: BorderRadius.circular(10)),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {},
                child: Text('Upgrade to $name', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              )),
          ],
        ],
      ),
    );
  }
}
