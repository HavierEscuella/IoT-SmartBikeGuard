import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/cubit/app_cubit.dart';
import 'package:smart_bike_guard/core/routing/app_router.dart';
import 'package:smart_bike_guard/core/services/notification_service.dart';
import 'package:smart_bike_guard/core/theme/app_theme.dart';
import 'package:smart_bike_guard/features/auth/data/services/firebase_auth_service.dart';
import 'package:smart_bike_guard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_bike_guard/features/profile/data/services/firebase_firestore_service.dart';
import 'package:smart_bike_guard/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const SmartBikeGuardApp());
}

class SmartBikeGuardApp extends StatelessWidget {
  const SmartBikeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => FirebaseAuthService()),
        RepositoryProvider(create: (_) => FirebaseFirestoreService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(authService: context.read<FirebaseAuthService>()),
          ),
          BlocProvider(
            create: (context) => AppCubit(
              firestoreService: context.read<FirebaseFirestoreService>(),
              authService: context.read<FirebaseAuthService>(),
            )..loadInitialData(),
          ),
        ],
        child: Builder(
          builder: (context) {
            final router = createRouter(context.read<AuthCubit>());
            return MaterialApp.router(
              title: 'Smart Bike Guard',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
