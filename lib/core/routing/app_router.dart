import 'package:flutter/material.dart';
import 'package:smart_bike_guard/core/models/bike_data.dart';
import 'package:smart_bike_guard/features/alarm/presentation/screens/alarm_screen.dart';
import 'package:smart_bike_guard/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_bike_guard/features/profile/data/services/bike_api_service.dart';
import 'package:smart_bike_guard/features/profile/data/services/local_storage_service.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  final BikeApiService _apiService = BikeApiService();
  final LocalStorageService _localStorage = LocalStorageService();

  late Future<BikeData> _dataFuture;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadInitialData();
  }

  Future<BikeData> _loadInitialData() async {
    int alertCount = 0;
    try {
      alertCount = await _localStorage.getAlertCount();
    } catch (_) {}

    try {
      final cached = await _localStorage.getBikeData();
      if (cached != null) {
        _apiService
            .fetchBikeData()
            .then(_localStorage.saveBikeData)
            .catchError((_) {});

        return BikeData(
          ownerName: cached['ownerName'] as String,
          ownerPhone: cached['ownerPhone'] as String,
          bikeName: cached['bikeName'] as String,
          bikeType: cached['bikeType'] as String,
          serialNumber: cached['serialNumber'] as String,
          sensitivity: cached['sensitivity'] as double,
          alertCount: alertCount,
          isOfflineMode: true,
        );
      }
    } catch (_) {}

    final serverData = await _apiService.fetchBikeData();
    await _localStorage.saveBikeData(serverData);

    return BikeData(
      ownerName: serverData['ownerName'] as String? ?? 'Власник',
      ownerPhone: serverData['ownerPhone'] as String? ?? '',
      bikeName: serverData['bikeName'] as String? ?? 'Байк',
      bikeType: serverData['bikeType'] as String? ?? 'Велосипед',
      serialNumber: serverData['serialNumber'] as String? ?? '',
      sensitivity: (serverData['sensitivity'] as num? ?? 0.5).toDouble(),
      alertCount: alertCount,
      isOfflineMode: false,
    );
  }

  void _retry() {
    setState(() {
      _dataFuture = _loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: () {
          setState(() => _isLoggedIn = true);
        },
      );
    }

    return FutureBuilder<BikeData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF00E676)),
                  SizedBox(height: 16),
                  Text(
                    'Завантаження конфігурації...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
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
                    'Помилка: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Спробувати знову'),
                  ),
                ],
              ),
            ),
          );
        }

        return AlarmKeychainScreen(
          initialData: snapshot.data!,
          apiService: _apiService,
          localStorage: _localStorage,
        );
      },
    );
  }
}
