import '../models/car_model.dart';
import '../core/constants.dart';
import 'api_client.dart';

/// Service for car CRUD and alert logic via REST API.
class CarService {
  final _api = ApiClient.instance;

  Future<CarModel> addCar(CarModel car) async {
    final res = await _api.post('/cars', car.toMap());
    return CarModel.fromMap(res as Map<String, dynamic>);
  }

  Future<CarModel> updateCar(CarModel car) async {
    final res = await _api.put('/cars/${car.id}', car.toMap());
    return CarModel.fromMap(res as Map<String, dynamic>);
  }

  Future<void> deleteCar(String id) async {
    await _api.delete('/cars/$id');
  }

  Future<List<CarModel>> getAllCars() async {
    final res = await _api.get('/cars') as List;
    return res
        .map((e) => CarModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<CarModel?> getCarById(String id) async {
    try {
      final res = await _api.get('/cars/$id');
      return CarModel.fromMap(res as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
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
