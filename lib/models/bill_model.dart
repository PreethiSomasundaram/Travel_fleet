/// Represents a generated bill for a trip.
class BillModel {
  final String? id;
  final String tripId;
  final String billDate; // ISO-8601
  final String tripDate;
  final String vehicleNumber;
  final String placesToVisit;
  final String startDateTime;
  final String endDateTime;
  final double startingKm;
  final double endingKm;
  final double totalKm;
  final String rentType; // day | hour
  final int rentUnits; // number of days or hours
  final double ratePerUnit; // rate per day / hour
  final double ratePerKm;
  final double kmAmount;
  final double driverBata;
  final double toll;
  final double permit;
  final double parking;
  final double otherCharges;
  final double totalAmount;
  final double advanceAmount;
  final double payableAmount;

  BillModel({
    this.id,
    required this.tripId,
    required this.billDate,
    required this.tripDate,
    required this.vehicleNumber,
    required this.placesToVisit,
    required this.startDateTime,
    required this.endDateTime,
    required this.startingKm,
    required this.endingKm,
    required this.totalKm,
    required this.rentType,
    required this.rentUnits,
    required this.ratePerUnit,
    required this.ratePerKm,
    required this.kmAmount,
    required this.driverBata,
    this.toll = 0,
    this.permit = 0,
    this.parking = 0,
    this.otherCharges = 0,
    required this.totalAmount,
    required this.advanceAmount,
    required this.payableAmount,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'tripId': tripId,
    'billDate': billDate,
    'tripDate': tripDate,
    'vehicleNumber': vehicleNumber,
    'placesToVisit': placesToVisit,
    'startDateTime': startDateTime,
    'endDateTime': endDateTime,
    'startingKm': startingKm,
    'endingKm': endingKm,
    'totalKm': totalKm,
    'rentType': rentType,
    'rentUnits': rentUnits,
    'ratePerUnit': ratePerUnit,
    'ratePerKm': ratePerKm,
    'kmAmount': kmAmount,
    'driverBata': driverBata,
    'toll': toll,
    'permit': permit,
    'parking': parking,
    'otherCharges': otherCharges,
    'totalAmount': totalAmount,
    'advanceAmount': advanceAmount,
    'payableAmount': payableAmount,
  };

  factory BillModel.fromMap(Map<String, dynamic> map) => BillModel(
    id: map['id']?.toString(),
    tripId: map['tripId'].toString(),
    billDate: map['billDate'] as String,
    tripDate: map['tripDate'] as String,
    vehicleNumber: map['vehicleNumber'] as String,
    placesToVisit: map['placesToVisit'] as String,
    startDateTime: map['startDateTime'] as String,
    endDateTime: map['endDateTime'] as String,
    startingKm: (map['startingKm'] as num).toDouble(),
    endingKm: (map['endingKm'] as num).toDouble(),
    totalKm: (map['totalKm'] as num).toDouble(),
    rentType: map['rentType'] as String,
    rentUnits: (map['rentUnits'] as num).toInt(),
    ratePerUnit: (map['ratePerUnit'] as num).toDouble(),
    ratePerKm: (map['ratePerKm'] as num).toDouble(),
    kmAmount: (map['kmAmount'] as num).toDouble(),
    driverBata: (map['driverBata'] as num).toDouble(),
    toll: (map['toll'] as num?)?.toDouble() ?? 0,
    permit: (map['permit'] as num?)?.toDouble() ?? 0,
    parking: (map['parking'] as num?)?.toDouble() ?? 0,
    otherCharges: (map['otherCharges'] as num?)?.toDouble() ?? 0,
    totalAmount: (map['totalAmount'] as num).toDouble(),
    advanceAmount: (map['advanceAmount'] as num).toDouble(),
    payableAmount: (map['payableAmount'] as num).toDouble(),
  );
}
