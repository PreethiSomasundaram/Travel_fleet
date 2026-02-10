/// Tracks payment status for a bill.
class PaymentModel {
  final String? id;
  final String billId;
  final double amount;
  final String status; // paid | pending
  final String date; // ISO-8601
  final String? remarks;

  PaymentModel({
    this.id,
    required this.billId,
    required this.amount,
    required this.status,
    required this.date,
    this.remarks,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'billId': billId,
    'amount': amount,
    'status': status,
    'date': date,
    'remarks': remarks,
  };

  factory PaymentModel.fromMap(Map<String, dynamic> map) => PaymentModel(
    id: map['id']?.toString(),
    billId: map['billId'].toString(),
    amount: (map['amount'] as num).toDouble(),
    status: map['status'] as String,
    date: map['date'] as String,
    remarks: map['remarks'] as String?,
  );
}
