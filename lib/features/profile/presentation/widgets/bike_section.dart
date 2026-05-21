import 'package:flutter/material.dart';

class BikeSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController typeController;
  final TextEditingController serialController;

  const BikeSection({
    required this.nameController,
    required this.typeController,
    required this.serialController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚲 Дані транспорту',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Назва байка',
            prefixIcon: Icon(Icons.pedal_bike, color: Color(0xFF00E676)),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Введіть назву' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: typeController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Тип (електросамокат, велосипед)',
            prefixIcon: Icon(Icons.electric_scooter, color: Color(0xFF00E676)),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Введіть тип' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: serialController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Серійний номер / MAC IoT',
            prefixIcon: Icon(Icons.qr_code, color: Color(0xFF00E676)),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Введіть серійний номер' : null,
        ),
      ],
    );
  }
}
