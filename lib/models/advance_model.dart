/// Represents an advance payment against a trip.
class AdvanceModel {
  final int? id;
  final int tripId;
  final double amount;
  final String advanceType; // booking | fuel
  final String enteredBy; // role of the person who entered
  final String date; // ISO-8601

  AdvanceModel({
    this.id,
    required this.tripId,
    required this.amount,
    required this.advanceType,
    required this.enteredBy,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'tripId': tripId,
    'amount': amount,
    'advanceType': advanceType,
    'enteredBy': enteredBy,
    'date': date,
  };

  factory AdvanceModel.fromMap(Map<String, dynamic> map) => AdvanceModel(
    id: map['id'] as int?,
    tripId: map['tripId'] as int,
    amount: (map['amount'] as num).toDouble(),
    advanceType: map['advanceType'] as String,
    enteredBy: map['enteredBy'] as String,
    date: map['date'] as String,
  );
}
