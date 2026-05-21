import 'package:flutter/material.dart';
import 'package:smart_bike_guard/core/models/bike_data.dart';
import 'package:smart_bike_guard/features/profile/data/services/bike_api_service.dart';
import 'package:smart_bike_guard/features/profile/data/services/local_storage_service.dart';
import 'package:smart_bike_guard/features/profile/presentation/widgets/profile_form.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final BikeData currentData;
  final BikeApiService apiService;
  final LocalStorageService localStorage;

  const ProfileSettingsScreen({
    required this.currentData,
    required this.apiService,
    required this.localStorage,
    super.key,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _ownerNameCtrl;
  late TextEditingController _ownerPhoneCtrl;
  late TextEditingController _bikeNameCtrl;
  late TextEditingController _bikeTypeCtrl;
  late TextEditingController _serialCtrl;
  late double _sensitivity;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ownerNameCtrl = TextEditingController(text: widget.currentData.ownerName);
    _ownerPhoneCtrl = TextEditingController(
      text: widget.currentData.ownerPhone,
    );
    _bikeNameCtrl = TextEditingController(text: widget.currentData.bikeName);
    _bikeTypeCtrl = TextEditingController(text: widget.currentData.bikeType);
    _serialCtrl = TextEditingController(text: widget.currentData.serialNumber);
    _sensitivity = widget.currentData.sensitivity;
  }

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _bikeNameCtrl.dispose();
    _bikeTypeCtrl.dispose();
    _serialCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updatedData = widget.currentData.copyWith(
      ownerName: _ownerNameCtrl.text,
      ownerPhone: _ownerPhoneCtrl.text,
      bikeName: _bikeNameCtrl.text,
      bikeType: _bikeTypeCtrl.text,
      serialNumber: _serialCtrl.text,
      sensitivity: _sensitivity,
    );

    final mapData = {
      'ownerName': updatedData.ownerName,
      'ownerPhone': updatedData.ownerPhone,
      'bikeName': updatedData.bikeName,
      'bikeType': updatedData.bikeType,
      'serialNumber': updatedData.serialNumber,
      'sensitivity': updatedData.sensitivity,
    };

    try {
      await widget.localStorage.saveBikeData(mapData);
    } catch (_) {}

    try {
      await widget.apiService.updateBikeData(mapData);
      if (mounted) {
        _showSnackBar('🛡️ Успішно збережено!', const Color(0xFF00E676));
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('⚠️ Локальне збереження.', Colors.orangeAccent);
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, updatedData);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Налаштування профілю'),
        backgroundColor: const Color(0xFF1E202C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProfileForm(
          formKey: _formKey,
          ownerNameCtrl: _ownerNameCtrl,
          ownerPhoneCtrl: _ownerPhoneCtrl,
          bikeNameCtrl: _bikeNameCtrl,
          bikeTypeCtrl: _bikeTypeCtrl,
          serialCtrl: _serialCtrl,
          sensitivity: _sensitivity,
          onSensitivityChanged: (val) => setState(() => _sensitivity = val),
          isSaving: _isSaving,
          onSave: _saveSettings,
        ),
      ),
    );
  }
}
