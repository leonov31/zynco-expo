
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import 'map_screen.dart';
import 'explore_screen.dart';
import 'saved_screen.dart';
import 'bookings_screen.dart';
import 'chats_screen.dart';
import 'profile_screen.dart';

class CustomerShell extends StatefulWidget {
  final Widget child;
  const CustomerShell({super.key, required this.child});
  @override State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _idx = 0;
  static const _screens = [MapScreen(), ExploreScreen(), SavedScreen(), BookingsScreen(), ChatsScreen(), CustomerProfileScreen()];
  static const _routes = ['/customer', '/customer/explore', '/customer/saved', '/customer/bookings', '/customer/chats', '/customer/me'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: ZyncoColors.surface,
          border: Border(top: BorderSide(color: ZyncoColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          backgroundColor: ZyncoColors.surface,
          selectedItemColor: ZyncoColors.primary,
          unselectedItemColor: ZyncoColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Saved'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
          ],
        ),
      ),
    );
  }
}
