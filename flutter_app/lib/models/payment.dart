class PaymentModel {
  final String id;
  final String status;
  final double amount;

  const PaymentModel({required this.id, required this.status, required this.amount});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] as String,
      status: json['status'] as String? ?? 'pending',
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
