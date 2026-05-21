class ApiConfig {
  // Налаштування для підключення до твого бекенду бази даних
  static const String baseUrl = 'https://api.iot-smartbike.local/v1';

  // Якщо true — додаток імітує мережеві запити з локальною затримкою.
  // Якщо false — додаток робить реальні HTTP-запити на вказаний baseUrl.
  static const bool useMockData = true;

  // Тайм-аут з'єднання в мілісекундах
  static const int connectTimeoutMs = 5000;
}
