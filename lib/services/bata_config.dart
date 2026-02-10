import '../database/db_helper.dart';

/// Service to manage driver bata configuration per vehicle type.
///
/// Bata values are stored in the `bata_config` table and seeded with defaults.
class BataConfigService {
  final _db = DBHelper.instance;

  /// Returns the bata per day for a given [vehicleType].
  Future<double> getBataPerDay(String vehicleType) async {
    final rows = await _db.queryWhere(
      'bata_config',
      'vehicleType = ?',
      [vehicleType],
    );
    if (rows.isNotEmpty) {
      return (rows.first['bataPerDay'] as num).toDouble();
    }
    return 0;
  }

  /// Returns all bata configs as a map: vehicleType → bataPerDay.
  Future<Map<String, double>> getAllBataConfigs() async {
    final rows = await _db.queryAll('bata_config');
    return {
      for (final row in rows)
        row['vehicleType'] as String: (row['bataPerDay'] as num).toDouble(),
    };
  }

  /// Updates bata per day for a vehicle type.
  Future<void> updateBata(String vehicleType, double bataPerDay) async {
    await _db.update(
      'bata_config',
      {'bataPerDay': bataPerDay},
      'vehicleType = ?',
      [vehicleType],
    );
  }
}
