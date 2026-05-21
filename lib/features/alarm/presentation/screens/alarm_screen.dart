import 'package:flutter/material.dart';
import 'package:smart_bike_guard/core/models/bike_data.dart';
import 'package:smart_bike_guard/features/alarm/presentation/widgets/alarm_indicator.dart';
import 'package:smart_bike_guard/features/alarm/presentation/widgets/command_input.dart';
import 'package:smart_bike_guard/features/alarm/presentation/widgets/status_header.dart';
import 'package:smart_bike_guard/features/profile/data/services/bike_api_service.dart';
import 'package:smart_bike_guard/features/profile/data/services/local_storage_service.dart';
import 'package:smart_bike_guard/features/profile/presentation/screens/profile_settings_screen.dart';

class AlarmKeychainScreen extends StatefulWidget {
  final BikeData initialData;
  final BikeApiService apiService;
  final LocalStorageService localStorage;

  const AlarmKeychainScreen({
    required this.initialData,
    required this.apiService,
    required this.localStorage,
    super.key,
  });

  @override
  State<AlarmKeychainScreen> createState() => _AlarmKeychainScreenState();
}

class _AlarmKeychainScreenState extends State<AlarmKeychainScreen> {
  late BikeData _data;
  bool _isArmed = true;
  bool _hasAlarmTriggered = false;
  String _statusMessage = '🟢 Охорона увімкнена. Усе спокійно.';

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    if (_data.isOfflineMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ℹ️ Працюємо в офлайн-режимі.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      });
    }
  }

  void _handleCommand(String text) {
    final input = text.trim();
    if (input == 'ARM') {
      setState(() {
        _isArmed = true;
        _hasAlarmTriggered = false;
        _statusMessage = '🟢 Охорона увімкнена. Система готова.';
      });
    } else if (input == 'DISARM') {
      setState(() {
        _isArmed = false;
        _hasAlarmTriggered = false;
        _statusMessage = '🔘 Охорона вимкнена. Можна їхати.';
      });
    } else if (input == 'SOS') {
      _triggerAlarm('Викликано SOS!');
    } else {
      final gForce = double.tryParse(input);
      if (gForce != null) {
        if (_isArmed && gForce >= _data.sensitivity) {
          _triggerAlarm('Сильний удар: ${gForce}G!');
        } else {
          setState(
            () => _statusMessage = _isArmed
                ? 'Легкий поштовх ${gForce}G.'
                : 'Удар ${gForce}G. Охорона вимкнена.',
          );
        }
      } else {
        setState(() => _statusMessage = '❌ Невідома команда: $input');
      }
    }
  }

  Future<void> _triggerAlarm(String reason) async {
    final newCount = _data.alertCount + 1;
    await widget.localStorage.saveAlertCount(newCount);
    setState(() {
      _hasAlarmTriggered = true;
      _data = _data.copyWith(alertCount: newCount);
      _statusMessage = '🚨 ТРИВОГА! $reason';
    });
  }

  Future<void> _openSettings() async {
    final updatedData = await Navigator.push<BikeData>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSettingsScreen(
          currentData: _data,
          apiService: widget.apiService,
          localStorage: widget.localStorage,
        ),
      ),
    );

    if (updatedData != null) {
      setState(() {
        _data = updatedData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Guard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_data.isOfflineMode)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.cloud_off, color: Colors.orangeAccent),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              StatusHeader(ownerName: _data.ownerName),
              const Spacer(),
              AlarmIndicator(
                hasAlarmTriggered: _hasAlarmTriggered,
                isArmed: _isArmed,
                bikeType: _data.bikeType,
                sensitivity: _data.sensitivity,
                alertCount: _data.alertCount,
              ),
              const Spacer(),
              CommandInput(
                statusMessage: _statusMessage,
                onCommandSubmitted: _handleCommand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
