import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentBikeName;
  final String currentBikeType;
  final String currentSerial;
  final double currentSensitivity;
  final void Function(
    String name,
    String phone,
    String bikeName,
    String bikeType,
    String serial,
    double sensitivity,
  ) onSave;

  const ProfileSettingsScreen({
    required this.currentName,
    required this.currentPhone,
    required this.currentBikeName,
    required this.currentBikeType,
    required this.currentSerial,
    required this.currentSensitivity,
    required this.onSave,
    super.key,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bikeNameController;
  late TextEditingController _serialController;
  late String _selectedType;
  late double _sensitivity;

  final List<String> _bikeTypes = [
    'Велосипед',
    'Електросамокат',
    'Електробайк',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _bikeNameController = TextEditingController(text: widget.currentBikeName);
    _serialController = TextEditingController(text: widget.currentSerial);
    _selectedType = widget.currentBikeType;
    _sensitivity = widget.currentSensitivity;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bikeNameController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _bikeNameController.text.trim(),
        _selectedType,
        _serialController.text.trim(),
        _sensitivity,
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🛡️ Налаштування пристрою та власника оновлено!'),
          backgroundColor: Color(0xFF00E676),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Налаштування Guard'),
        backgroundColor: const Color(0xFF1E202C),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Секція Власника
              const Text(
                '👤 ВЛАСНИК ТРАНСПОРТУ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E676),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Ім'я власника",
                  prefixIcon: Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Color(0xFF1E202C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Введіть ім'я";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Телефон для SOS-сповіщень',
                  prefixIcon: Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: Color(0xFF1E202C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть номер телефону';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Секція Велосипеда
              const Text(
                '🚲 РЕЄСТРАЦІЯ ТРАНСПОРТУ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E676),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bikeNameController,
                decoration: const InputDecoration(
                  labelText: 'Назва / Модель байка',
                  prefixIcon: Icon(Icons.pedal_bike_outlined),
                  filled: true,
                  fillColor: Color(0xFF1E202C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть назву';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Тип транспорту',
                  prefixIcon: Icon(Icons.merge_type_outlined),
                  filled: true,
                  fillColor: Color(0xFF1E202C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _bikeTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serialController,
                decoration: const InputDecoration(
                  labelText: 'Серійний номер рами',
                  prefixIcon: Icon(Icons.qr_code_scanner_outlined),
                  filled: true,
                  fillColor: Color(0xFF1E202C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть серійний номер';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Налаштування датчиків
              Text(
                '⚡ ЧУТЛИВІСТЬ АКСЕЛЕРОМЕТРА: '
                '${(_sensitivity * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E676),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _sensitivity,
                activeColor: const Color(0xFF00E676),
                inactiveColor: const Color(0xFF1E202C),
                onChanged: (value) {
                  setState(() {
                    _sensitivity = value;
                  });
                },
              ),
              const SizedBox(height: 48),

              // Кнопка збереження
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ЗБЕРЕГТИ НАЛАШТУВАННЯ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
