/// Represents a vehicle managed by the fleet.
class CarModel {
  final int? id;
  final String vehicleNumber;
  final String vehicleType; // Sedan, MPV, SUV, Tempo Traveller, Bus
  final double currentKm;
  final double nextServiceKm;
  final String fcExpiryDate; // ISO-8601 date string
  final String insuranceExpiryDate;
  final String pucExpiryDate;

  CarModel({
    this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.currentKm,
    required this.nextServiceKm,
    required this.fcExpiryDate,
    required this.insuranceExpiryDate,
    required this.pucExpiryDate,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'vehicleNumber': vehicleNumber,
    'vehicleType': vehicleType,
    'currentKm': currentKm,
    'nextServiceKm': nextServiceKm,
    'fcExpiryDate': fcExpiryDate,
    'insuranceExpiryDate': insuranceExpiryDate,
    'pucExpiryDate': pucExpiryDate,
  };

  factory CarModel.fromMap(Map<String, dynamic> map) => CarModel(
    id: map['id'] as int?,
    vehicleNumber: map['vehicleNumber'] as String,
    vehicleType: map['vehicleType'] as String,
    currentKm: (map['currentKm'] as num).toDouble(),
    nextServiceKm: (map['nextServiceKm'] as num).toDouble(),
    fcExpiryDate: map['fcExpiryDate'] as String,
    insuranceExpiryDate: map['insuranceExpiryDate'] as String,
    pucExpiryDate: map['pucExpiryDate'] as String,
  );

  CarModel copyWith({
    int? id,
    String? vehicleNumber,
    String? vehicleType,
    double? currentKm,
    double? nextServiceKm,
    String? fcExpiryDate,
    String? insuranceExpiryDate,
    String? pucExpiryDate,
  }) =>
      CarModel(
        id: id ?? this.id,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        vehicleType: vehicleType ?? this.vehicleType,
        currentKm: currentKm ?? this.currentKm,
        nextServiceKm: nextServiceKm ?? this.nextServiceKm,
        fcExpiryDate: fcExpiryDate ?? this.fcExpiryDate,
        insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
        pucExpiryDate: pucExpiryDate ?? this.pucExpiryDate,
      );
}
