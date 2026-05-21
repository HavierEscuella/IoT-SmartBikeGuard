import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_bike_guard/core/network/api_config.dart';

class BikeApiService {
  final http.Client _client = http.Client();

  // Отримання конфігурації профілю та байка з сервера
  Future<Map<String, dynamic>> fetchBikeData() async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return {
        'ownerName': 'Денис Доскочинський',
        'ownerPhone': '+380 97 123 4567',
        'bikeName': 'Specialized Turbo',
        'bikeType': 'Велосипед',
        'serialNumber': 'SN-789-2026',
        'sensitivity': 0.75,
      };
    }

    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}/bike-config'))
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeoutMs));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Сервер повернув помилку: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Не вдалося з’єднатися з сервером. Перевірте мережу.');
    }
  }

  // Оновлення конфігурації профілю та байка на сервері
  Future<bool> updateBikeData(Map<String, dynamic> data) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/bike-config/update'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeoutMs));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Помилка відправки конфігурації на сервер.');
    }
  }

  // Відправка SOS сигналу тривоги на сервер
  Future<bool> reportSosAlarm(int intensity) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return true;
    }

    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/alarm/sos'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'intensity': intensity,
              'time': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeoutMs));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Не вдалося надіслати SOS сигнал тривоги.');
    }
  }
}
