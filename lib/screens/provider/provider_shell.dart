
import 'package:flutter/material.dart';
import '../../main.dart';
import 'dashboard_screen.dart';
import 'provider_bookings_screen.dart';
import 'provider_chats_screen.dart';
import 'plan_screen.dart';
import 'provider_profile_screen.dart';

class ProviderShell extends StatefulWidget {
  final Widget child;
  const ProviderShell({super.key, required this.child});
  @override State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell> {
  int _idx = 0;
  static const _screens = [DashboardScreen(), ProviderBookingsScreen(), ProviderChatsScreen(), PlanScreen(), ProviderProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: ZyncoColors.surface, border: Border(top: BorderSide(color: ZyncoColors.border))),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          backgroundColor: ZyncoColors.surface,
          selectedItemColor: ZyncoColors.primary,
          unselectedItemColor: ZyncoColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.star_outline), label: 'Plan'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
          ],
        ),
      ),
    );
  }
}
