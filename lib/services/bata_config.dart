import 'api_client.dart';

/// Service to manage driver bata configuration per vehicle type via REST API.
class BataConfigService {
  final _api = ApiClient.instance;

  /// Returns the bata per day for a given [vehicleType].
  Future<double> getBataPerDay(String vehicleType) async {
    final configs = await getAllBataConfigs();
    return configs[vehicleType] ?? 0;
  }

  /// Returns all bata configs as a map: vehicleType → bataPerDay.
  Future<Map<String, double>> getAllBataConfigs() async {
    final res = await _api.get('/bata-config') as List;
    return {
      for (final item in res)
        (item as Map<String, dynamic>)['vehicleType'] as String:
            ((item)['bataPerDay'] as num).toDouble(),
    };
  }

  /// Updates bata per day for a vehicle type.
  Future<void> updateBata(String vehicleType, double bataPerDay) async {
    await _api.put('/bata-config/$vehicleType', {'bataPerDay': bataPerDay});
  }
}
