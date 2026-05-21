import 'package:flutter/material.dart';
import 'package:smart_bike_guard/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_bike_guard/features/profile/data/services/bike_api_service.dart';
import 'package:smart_bike_guard/features/profile/presentation/screens/profile_settings_screen.dart';

void main() {
  runApp(const SmartBikeGuardApp());
}

class SmartBikeGuardApp extends StatelessWidget {
  const SmartBikeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Bike Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111217),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFFFF1744),
          surface: Color(0xFF1E202C),
        ),
      ),
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  final BikeApiService _apiService = BikeApiService();
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String _errorMessage = '';

  // Стан пристрою та власника з REST API
  String _ownerName = '';
  String _ownerPhone = '';
  String _bikeName = '';
  String _bikeType = '';
  String _serialNumber = '';
  double _sensitivity = 0.5;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _apiService.fetchBikeData();
      setState(() {
        _ownerName = data['ownerName'] as String? ?? 'Власник';
        _ownerPhone = data['ownerPhone'] as String? ?? '';
        _bikeName = data['bikeName'] as String? ?? 'Байк';
        _bikeType = data['bikeType'] as String? ?? 'Велосипед';
        _serialNumber = data['serialNumber'] as String? ?? '';
        _sensitivity = (data['sensitivity'] as num? ?? 0.5).toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  Future<void> _handleSettingsSave(
    String name,
    String phone,
    String bikeName,
    String bikeType,
    String serial,
    double sensitivity,
  ) async {
    final updatedData = {
      'ownerName': name,
      'ownerPhone': phone,
      'bikeName': bikeName,
      'bikeType': bikeType,
      'serialNumber': serial,
      'sensitivity': sensitivity,
    };

    try {
      final success = await _apiService.updateBikeData(updatedData);
      if (success) {
        setState(() {
          _ownerName = name;
          _ownerPhone = phone;
          _bikeName = bikeName;
          _bikeType = bikeType;
          _serialNumber = serial;
          _sensitivity = sensitivity;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Помилка синхронізації: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF00E676),
              ),
              SizedBox(height: 16),
              Text(
                'Завантаження даних з сервера...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_outlined,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadInitialData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Спробувати знову'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isLoggedIn) {
      return LoginScreen(onLoginSuccess: _handleLoginSuccess);
    }

    return AlarmKeychainScreen(
      ownerName: _ownerName,
      ownerPhone: _ownerPhone,
      bikeName: _bikeName,
      bikeType: _bikeType,
      serialNumber: _serialNumber,
      sensitivity: _sensitivity,
      onSaveSettings: _handleSettingsSave,
      apiService: _apiService,
    );
  }
}

class AlarmKeychainScreen extends StatefulWidget {
  final String ownerName;
  final String ownerPhone;
  final String bikeName;
  final String bikeType;
  final String serialNumber;
  final double sensitivity;
  final void Function(
    String name,
    String phone,
    String bikeName,
    String bikeType,
    String serial,
    double sensitivity,
  ) onSaveSettings;
  final BikeApiService apiService;

  const AlarmKeychainScreen({
    required this.ownerName,
    required this.ownerPhone,
    required this.bikeName,
    required this.bikeType,
    required this.serialNumber,
    required this.sensitivity,
    required this.onSaveSettings,
    required this.apiService,
    super.key,
  });

  @override
  State<AlarmKeychainScreen> createState() => _AlarmKeychainScreenState();
}

class _AlarmKeychainScreenState extends State<AlarmKeychainScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _isArmed = false;
  bool _hasAlarmTriggered = false;
  int _alertCount = 0;
  String _statusMessage = 'Система готова. Очікування команди...';

  void _processCommand(String text) async {
    final cleanText = text.trim().toUpperCase();

    if (cleanText == '1234' || cleanText == 'ARM') {
      setState(() {
        _isArmed = true;
        _hasAlarmTriggered = false;
        _statusMessage =
            '🛡️ ОХОРОНА АКТИВОВАНА. Велосипед під захистом.';
      });
    } else if (cleanText == 'DISARM') {
      setState(() {
        _isArmed = false;
        _hasAlarmTriggered = false;
        _statusMessage = '🔓 ЗНЯТО З ОХОРОНИ. Вільний рух дозволено.';
      });
    } else if (cleanText == 'SOS' || cleanText == 'AVADA KEDAVRA') {
      setState(() {
        _isArmed = false;
        _hasAlarmTriggered = false;
        _alertCount = 0;
        _statusMessage =
            '⚡ Систему перезавантажено (Екстрене скидання).';
      });
    } else {
      final parsedValue = int.tryParse(cleanText);
      if (parsedValue != null) {
        if (_isArmed) {
          setState(() {
            _hasAlarmTriggered = true;
            _alertCount += parsedValue;
            _statusMessage =
                '🚨 ТРИВОГА! Рух силою $parsedValue G. Надіслано SOS...';
          });

          // Асинхронно повідомляємо REST API сервер про спрацювання тривоги
          try {
            final ok = await widget.apiService.reportSosAlarm(parsedValue);
            if (ok && mounted) {
              setState(() {
                _statusMessage = '🚨 ТРИВОГА! Рух силою $parsedValue G!\n'
                    '📲 REST API: Сигнал SOS успішно доставлено!';
              });
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _statusMessage = '🚨 ТРИВОГА! Рух силою $parsedValue G!\n'
                    '⚠️ REST API: Помилка передачі сигналу тривоги!';
              });
            }
          }
        } else {
          setState(() {
            _statusMessage =
                'ℹ️ Поштовх $parsedValue G (Охорона вимкнена).';
          });
        }
      } else {
        setState(() {
          _statusMessage =
              '❌ Невідома команда. Дозволені: ARM, DISARM, SOS або Число.';
        });
      }
    }
    _codeController.clear();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = const Color(0xFF00E676);
    if (_hasAlarmTriggered) {
      activeColor = const Color(0xFFFF1744);
    } else if (!_isArmed) {
      activeColor = Colors.blueGrey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bikeName),
        backgroundColor: const Color(0xFF1E202C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => ProfileSettingsScreen(
                    currentName: widget.ownerName,
                    currentPhone: widget.ownerPhone,
                    currentBikeName: widget.bikeName,
                    currentBikeType: widget.bikeType,
                    currentSerial: widget.serialNumber,
                    currentSensitivity: widget.sensitivity,
                    onSave: widget.onSaveSettings,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Власник: ${widget.ownerName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E202C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.battery_5_bar,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '84%',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
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
                      border: Border.all(
                        color: activeColor,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _hasAlarmTriggered
                            ? Icons.gpp_bad
                            : (_isArmed
                                ? Icons.shield
                                : Icons.shield_outlined),
                        size: 70,
                        color: activeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _hasAlarmTriggered
                        ? '🔥 УВАГА: ВИКРАДЕННЯ!'
                        : (_isArmed ? 'РЕЖИМ ОХОРОНИ' : 'БЕЗПЕЧНИЙ РЕЖИМ'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Тип: ${widget.bikeType} | Чутливість: '
                    '${(widget.sensitivity * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Тривог зафіксовано: $_alertCount',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E202C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      hintText: 'Команда: ARM / DISARM / SOS або Число',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A1B23),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF00E676),
                        ),
                        onPressed: () => _processCommand(
                          _codeController.text,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _processCommand,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '💡 Введіть число для імітації сили удару (G) по рамі.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
