/// Represents a trip / booking in the fleet system.
class TripModel {
  final int? id;
  final String pickupDate; // ISO-8601
  final String pickupTime;
  final String pickupLocation;
  final int numberOfDays;
  final String placesToVisit;
  final int? carId;
  final int? driverId;
  final String status; // created | started | ended

  // Filled by driver on trip start
  final String? startTime;
  final double? startingKm;

  // Filled by driver on trip end
  final String? endTime;
  final double? endingKm;

  // Charges marked by driver
  final double toll;
  final double permit;
  final double parking;
  final double otherCharges;

  TripModel({
    this.id,
    required this.pickupDate,
    required this.pickupTime,
    required this.pickupLocation,
    required this.numberOfDays,
    required this.placesToVisit,
    this.carId,
    this.driverId,
    this.status = 'created',
    this.startTime,
    this.startingKm,
    this.endTime,
    this.endingKm,
    this.toll = 0,
    this.permit = 0,
    this.parking = 0,
    this.otherCharges = 0,
  });

  /// Total KM for this trip. Returns 0 if trip not finished.
  double get totalKm =>
      (endingKm != null && startingKm != null) ? endingKm! - startingKm! : 0;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'pickupDate': pickupDate,
    'pickupTime': pickupTime,
    'pickupLocation': pickupLocation,
    'numberOfDays': numberOfDays,
    'placesToVisit': placesToVisit,
    'carId': carId,
    'driverId': driverId,
    'status': status,
    'startTime': startTime,
    'endTime': endTime,
    'startingKm': startingKm,
    'endingKm': endingKm,
    'toll': toll,
    'permit': permit,
    'parking': parking,
    'otherCharges': otherCharges,
  };

  factory TripModel.fromMap(Map<String, dynamic> map) => TripModel(
    id: map['id'] as int?,
    pickupDate: map['pickupDate'] as String,
    pickupTime: map['pickupTime'] as String,
    pickupLocation: map['pickupLocation'] as String,
    numberOfDays: map['numberOfDays'] as int,
    placesToVisit: map['placesToVisit'] as String,
    carId: map['carId'] as int?,
    driverId: map['driverId'] as int?,
    status: map['status'] as String? ?? 'created',
    startTime: map['startTime'] as String?,
    endTime: map['endTime'] as String?,
    startingKm: (map['startingKm'] as num?)?.toDouble(),
    endingKm: (map['endingKm'] as num?)?.toDouble(),
    toll: (map['toll'] as num?)?.toDouble() ?? 0,
    permit: (map['permit'] as num?)?.toDouble() ?? 0,
    parking: (map['parking'] as num?)?.toDouble() ?? 0,
    otherCharges: (map['otherCharges'] as num?)?.toDouble() ?? 0,
  );

  TripModel copyWith({
    int? id,
    String? pickupDate,
    String? pickupTime,
    String? pickupLocation,
    int? numberOfDays,
    String? placesToVisit,
    int? carId,
    int? driverId,
    String? status,
    String? startTime,
    double? startingKm,
    String? endTime,
    double? endingKm,
    double? toll,
    double? permit,
    double? parking,
    double? otherCharges,
  }) =>
      TripModel(
        id: id ?? this.id,
        pickupDate: pickupDate ?? this.pickupDate,
        pickupTime: pickupTime ?? this.pickupTime,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        numberOfDays: numberOfDays ?? this.numberOfDays,
        placesToVisit: placesToVisit ?? this.placesToVisit,
        carId: carId ?? this.carId,
        driverId: driverId ?? this.driverId,
        status: status ?? this.status,
        startTime: startTime ?? this.startTime,
        startingKm: startingKm ?? this.startingKm,
        endTime: endTime ?? this.endTime,
        endingKm: endingKm ?? this.endingKm,
        toll: toll ?? this.toll,
        permit: permit ?? this.permit,
        parking: parking ?? this.parking,
        otherCharges: otherCharges ?? this.otherCharges,
      );
}
