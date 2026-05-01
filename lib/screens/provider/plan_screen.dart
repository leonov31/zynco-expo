import 'package:flutter/material.dart';
import '../../theme.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyncoColors.background,
      appBar: AppBar(title: const Text('Subscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Text('Choose Your Plan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Upgrade to reach more customers', style: TextStyle(color: ZyncoColors.textSecondary)),
          const SizedBox(height: 24),
          ...[
            ('🌟 Free', 'Free', ['Basic profile', '6 gallery photos', '1 video', 'Basic messaging'], false),
            ('🚀 Boost', '\$9.99/mo', ['Everything in Free', 'Boosted ranking', 'Priority support', 'Analytics'], true),
            ('👑 Top', '\$24.99/mo', ['Everything in Boost', 'Top placement', 'Verified badge', 'Unlimited media', 'Calendar sync'], false),
          ].map((plan) {
            final isHighlight = plan.$4 as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: isHighlight ? ZyncoColors.gradient : null,
                color: isHighlight ? null : ZyncoColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isHighlight ? Colors.transparent : ZyncoColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(plan.$1 as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    Text(plan.$2 as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isHighlight ? Colors.white : ZyncoColors.primary)),
                  ]),
                  const SizedBox(height: 12),
                  ...(plan.$3 as List<String>).map((f) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
                    Icon(Icons.check_circle, size: 16, color: isHighlight ? Colors.white : ZyncoColors.success),
                    const SizedBox(width: 8),
                    Text(f, style: TextStyle(color: isHighlight ? Colors.white : ZyncoColors.textPrimary, fontSize: 13)),
                  ]))),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: plan.$2 == 'Free' ? null : () {},
                      style: ElevatedButton.styleFrom(backgroundColor: isHighlight ? Colors.white : ZyncoColors.primary, foregroundColor: isHighlight ? ZyncoColors.primary : Colors.white),
                      child: Text(plan.$2 == 'Free' ? 'Current Plan' : 'Upgrade'),
                    ),
                  ),
                ]),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text('Coming Soon for Customers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...[('💰', 'Wallet', 'Pay for services'), ('🎯', 'Loyalty Points', 'Earn rewards'), ('👥', 'Group Bookings', 'Book with friends'), ('🎁', 'Gift Cards', 'Give services as gifts')]
              .map((item) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                leading: Text(item.$1, style: const TextStyle(fontSize: 24)),
                title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(item.$3, style: const TextStyle(color: ZyncoColors.textSecondary, fontSize: 12)),
                trailing: const Text('SOON', style: TextStyle(color: ZyncoColors.textSecondary, fontSize: 10)),
              ))),
        ]),
      ),
    );
  }
}
