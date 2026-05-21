import 'package:flutter/material.dart';
import 'package:smart_bike_guard/features/profile/presentation/widgets/bike_section.dart';
import 'package:smart_bike_guard/features/profile/presentation/widgets/owner_section.dart';
import 'package:smart_bike_guard/features/profile/presentation/widgets/sensitivity_slider.dart';

class ProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController ownerNameCtrl;
  final TextEditingController ownerPhoneCtrl;
  final TextEditingController bikeNameCtrl;
  final TextEditingController bikeTypeCtrl;
  final TextEditingController serialCtrl;
  final double sensitivity;
  final void Function(double) onSensitivityChanged;
  final bool isSaving;
  final VoidCallback onSave;

  const ProfileForm({
    required this.formKey,
    required this.ownerNameCtrl,
    required this.ownerPhoneCtrl,
    required this.bikeNameCtrl,
    required this.bikeTypeCtrl,
    required this.serialCtrl,
    required this.sensitivity,
    required this.onSensitivityChanged,
    required this.isSaving,
    required this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OwnerSection(
            nameController: ownerNameCtrl,
            phoneController: ownerPhoneCtrl,
          ),
          const SizedBox(height: 32),
          BikeSection(
            nameController: bikeNameCtrl,
            typeController: bikeTypeCtrl,
            serialController: serialCtrl,
          ),
          const SizedBox(height: 32),
          SensitivitySlider(
            sensitivity: sensitivity,
            onChanged: onSensitivityChanged,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF00E676),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'ЗБЕРЕГТИ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111217),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
