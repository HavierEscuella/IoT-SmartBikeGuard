import 'package:flutter/material.dart';

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
      home: const AlarmKeychainScreen(),
    );
  }
}

class AlarmKeychainScreen extends StatefulWidget {
  const AlarmKeychainScreen({super.key});

  @override
  State<AlarmKeychainScreen> createState() => _AlarmKeychainScreenState();
}

class _AlarmKeychainScreenState extends State<AlarmKeychainScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _isArmed = false;
  bool _hasAlarmTriggered = false;
  int _alertCount = 0;
  String _statusMessage = 'Система готова. Очікування команди...';

  void _processCommand(String text) {
    final cleanText = text.trim().toUpperCase();

    setState(() {
      if (cleanText == '1234' || cleanText == 'ARM') {
        _isArmed = true;
        _hasAlarmTriggered = false;
        _statusMessage =
            '🛡️ ОХОРОНА АКТИВОВАНА. Велосипед під захистом.';
      } else if (cleanText == 'DISARM') {
        _isArmed = false;
        _hasAlarmTriggered = false;
        _statusMessage = '🔓 ЗНЯТО З ОХОРОНИ. Вільний рух дозволено.';
      } else if (cleanText == 'SOS' || cleanText == 'AVADA KEDAVRA') {
        _isArmed = false;
        _hasAlarmTriggered = false;
        _alertCount = 0;
        _statusMessage =
            '⚡ Систему перезавантажено (Екстрене скидання).';
      } else {
        final parsedValue = int.tryParse(cleanText);
        if (parsedValue != null) {
          if (_isArmed) {
            _hasAlarmTriggered = true;
            _alertCount += parsedValue;
            _statusMessage =
                '🚨 ТРИВОГА! Рух силою $parsedValue G!';
          } else {
            _statusMessage =
                'ℹ️ Поштовх $parsedValue G (Охорона вимкнена).';
          }
        } else {
          _statusMessage =
              '❌ Невідома команда. Дозволені: ARM, DISARM, SOS або Число.';
        }
      }
    });
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
                  const Text(
                    'IoT Bike Guard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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
                    width: 200,
                    height: 200,
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
                        size: 80,
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Тривог зафіксовано: $_alertCount',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
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
                        fontSize: 14,
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
