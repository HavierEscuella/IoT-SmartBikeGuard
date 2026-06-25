import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_flashlight/smart_bike_flashlight.dart';
import 'package:smart_bike_guard/core/cubit/app_cubit.dart';
import 'package:smart_bike_guard/core/cubit/app_state.dart';
import 'package:smart_bike_guard/core/services/notification_service.dart';
import 'package:smart_bike_guard/features/alarm/presentation/cubit/alarm_state.dart';

class AlarmCubit extends Cubit<AlarmState> {
  final AppCubit appCubit;
  Timer? _flashlightTimer;
  bool _isFlashlightOn = false;

  AlarmCubit({required this.appCubit})
    : super(AlarmState.initial());

  void handleCommand(String input, double sensitivity) {
    final command = input.trim();
    if (command == 'ARM') {
      _stopFlashlightBlinking();
      emit(
        state.copyWith(
          isArmed: true,
          hasAlarmTriggered: false,
          statusMessage: '🟢 Охорона увімкнена. Система готова.',
        ),
      );
    } else if (command == 'DISARM') {
      _stopFlashlightBlinking();
      emit(
        state.copyWith(
          isArmed: false,
          hasAlarmTriggered: false,
          statusMessage: '🔘 Охорона вимкнена. Можна їхати.',
        ),
      );
    } else if (command == 'SOS') {
      triggerAlarm('Викликано SOS!');
    } else {
      final gForce = double.tryParse(command);
      if (gForce != null) {
        if (state.isArmed && gForce >= sensitivity) {
          triggerAlarm('Сильний удар: ${gForce}G!');
        } else {
          emit(
            state.copyWith(
              statusMessage: state.isArmed
                  ? 'Легкий поштовх ${gForce}G.'
                  : 'Удар ${gForce}G. Охорона вимкнена.',
            ),
          );
        }
      } else {
        emit(state.copyWith(statusMessage: '❌ Невідома команда: $command'));
      }
    }
  }

  Future<void> triggerAlarm(String reason) async {
    final currentApp = appCubit.state;
    if (currentApp is! AppLoaded) return;

    await appCubit.incrementAlertCount();

    HapticFeedback.vibrate();
    NotificationService().showAlarmNotification(reason);
    _startFlashlightBlinking();

    emit(
      state.copyWith(
        hasAlarmTriggered: true,
        statusMessage: '🚨 ТРИВОГА! $reason',
      ),
    );
  }

  void _startFlashlightBlinking() {
    _flashlightTimer?.cancel();
    _isFlashlightOn = true;
    try { SmartBikeFlashlight.toggleTorch(_isFlashlightOn); } catch (_) {}
    
    _flashlightTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      _isFlashlightOn = !_isFlashlightOn;
      try { SmartBikeFlashlight.toggleTorch(_isFlashlightOn); } catch (_) {}
    });
  }

  void _stopFlashlightBlinking() {
    _flashlightTimer?.cancel();
    _flashlightTimer = null;
    _isFlashlightOn = false;
    try { SmartBikeFlashlight.toggleTorch(false); } catch (_) {}
  }

  @override
  Future<void> close() {
    _stopFlashlightBlinking();
    return super.close();
  }
}
