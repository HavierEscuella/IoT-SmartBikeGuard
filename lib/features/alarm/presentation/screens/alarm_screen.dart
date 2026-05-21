import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/cubit/app_cubit.dart';
import 'package:smart_bike_guard/core/cubit/app_state.dart';
import 'package:smart_bike_guard/features/alarm/presentation/cubit/alarm_cubit.dart';
import 'package:smart_bike_guard/features/alarm/presentation/cubit/alarm_state.dart';
import 'package:smart_bike_guard/features/alarm/presentation/widgets/alarm_indicator.dart';
import 'package:smart_bike_guard/features/alarm/presentation/widgets/command_input.dart';
import 'package:smart_bike_guard/features/alarm/presentation/widgets/status_header.dart';
import 'package:smart_bike_guard/features/profile/data/services/local_storage_service.dart';
import 'package:smart_bike_guard/features/profile/presentation/screens/profile_settings_screen.dart';

class AlarmKeychainScreen extends StatelessWidget {
  const AlarmKeychainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlarmCubit(
        localStorage: context.read<LocalStorageService>(),
        appCubit: context.read<AppCubit>(),
      ),
      child: BlocListener<AppCubit, AppState>(
        listener: (context, appState) {
          if (appState is AppLoaded && appState.data.isOfflineMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ℹ️ Працюємо в офлайн-режимі.'),
                backgroundColor: Colors.blueGrey,
              ),
            );
          }
        },
        child: const _AlarmView(),
      ),
    );
  }
}

class _AlarmView extends StatelessWidget {
  const _AlarmView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        if (appState is! AppLoaded) return const SizedBox.shrink();
        final data = appState.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Smart Guard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (data.isOfflineMode)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.cloud_off, color: Colors.orangeAccent),
                ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfileSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  StatusHeader(ownerName: data.ownerName),
                  const Spacer(),
                  BlocBuilder<AlarmCubit, AlarmState>(
                    builder: (context, alarmState) {
                      return AlarmIndicator(
                        hasAlarmTriggered: alarmState.hasAlarmTriggered,
                        isArmed: alarmState.isArmed,
                        bikeType: data.bikeType,
                        sensitivity: data.sensitivity,
                        alertCount: data.alertCount,
                      );
                    },
                  ),
                  const Spacer(),
                  BlocBuilder<AlarmCubit, AlarmState>(
                    builder: (context, alarmState) {
                      return CommandInput(
                        statusMessage: alarmState.statusMessage,
                        onCommandSubmitted: (cmd) => context
                            .read<AlarmCubit>()
                            .handleCommand(cmd, data.sensitivity),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
