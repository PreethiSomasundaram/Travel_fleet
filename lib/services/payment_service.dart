import '../database/db_helper.dart';
import '../models/payment_model.dart';

/// Service for tracking payment status per bill.
class PaymentService {
  final _db = DBHelper.instance;

  Future<int> addPayment(PaymentModel payment) =>
      _db.insert('payments', payment.toMap());

  Future<List<PaymentModel>> getAllPayments() async {
    final rows = await _db.queryAll('payments');
    return rows.map(PaymentModel.fromMap).toList();
  }

  Future<PaymentModel?> getPaymentForBill(int billId) async {
    final rows = await _db.queryWhere('payments', 'billId = ?', [billId]);
    if (rows.isEmpty) return null;
    return PaymentModel.fromMap(rows.first);
  }

  Future<void> updatePaymentStatus(int paymentId, String status) async {
    await _db.update('payments', {'status': status}, 'id = ?', [paymentId]);
  }
}
