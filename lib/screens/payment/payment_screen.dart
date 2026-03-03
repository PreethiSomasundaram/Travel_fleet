import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/bill_model.dart';
import '../../models/payment_model.dart';
import '../../services/billing_service.dart';
import '../../services/payment_service.dart';

/// Payment tracking – lists all bills and their payment status.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _billingService = BillingService();
  final _paymentService = PaymentService();
  List<BillModel> _bills = [];
  Map<String, PaymentModel> _payments = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bills = await _billingService.getAllBills();
    final allPayments = await _paymentService.getAllPayments();

    final paymentMap = <String, PaymentModel>{};
    for (final p in allPayments) {
      paymentMap[p.billId] = p;
    }

    setState(() {
      _bills = bills;
      _payments = paymentMap;
      _loading = false;
    });
  }

  Future<void> _togglePayment(BillModel bill) async {
    final existing = _payments[bill.id];
    if (existing == null) {
      // Create as pending
      await _paymentService.addPayment(
        PaymentModel(
          billId: bill.id!,
          amount: bill.payableAmount,
          status: AppConstants.paymentPaid,
          date: DateTime.now().toIso8601String(),
        ),
      );
    } else {
      final newStatus = existing.status == AppConstants.paymentPaid
          ? AppConstants.paymentPending
          : AppConstants.paymentPaid;
      await _paymentService.updatePaymentStatus(existing.id!, newStatus);
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 64,
                    color: cs.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No bills to track',
                    style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _bills.length,
              itemBuilder: (context, i) {
                final bill = _bills[i];
                final payment = _payments[bill.id];
                final isPaid = payment?.status == AppConstants.paymentPaid;

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isPaid ? Icons.check_circle : Icons.pending,
                      color: isPaid ? cs.tertiary : const Color(0xFFF59E0B),
                    ),
                    title: Text('Bill #${bill.id} – ${bill.vehicleNumber}'),
                    subtitle: Text(
                      'Payable: ₹${bill.payableAmount.toStringAsFixed(0)}\n'
                      'Status: ${isPaid ? 'PAID' : 'PENDING'}',
                    ),
                    isThreeLine: true,
                    trailing: TextButton(
                      onPressed: () => _togglePayment(bill),
                      child: Text(isPaid ? 'Mark Pending' : 'Mark Paid'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
