import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/cubit/app_cubit.dart';
import 'package:smart_bike_guard/core/routing/app_router.dart';
import 'package:smart_bike_guard/core/theme/app_theme.dart';
import 'package:smart_bike_guard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_bike_guard/features/profile/data/services/bike_api_service.dart';
import 'package:smart_bike_guard/features/profile/data/services/local_storage_service.dart';

void main() {
  runApp(const SmartBikeGuardApp());
}

class SmartBikeGuardApp extends StatelessWidget {
  const SmartBikeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => BikeApiService()),
        RepositoryProvider(create: (_) => LocalStorageService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppCubit(
              apiService: context.read<BikeApiService>(),
              localStorage: context.read<LocalStorageService>(),
            )..loadInitialData(),
          ),
          BlocProvider(create: (_) => AuthCubit()),
        ],
        child: MaterialApp(
          title: 'Smart Bike Guard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const AppRouter(),
        ),
      ),
    );
  }
}
