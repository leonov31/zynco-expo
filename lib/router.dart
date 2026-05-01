
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/age_verification_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/customer/customer_shell.dart';
import 'screens/provider/provider_shell.dart';

GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    refreshListenable: auth,
    initialLocation: '/age',
    redirect: (context, state) {
      if (!auth.ageConfirmed) return '/age';
      if (auth.status == AuthStatus.loading) return null;
      final loggedIn = auth.status == AuthStatus.authenticated;
      final loc = state.uri.path;
      final onAuth = loc == '/login' || loc == '/register';
      if (!loggedIn && !onAuth && loc != '/age') return '/login';
      if (loggedIn && onAuth) return auth.isProvider ? '/provider' : '/customer';
      return null;
    },
    routes: [
      GoRoute(path: '/age', builder: (c, s) => const AgeVerificationScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      ShellRoute(
        builder: (c, s, child) => CustomerShell(child: child),
        routes: [
          GoRoute(path: '/customer', builder: (c, s) => const _Empty()),
          GoRoute(path: '/customer/explore', builder: (c, s) => const _Empty()),
          GoRoute(path: '/customer/saved', builder: (c, s) => const _Empty()),
          GoRoute(path: '/customer/bookings', builder: (c, s) => const _Empty()),
          GoRoute(path: '/customer/chats', builder: (c, s) => const _Empty()),
          GoRoute(path: '/customer/me', builder: (c, s) => const _Empty()),
        ],
      ),
      ShellRoute(
        builder: (c, s, child) => ProviderShell(child: child),
        routes: [
          GoRoute(path: '/provider', builder: (c, s) => const _Empty()),
          GoRoute(path: '/provider/bookings', builder: (c, s) => const _Empty()),
          GoRoute(path: '/provider/chats', builder: (c, s) => const _Empty()),
          GoRoute(path: '/provider/plan', builder: (c, s) => const _Empty()),
          GoRoute(path: '/provider/me', builder: (c, s) => const _Empty()),
        ],
      ),
    ],
  );
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override Widget build(BuildContext context) => const SizedBox.shrink();
}
