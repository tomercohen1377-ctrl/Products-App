/// Connection settings for the Platzi Fake Store API.
class ApiConfig {
  const ApiConfig({
    this.baseUrl = 'https://api.escuelajs.co/api/v1',
    this.connectTimeout = const Duration(seconds: 10),
    this.sendTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration sendTimeout;
  final Duration receiveTimeout;
}
