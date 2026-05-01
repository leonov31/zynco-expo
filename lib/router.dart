import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/age_verification_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/customer/customer_shell.dart';
import 'screens/customer/map_screen.dart';
import 'screens/customer/explore_screen.dart';
import 'screens/customer/saved_screen.dart';
import 'screens/customer/customer_bookings_screen.dart';
import 'screens/customer/chats_screen.dart';
import 'screens/customer/customer_profile_screen.dart';
import 'screens/customer/provider_profile_screen.dart';
import 'screens/customer/chat_screen.dart';
import 'screens/provider/provider_shell.dart';
import 'screens/provider/dashboard_screen.dart';
import 'screens/provider/provider_bookings_screen.dart';
import 'screens/provider/provider_chats_screen.dart';
import 'screens/provider/plan_screen.dart';
import 'screens/provider/provider_profile_screen.dart';
import 'screens/provider/edit_profile_screen.dart';

final _supabase = Supabase.instance.client;

GoRouter createRouter(bool ageConfirmed) {
  return GoRouter(
    initialLocation: ageConfirmed ? '/login' : '/age',
    redirect: (context, state) {
      final session = _supabase.auth.currentSession;
      final isAuth = session != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot') ||
          state.matchedLocation.startsWith('/age');

      if (isAuth && isAuthRoute) {
        return _getHomeRoute();
      }
      return null;
    },
    routes: [
      GoRoute(path: '/age', builder: (_, __) => const AgeVerificationScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),

      // Customer shell
      ShellRoute(
        builder: (_, __, child) => CustomerShell(child: child),
        routes: [
          GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
          GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
          GoRoute(path: '/saved', builder: (_, __) => const SavedScreen()),
          GoRoute(path: '/bookings', builder: (_, __) => const CustomerBookingsScreen()),
          GoRoute(path: '/chats', builder: (_, __) => const ChatsScreen()),
          GoRoute(path: '/me', builder: (_, __) => const CustomerProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/provider/:id',
        builder: (_, state) => ProviderProfileScreen(providerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) => ChatScreen(chatId: state.pathParameters['id']!),
      ),

      // Provider shell
      ShellRoute(
        builder: (_, __, child) => ProviderShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/provider-bookings', builder: (_, __) => const ProviderBookingsScreen()),
          GoRoute(path: '/provider-chats', builder: (_, __) => const ProviderChatsScreen()),
          GoRoute(path: '/plan', builder: (_, __) => const PlanScreen()),
          GoRoute(path: '/provider-me', builder: (_, __) => const ProviderProfileScreen()),
        ],
      ),
      GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
    ],
  );
}

String _getHomeRoute() {
  // Will be determined by user role after auth
  return '/map';
}
