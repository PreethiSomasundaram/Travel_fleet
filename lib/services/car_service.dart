import '../database/db_helper.dart';
import '../models/car_model.dart';
import '../core/constants.dart';

/// Service for car CRUD and alert logic.
class CarService {
  final _db = DBHelper.instance;

  Future<int> addCar(CarModel car) => _db.insert('cars', car.toMap());

  Future<int> updateCar(CarModel car) =>
      _db.update('cars', car.toMap(), 'id = ?', [car.id]);

  Future<int> deleteCar(int id) => _db.delete('cars', 'id = ?', [id]);

  Future<List<CarModel>> getAllCars() async {
    final rows = await _db.queryAll('cars');
    return rows.map(CarModel.fromMap).toList();
  }

  Future<CarModel?> getCarById(int id) async {
    final rows = await _db.queryWhere('cars', 'id = ?', [id]);
    if (rows.isEmpty) return null;
    return CarModel.fromMap(rows.first);
  }

  /// Updates current KM after service.
  Future<void> updateServiceKm(int carId, double newNextServiceKm) async {
    await _db.update(
      'cars',
      {'nextServiceKm': newNextServiceKm},
      'id = ?',
      [carId],
    );
  }

  // ── Alert helpers ─────────────────────────────────────────────────────────

  /// Returns `true` if the date string is expired (before today).
  bool isExpired(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  /// Returns `true` if the date string is within [AppConstants.expiryWarningDays].
  bool isNearExpiry(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return false;
    final daysLeft = date.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= AppConstants.expiryWarningDays;
  }

  /// Returns `true` if service is nearing (≤ 300 km remaining).
  bool isNearService(CarModel car) {
    final remaining = car.nextServiceKm - car.currentKm;
    return remaining >= 0 && remaining <= AppConstants.serviceWarningKm;
  }

  /// Returns cars that have any alert (expired / near-expiry / near-service).
  Future<List<CarModel>> getCarsWithAlerts() async {
    final all = await getAllCars();
    return all.where((c) {
      return isExpired(c.fcExpiryDate) ||
          isExpired(c.insuranceExpiryDate) ||
          isExpired(c.pucExpiryDate) ||
          isNearExpiry(c.fcExpiryDate) ||
          isNearExpiry(c.insuranceExpiryDate) ||
          isNearExpiry(c.pucExpiryDate) ||
          isNearService(c);
    }).toList();
  }
}
