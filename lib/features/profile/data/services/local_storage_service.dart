import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyOwnerName = 'owner_name';
  static const String _keyOwnerPhone = 'owner_phone';
  static const String _keyBikeName = 'bike_name';
  static const String _keyBikeType = 'bike_type';
  static const String _keySerial = 'serial_number';
  static const String _keySensitivity = 'sensitivity';
  static const String _keyAlertCount = 'alert_count';

  // Збереження всіх налаштувань профілю та пристрою
  Future<void> saveBikeData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOwnerName, data['ownerName'] as String? ?? '');
    await prefs.setString(_keyOwnerPhone, data['ownerPhone'] as String? ?? '');
    await prefs.setString(_keyBikeName, data['bikeName'] as String? ?? '');
    await prefs.setString(_keyBikeType, data['bikeType'] as String? ?? '');
    await prefs.setString(_keySerial, data['serialNumber'] as String? ?? '');
    await prefs.setDouble(
      _keySensitivity,
      (data['sensitivity'] as num? ?? 0.5).toDouble(),
    );
  }

  // Отримання локально збережених налаштувань
  Future<Map<String, dynamic>?> getBikeData() async {
    final prefs = await SharedPreferences.getInstance();
    final ownerName = prefs.getString(_keyOwnerName);
    if (ownerName == null) return null;

    return {
      'ownerName': ownerName,
      'ownerPhone': prefs.getString(_keyOwnerPhone) ?? '',
      'bikeName': prefs.getString(_keyBikeName) ?? '',
      'bikeType': prefs.getString(_keyBikeType) ?? 'Велосипед',
      'serialNumber': prefs.getString(_keySerial) ?? '',
      'sensitivity': prefs.getDouble(_keySensitivity) ?? 0.5,
    };
  }

  // Збереження кількості тривог
  Future<void> saveAlertCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAlertCount, count);
  }

  // Отримання кількості тривог
  Future<int> getAlertCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAlertCount) ?? 0;
  }
}
