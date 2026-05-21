import 'package:flutter/material.dart';

class AlarmIndicator extends StatelessWidget {
  final bool hasAlarmTriggered;
  final bool isArmed;
  final String bikeType;
  final double sensitivity;
  final int alertCount;

  const AlarmIndicator({
    required this.hasAlarmTriggered,
    required this.isArmed,
    required this.bikeType,
    required this.sensitivity,
    required this.alertCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor = const Color(0xFF00E676);
    if (hasAlarmTriggered) {
      activeColor = const Color(0xFFFF1744);
    } else if (!isArmed) {
      activeColor = Colors.blueGrey;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E202C),
            boxShadow: [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(color: activeColor, width: 4),
          ),
          child: Center(
            child: Icon(
              hasAlarmTriggered
                  ? Icons.gpp_bad
                  : (isArmed ? Icons.shield : Icons.shield_outlined),
              size: 70,
              color: activeColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          hasAlarmTriggered
              ? '🔥 УВАГА: ВИКРАДЕННЯ!'
              : (isArmed ? 'РЕЖИМ ОХОРОНИ' : 'БЕЗПЕЧНИЙ РЕЖИМ'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: activeColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Тип: $bikeType | Чутливість: ${(sensitivity * 100).toInt()}%',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          'Тривог зафіксовано: $alertCount',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}
