import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/cubit/app_cubit.dart';
import 'package:smart_bike_guard/core/cubit/app_state.dart';
import 'package:smart_bike_guard/features/alarm/presentation/cubit/alarm_state.dart';
import 'package:smart_bike_guard/features/profile/data/services/local_storage_service.dart';

class AlarmCubit extends Cubit<AlarmState> {
  final LocalStorageService localStorage;
  final AppCubit appCubit;

  AlarmCubit({required this.localStorage, required this.appCubit})
    : super(AlarmState.initial());

  void handleCommand(String input, double sensitivity) {
    final command = input.trim();
    if (command == 'ARM') {
      emit(
        state.copyWith(
          isArmed: true,
          hasAlarmTriggered: false,
          statusMessage: '🟢 Охорона увімкнена. Система готова.',
        ),
      );
    } else if (command == 'DISARM') {
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

    final newCount = currentApp.data.alertCount + 1;
    await localStorage.saveAlertCount(newCount);

    appCubit.updateData(currentApp.data.copyWith(alertCount: newCount));

    emit(
      state.copyWith(
        hasAlarmTriggered: true,
        statusMessage: '🚨 ТРИВОГА! $reason',
      ),
    );
  }
}
