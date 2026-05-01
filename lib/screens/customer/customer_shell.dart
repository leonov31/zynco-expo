import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class CustomerShell extends StatelessWidget {
  final Widget child;
  const CustomerShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/map')) return 0;
    if (loc.startsWith('/explore')) return 1;
    if (loc.startsWith('/saved')) return 2;
    if (loc.startsWith('/bookings')) return 3;
    if (loc.startsWith('/chats')) return 4;
    if (loc.startsWith('/me')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ZyncoColors.surface,
          border: const Border(top: BorderSide(color: ZyncoColors.border)),
        ),
        child: SafeArea(
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _selectedIndex(context),
            indicatorColor: ZyncoColors.primary.withOpacity(0.15),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map, color: ZyncoColors.primary), label: 'Map'),
              NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search, color: ZyncoColors.primary), label: 'Explore'),
              NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite, color: ZyncoColors.primary), label: 'Saved'),
              NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today, color: ZyncoColors.primary), label: 'Bookings'),
              NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble, color: ZyncoColors.primary), label: 'Chats'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: ZyncoColors.primary), label: 'Me'),
            ],
            onDestinationSelected: (i) {
              switch (i) {
                case 0: context.go('/map'); break;
                case 1: context.go('/explore'); break;
                case 2: context.go('/saved'); break;
                case 3: context.go('/bookings'); break;
                case 4: context.go('/chats'); break;
                case 5: context.go('/me'); break;
              }
            },
          ),
        ),
      ),
    );
  }
}
