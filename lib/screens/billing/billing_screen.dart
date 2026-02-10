import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../models/bill_model.dart';
import '../../models/trip_model.dart';
import '../../services/billing_service.dart';
import '../../widgets/input_field.dart';

/// Billing screen – generate a bill for a completed trip, or list all bills.
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _billingService = BillingService();
  final _formKey = GlobalKey<FormState>();

  // Bill generation fields
  final _rentUnitsCtrl = TextEditingController();
  final _ratePerUnitCtrl = TextEditingController();
  final _ratePerKmCtrl = TextEditingController();
  String _rentType = 'day';

  List<BillModel> _bills = [];
  TripModel? _tripArg;
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is TripModel) {
      _tripArg = arg;
      _rentUnitsCtrl.text = arg.numberOfDays.toString();
    }
  }

  Future<void> _loadBills() async {
    final bills = await _billingService.getAllBills();
    setState(() {
      _bills = bills;
      _loading = false;
    });
  }

  Future<void> _generateBill() async {
    if (_tripArg == null || !_formKey.currentState!.validate()) return;
    setState(() => _generating = true);

    try {
      await _billingService.generateBill(
        tripId: _tripArg!.id!,
        rentType: _rentType,
        rentUnits: int.tryParse(_rentUnitsCtrl.text) ?? 1,
        ratePerUnit: double.tryParse(_ratePerUnitCtrl.text) ?? 0,
        ratePerKm: double.tryParse(_ratePerKmCtrl.text) ?? 0,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill generated!')),
        );
        _tripArg = null; // clear so we show the list
        _loadBills();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => _generating = false);
  }

  @override
  Widget build(BuildContext context) {
    // If we came with a trip argument, show the generation form
    if (_tripArg != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Generate Bill')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trip: ${_tripArg!.placesToVisit}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Total KM: ${_tripArg!.totalKm.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _rentType,
                  items: const [
                    DropdownMenuItem(value: 'day', child: Text('Day Rent')),
                    DropdownMenuItem(value: 'hour', child: Text('Hour Rent')),
                  ],
                  onChanged: (v) => setState(() => _rentType = v!),
                  decoration: const InputDecoration(labelText: 'Rent Type'),
                ),
                InputField(
                  label: _rentType == 'day' ? 'Number of Days' : 'Number of Hours',
                  controller: _rentUnitsCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                InputField(
                  label: _rentType == 'day' ? 'Rate per Day (₹)' : 'Rate per Hour (₹)',
                  controller: _ratePerUnitCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                InputField(
                  label: 'Rate per KM (₹)',
                  controller: _ratePerKmCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generating ? null : _generateBill,
                    child: _generating
                        ? const CircularProgressIndicator()
                        : const Text('Generate Bill'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Otherwise show all bills
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? const Center(child: Text('No bills generated yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _bills.length,
                  itemBuilder: (context, i) {
                    final bill = _bills[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long, color: Colors.orange),
                        title: Text('Bill #${bill.id} – ${bill.vehicleNumber}'),
                        subtitle: Text(
                          '${bill.placesToVisit}\n'
                          'Total: ₹${bill.totalAmount.toStringAsFixed(0)} '
                          '| Payable: ₹${bill.payableAmount.toStringAsFixed(0)}',
                        ),
                        isThreeLine: true,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.billDetail,
                          arguments: bill,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
