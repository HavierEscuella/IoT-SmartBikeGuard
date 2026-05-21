import 'package:flutter/material.dart';

class SensitivitySlider extends StatelessWidget {
  final double sensitivity;
  final void Function(double) onChanged;

  const SensitivitySlider({
    required this.sensitivity,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎛️ Чутливість сигналізації',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Поточна: ${(sensitivity * 100).toInt()}% '
          '(Удар ${sensitivity.toStringAsFixed(1)}G)',
          style: const TextStyle(color: Colors.grey),
        ),
        Slider(
          value: sensitivity,
          min: 0.1,
          max: 2,
          divisions: 19,
          activeColor: const Color(0xFF00E676),
          inactiveColor: const Color(0xFF1E202C),
          label: '${sensitivity.toStringAsFixed(1)}G',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
