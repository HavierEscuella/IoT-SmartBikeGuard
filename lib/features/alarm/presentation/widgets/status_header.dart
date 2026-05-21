import 'package:flutter/material.dart';

class StatusHeader extends StatelessWidget {
  final String ownerName;

  const StatusHeader({required this.ownerName, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Власник: $ownerName',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E202C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.battery_5_bar, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text('84%', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
