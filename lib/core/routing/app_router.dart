import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/cubit/app_cubit.dart';
import 'package:smart_bike_guard/core/cubit/app_state.dart';
import 'package:smart_bike_guard/features/alarm/presentation/screens/alarm_screen.dart';
import 'package:smart_bike_guard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_bike_guard/features/auth/presentation/screens/login_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, bool>(
      builder: (context, isLoggedIn) {
        if (!isLoggedIn) {
          return LoginScreen(
            onLoginSuccess: () => context.read<AuthCubit>().login(),
          );
        }

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
                        onPressed: () =>
                            context.read<AppCubit>().loadInitialData(),
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
      },
    );
  }
}
