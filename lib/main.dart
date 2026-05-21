import 'package:flutter/material.dart';
import 'package:smart_bike_guard/core/routing/app_router.dart';
import 'package:smart_bike_guard/core/theme/app_theme.dart';

void main() {
  runApp(const SmartBikeGuardApp());
}

class SmartBikeGuardApp extends StatelessWidget {
  const SmartBikeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Bike Guard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppRouter(),
    );
  }
}
