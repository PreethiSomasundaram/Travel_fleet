/// Application-wide configuration for API connectivity.
class AppConfig {
  /// Base URL for the backend API.
  ///
  /// • Android emulator → `http://10.0.2.2:3000/api`
  /// • Physical device   → replace with your machine's LAN IP, e.g.
  ///   `http://192.168.1.100:3000/api`
  /// • Web / Windows      → `http://localhost:3000/api`
  static const String apiBaseUrl = 'http://localhost:3000/api';
}
