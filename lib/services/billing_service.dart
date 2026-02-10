import '../database/db_helper.dart';
import '../models/bill_model.dart';
import 'bata_config.dart';
import 'trip_service.dart';
import 'car_service.dart';

/// Service for bill generation and retrieval.
///
/// Billing Calculation:
/// ```
/// Total KM   = End KM − Start KM
/// KM Amount  = Total KM × Rate per KM
/// Driver Bata = Vehicle Bata × No. of Days
/// Total      = KM Amount + Driver Bata + Rent + Other Charges
/// Payable    = Total − Advance
/// ```
class BillingService {
  final _db = DBHelper.instance;
  final _bataConfig = BataConfigService();
  final _tripService = TripService();
  final _carService = CarService();

  /// Generate a bill for a completed trip.
  ///
  /// [rentType] is `day` or `hour`.
  /// [rentUnits] is number of days / hours.
  /// [ratePerUnit] is rate per day / hour.
  /// [ratePerKm] is rate per kilometre.
  Future<int> generateBill({
    required int tripId,
    required String rentType,
    required int rentUnits,
    required double ratePerUnit,
    required double ratePerKm,
  }) async {
    final trip = await _tripService.getTripById(tripId);
    if (trip == null) throw Exception('Trip not found');
    if (trip.status != 'ended') throw Exception('Trip has not ended yet');

    final car = trip.carId != null
        ? await _carService.getCarById(trip.carId!)
        : null;

    final totalKm = trip.totalKm;
    final kmAmount = totalKm * ratePerKm;

    // Auto-pick bata based on vehicle type
    double bataPerDay = 0;
    if (car != null) {
      bataPerDay = await _bataConfig.getBataPerDay(car.vehicleType);
    }
    final driverBata = bataPerDay * trip.numberOfDays;

    final rentAmount = rentUnits * ratePerUnit;
    final chargesTotal = trip.toll + trip.permit + trip.parking + trip.otherCharges;
    final totalAmount = kmAmount + driverBata + rentAmount + chargesTotal;

    final advanceAmount = await _tripService.getTotalAdvance(tripId);
    final payableAmount = totalAmount - advanceAmount;

    final bill = BillModel(
      tripId: tripId,
      billDate: DateTime.now().toIso8601String(),
      tripDate: trip.pickupDate,
      vehicleNumber: car?.vehicleNumber ?? 'N/A',
      placesToVisit: trip.placesToVisit,
      startDateTime: trip.startTime ?? '',
      endDateTime: trip.endTime ?? '',
      startingKm: trip.startingKm ?? 0,
      endingKm: trip.endingKm ?? 0,
      totalKm: totalKm,
      rentType: rentType,
      rentUnits: rentUnits,
      ratePerUnit: ratePerUnit,
      ratePerKm: ratePerKm,
      kmAmount: kmAmount,
      driverBata: driverBata,
      toll: trip.toll,
      permit: trip.permit,
      parking: trip.parking,
      otherCharges: trip.otherCharges,
      totalAmount: totalAmount,
      advanceAmount: advanceAmount,
      payableAmount: payableAmount,
    );

    return _db.insert('bills', bill.toMap());
  }

  Future<List<BillModel>> getAllBills() async {
    final rows = await _db.queryAll('bills');
    return rows.map(BillModel.fromMap).toList();
  }

  Future<BillModel?> getBillById(int id) async {
    final rows = await _db.queryWhere('bills', 'id = ?', [id]);
    if (rows.isEmpty) return null;
    return BillModel.fromMap(rows.first);
  }

  Future<BillModel?> getBillForTrip(int tripId) async {
    final rows = await _db.queryWhere('bills', 'tripId = ?', [tripId]);
    if (rows.isEmpty) return null;
    return BillModel.fromMap(rows.first);
  }
}
