import '../database/db_helper.dart';
import '../models/trip_model.dart';
import '../models/advance_model.dart';

/// Service for trip / booking management.
class TripService {
  final _db = DBHelper.instance;

  Future<int> createTrip(TripModel trip) => _db.insert('trips', trip.toMap());

  Future<int> updateTrip(TripModel trip) =>
      _db.update('trips', trip.toMap(), 'id = ?', [trip.id]);

  Future<int> deleteTrip(int id) => _db.delete('trips', 'id = ?', [id]);

  Future<List<TripModel>> getAllTrips() async {
    final rows = await _db.queryAll('trips');
    return rows.map(TripModel.fromMap).toList();
  }

  Future<TripModel?> getTripById(int id) async {
    final rows = await _db.queryWhere('trips', 'id = ?', [id]);
    if (rows.isEmpty) return null;
    return TripModel.fromMap(rows.first);
  }

  /// Returns trips assigned to a particular driver.
  Future<List<TripModel>> getTripsForDriver(int driverId) async {
    final rows = await _db.queryWhere('trips', 'driverId = ?', [driverId]);
    return rows.map(TripModel.fromMap).toList();
  }

  /// Start a trip – sets startTime and startingKm.
  Future<void> startTrip(int tripId, double startingKm) async {
    await _db.update('trips', {
      'status': 'started',
      'startTime': DateTime.now().toIso8601String(),
      'startingKm': startingKm,
    }, 'id = ?', [tripId]);
  }

  /// End a trip – sets endTime and endingKm.
  Future<void> endTrip(int tripId, double endingKm) async {
    await _db.update('trips', {
      'status': 'ended',
      'endTime': DateTime.now().toIso8601String(),
      'endingKm': endingKm,
    }, 'id = ?', [tripId]);
  }

  /// Update charges (toll, permit, parking, other).
  Future<void> updateCharges(
    int tripId, {
    required double toll,
    required double permit,
    required double parking,
    required double otherCharges,
  }) async {
    await _db.update('trips', {
      'toll': toll,
      'permit': permit,
      'parking': parking,
      'otherCharges': otherCharges,
    }, 'id = ?', [tripId]);
  }

  // ── Advance management ────────────────────────────────────────────────────

  Future<int> addAdvance(AdvanceModel advance) =>
      _db.insert('advances', advance.toMap());

  Future<List<AdvanceModel>> getAdvancesForTrip(int tripId) async {
    final rows = await _db.queryWhere('advances', 'tripId = ?', [tripId]);
    return rows.map(AdvanceModel.fromMap).toList();
  }

  /// Sum of all advances for a trip.
  Future<double> getTotalAdvance(int tripId) async {
    final rows = await _db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM advances WHERE tripId = ?',
      [tripId],
    );
    return (rows.first['total'] as num).toDouble();
  }
}
