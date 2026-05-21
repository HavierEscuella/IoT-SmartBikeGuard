import 'package:flutter/material.dart';

class OwnerSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const OwnerSection({
    required this.nameController,
    required this.phoneController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👤 Дані власника',
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
            labelText: 'Повне ім\'я',
            prefixIcon: Icon(Icons.person, color: Color(0xFF00E676)),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Введіть ім\'я' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phoneController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Номер телефону',
            prefixIcon: Icon(Icons.phone, color: Color(0xFF00E676)),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Введіть номер' : null,
        ),
      ],
    );
  }
}
