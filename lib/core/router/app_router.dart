import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_admin/core/data/feature_data_layers.dart';
import 'package:gym_admin/core/di/injection_container.dart';
import 'package:gym_admin/core/layout/admin_shell.dart';
import 'package:gym_admin/core/screens/feature_screens.dart';
import 'package:gym_admin/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gym_admin/features/auth/presentation/screens/login_screen.dart';
import 'package:gym_admin/features/plans/presentation/plans_presentation.dart';
import 'package:gym_admin/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_admin/features/users/presentation/screens/users_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: _AuthListenable(authCubit),
    redirect: (context, state) {
      final isAuthenticated = authCubit.state is AuthAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginRoute) return '/login';
      if (isAuthenticated && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      // ── Login ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LoginScreen(),
      ),

      // ── Admin shell with sidebar ───────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          // Dashboard / Analytics
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<AnalyticsCubit>(),
              child: const AnalyticsScreen(),
            ),
          ),
          // Users
          GoRoute(
            path: '/users',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<UsersCubit>(),
              child: const UsersScreen(),
            ),
          ),
          // Plans
          GoRoute(
            path: '/plans',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<PlansCubit>(),
              child: const PlansScreen(),
            ),
          ),
          // Subscriptions
          GoRoute(
            path: '/subscriptions',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<SubscriptionsCubit>(),
              child: const SubscriptionsScreen(),
            ),
          ),
          // Workouts
          GoRoute(
            path: '/workouts',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<WorkoutsCubit>(),
              child: const WorkoutsScreen(),
            ),
          ),
          // Attendance
          GoRoute(
            path: '/attendance',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<AttendanceCubit>(),
              child: const AttendanceScreen(),
            ),
          ),
          // Messages
          GoRoute(
            path: '/messages',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<MessagingCubit>(),
              child: const MessagingScreen(),
            ),
          ),
          // Analytics standalone
          GoRoute(
            path: '/analytics',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<AnalyticsCubit>(),
              child: const AnalyticsScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF4757)),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Notifies GoRouter when auth state changes so redirects fire automatically
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(AuthCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}
