import '../models/bill_model.dart';
import 'bata_config.dart';
import 'trip_service.dart';
import 'car_service.dart';
import 'api_client.dart';

/// Service for bill generation and retrieval via REST API.
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
  final _api = ApiClient.instance;
  final _bataConfig = BataConfigService();
  final _tripService = TripService();
  final _carService = CarService();

  /// Generate a bill for a completed trip.
  ///
  /// [rentType] is `day` or `hour`.
  /// [rentUnits] is number of days / hours.
  /// [ratePerUnit] is rate per day / hour.
  /// [ratePerKm] is rate per kilometre.
  Future<BillModel> generateBill({
    required String tripId,
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

    final res = await _api.post('/bills', bill.toMap());
    return BillModel.fromMap(res as Map<String, dynamic>);
  }

  Future<List<BillModel>> getAllBills() async {
    final res = await _api.get('/bills') as List;
    return res
        .map((e) => BillModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<BillModel?> getBillById(String id) async {
    try {
      final res = await _api.get('/bills/$id');
      return BillModel.fromMap(res as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }

  Future<BillModel?> getBillForTrip(String tripId) async {
    final res = await _api.get('/bills?tripId=$tripId') as List;
    if (res.isEmpty) return null;
    return BillModel.fromMap(res.first as Map<String, dynamic>);
  }
}
