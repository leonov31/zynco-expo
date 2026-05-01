import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class ProviderShell extends StatelessWidget {
  final Widget child;
  const ProviderShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/dashboard')) return 0;
    if (loc.startsWith('/provider-bookings')) return 1;
    if (loc.startsWith('/provider-chats')) return 2;
    if (loc.startsWith('/plan')) return 3;
    if (loc.startsWith('/provider-me')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: ZyncoColors.surface, border: const Border(top: BorderSide(color: ZyncoColors.border))),
        child: SafeArea(
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _selectedIndex(context),
            indicatorColor: ZyncoColors.primary.withOpacity(0.15),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: ZyncoColors.primary), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today, color: ZyncoColors.primary), label: 'Bookings'),
              NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble, color: ZyncoColors.primary), label: 'Chats'),
              NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star, color: ZyncoColors.primary), label: 'Plan'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: ZyncoColors.primary), label: 'Me'),
            ],
            onDestinationSelected: (i) {
              switch (i) {
                case 0: context.go('/dashboard'); break;
                case 1: context.go('/provider-bookings'); break;
                case 2: context.go('/provider-chats'); break;
                case 3: context.go('/plan'); break;
                case 4: context.go('/provider-me'); break;
              }
            },
          ),
        ),
      ),
    );
  }
}
