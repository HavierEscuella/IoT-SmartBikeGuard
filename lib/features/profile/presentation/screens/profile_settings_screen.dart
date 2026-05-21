import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/cubit/app_cubit.dart';
import 'package:smart_bike_guard/core/cubit/app_state.dart';
import 'package:smart_bike_guard/features/profile/data/services/bike_api_service.dart';
import 'package:smart_bike_guard/features/profile/data/services/local_storage_service.dart';
import 'package:smart_bike_guard/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:smart_bike_guard/features/profile/presentation/cubit/profile_state.dart';
import 'package:smart_bike_guard/features/profile/presentation/widgets/profile_form.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        apiService: context.read<BikeApiService>(),
        localStorage: context.read<LocalStorageService>(),
        appCubit: context.read<AppCubit>(),
      ),
      child: const _ProfileSettingsView(),
    );
  }
}

class _ProfileSettingsView extends StatefulWidget {
  const _ProfileSettingsView();

  @override
  State<_ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<_ProfileSettingsView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _ownerNameCtrl;
  late TextEditingController _ownerPhoneCtrl;
  late TextEditingController _bikeNameCtrl;
  late TextEditingController _bikeTypeCtrl;
  late TextEditingController _serialCtrl;
  late double _sensitivity;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppCubit>().state;
    if (appState is AppLoaded) {
      final data = appState.data;
      _ownerNameCtrl = TextEditingController(text: data.ownerName);
      _ownerPhoneCtrl = TextEditingController(text: data.ownerPhone);
      _bikeNameCtrl = TextEditingController(text: data.bikeName);
      _bikeTypeCtrl = TextEditingController(text: data.bikeType);
      _serialCtrl = TextEditingController(text: data.serialNumber);
      _sensitivity = data.sensitivity;
    } else {
      _ownerNameCtrl = TextEditingController();
      _ownerPhoneCtrl = TextEditingController();
      _bikeNameCtrl = TextEditingController();
      _bikeTypeCtrl = TextEditingController();
      _serialCtrl = TextEditingController();
      _sensitivity = 0.5;
    }
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

  void _onSave(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppCubit>().state;
    if (appState is! AppLoaded) return;

    final updatedData = appState.data.copyWith(
      ownerName: _ownerNameCtrl.text,
      ownerPhone: _ownerPhoneCtrl.text,
      bikeName: _bikeNameCtrl.text,
      bikeType: _bikeTypeCtrl.text,
      serialNumber: _serialCtrl.text,
      sensitivity: _sensitivity,
    );

    context.read<ProfileCubit>().saveSettings(updatedData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isOffline
                    ? '⚠️ Локальне збереження.'
                    : '🛡️ Успішно збережено!',
              ),
              backgroundColor: state.isOffline
                  ? Colors.orangeAccent
                  : const Color(0xFF00E676),
            ),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Налаштування профілю'),
          backgroundColor: const Color(0xFF1E202C),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              return ProfileForm(
                formKey: _formKey,
                ownerNameCtrl: _ownerNameCtrl,
                ownerPhoneCtrl: _ownerPhoneCtrl,
                bikeNameCtrl: _bikeNameCtrl,
                bikeTypeCtrl: _bikeTypeCtrl,
                serialCtrl: _serialCtrl,
                sensitivity: _sensitivity,
                onSensitivityChanged: (val) =>
                    setState(() => _sensitivity = val),
                isSaving: state is ProfileSaving,
                onSave: () => _onSave(context),
              );
            },
          ),
        ),
      ),
    );
  }
}
