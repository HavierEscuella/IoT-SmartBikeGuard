import 'package:equatable/equatable.dart';

class AlarmState extends Equatable {
  final bool isArmed;
  final bool hasAlarmTriggered;
  final String statusMessage;

  const AlarmState({
    required this.isArmed,
    required this.hasAlarmTriggered,
    required this.statusMessage,
  });

  factory AlarmState.initial() {
    return const AlarmState(
      isArmed: true,
      hasAlarmTriggered: false,
      statusMessage: '🟢 Охорона увімкнена. Усе спокійно.',
    );
  }

  AlarmState copyWith({
    bool? isArmed,
    bool? hasAlarmTriggered,
    String? statusMessage,
  }) {
    return AlarmState(
      isArmed: isArmed ?? this.isArmed,
      hasAlarmTriggered: hasAlarmTriggered ?? this.hasAlarmTriggered,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [isArmed, hasAlarmTriggered, statusMessage];
}
