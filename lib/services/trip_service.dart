import '../models/trip_model.dart';
import '../models/advance_model.dart';
import 'api_client.dart';

/// Service for trip / booking management via REST API.
class TripService {
  final _api = ApiClient.instance;

  Future<TripModel> createTrip(TripModel trip) async {
    final res = await _api.post('/trips', trip.toMap());
    return TripModel.fromMap(res as Map<String, dynamic>);
  }

  Future<TripModel> updateTrip(TripModel trip) async {
    final res = await _api.put('/trips/${trip.id}', trip.toMap());
    return TripModel.fromMap(res as Map<String, dynamic>);
  }

  Future<void> deleteTrip(String id) async {
    await _api.delete('/trips/$id');
  }

  Future<List<TripModel>> getAllTrips() async {
    final res = await _api.get('/trips') as List;
    return res
        .map((e) => TripModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<TripModel?> getTripById(String id) async {
    try {
      final res = await _api.get('/trips/$id');
      return TripModel.fromMap(res as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }

  /// Returns trips assigned to a particular driver.
  Future<List<TripModel>> getTripsForDriver(String driverId) async {
    final res = await _api.get('/trips?driverId=$driverId') as List;
    return res
        .map((e) => TripModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Start a trip – sets startTime and startingKm.
  Future<void> startTrip(String tripId, double startingKm) async {
    await _api.put('/trips/$tripId', {
      'status': 'started',
      'startTime': DateTime.now().toIso8601String(),
      'startingKm': startingKm,
    });
  }

  /// End a trip – sets endTime and endingKm.
  Future<void> endTrip(String tripId, double endingKm) async {
    await _api.put('/trips/$tripId', {
      'status': 'ended',
      'endTime': DateTime.now().toIso8601String(),
      'endingKm': endingKm,
    });
  }

  /// Update charges (toll, permit, parking, other).
  Future<void> updateCharges(
    String tripId, {
    required double toll,
    required double permit,
    required double parking,
    required double otherCharges,
  }) async {
    await _api.put('/trips/$tripId', {
      'toll': toll,
      'permit': permit,
      'parking': parking,
      'otherCharges': otherCharges,
    });
  }

  // ── Advance management ────────────────────────────────────────────────────

  Future<AdvanceModel> addAdvance(AdvanceModel advance) async {
    final res = await _api.post('/advances', advance.toMap());
    return AdvanceModel.fromMap(res as Map<String, dynamic>);
  }

  Future<List<AdvanceModel>> getAdvancesForTrip(String tripId) async {
    final res = await _api.get('/advances?tripId=$tripId') as List;
    return res
        .map((e) => AdvanceModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Sum of all advances for a trip.
  Future<double> getTotalAdvance(String tripId) async {
    final advances = await getAdvancesForTrip(tripId);
    return advances.fold<double>(0.0, (sum, a) => sum + a.amount);
  }
}
