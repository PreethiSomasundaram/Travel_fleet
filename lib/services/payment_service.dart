import '../models/payment_model.dart';
import 'api_client.dart';

/// Service for tracking payment status per bill via REST API.
class PaymentService {
  final _api = ApiClient.instance;

  Future<PaymentModel> addPayment(PaymentModel payment) async {
    final res = await _api.post('/payments', payment.toMap());
    return PaymentModel.fromMap(res as Map<String, dynamic>);
  }

  Future<List<PaymentModel>> getAllPayments() async {
    final res = await _api.get('/payments') as List;
    return res
        .map((e) => PaymentModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaymentModel?> getPaymentForBill(String billId) async {
    final res = await _api.get('/payments?billId=$billId') as List;
    if (res.isEmpty) return null;
    return PaymentModel.fromMap(res.first as Map<String, dynamic>);
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await _api.put('/payments/$paymentId', {'status': status});
  }
}
