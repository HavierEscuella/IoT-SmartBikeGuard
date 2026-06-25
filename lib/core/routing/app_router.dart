import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_bike_guard/core/cubit/app_cubit.dart';
import 'package:smart_bike_guard/core/cubit/app_state.dart';
import 'package:smart_bike_guard/features/alarm/presentation/screens/alarm_screen.dart';
import 'package:smart_bike_guard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_bike_guard/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_bike_guard/features/profile/presentation/screens/profile_settings_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final isLoggedIn = authCubit.state;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          onLoginSuccess: () => context.read<AuthCubit>().login(),
        ),
      ),
      GoRoute(path: '/', builder: (context, state) => const RootScreen()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
    ],
  );
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        if (state is AppLoading || state is AppInitial) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF00E676)),
                  SizedBox(height: 16),
                  Text(
                    'Завантаження конфігурації...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AppError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_outlined,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Помилка: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<AppCubit>().loadInitialData(),
                    child: const Text('Спробувати знову'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AppLoaded) {
          return const AlarmKeychainScreen();
        }

        return const SizedBox.shrink();
      },
    );
  }
}
