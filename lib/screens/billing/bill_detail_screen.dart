import 'package:flutter/material.dart';
import '../../models/bill_model.dart';

/// Detailed view of a single bill.
class BillDetailScreen extends StatelessWidget {
  const BillDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bill = ModalRoute.of(context)?.settings.arguments as BillModel?;
    if (bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bill Detail')),
        body: const Center(child: Text('No bill data')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Bill #${bill.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header('Trip Information'),
            _row('Vehicle', bill.vehicleNumber),
            _row('Places', bill.placesToVisit),
            _row('Trip Date', bill.tripDate),
            _row('Start', bill.startDateTime),
            _row('End', bill.endDateTime),
            const Divider(height: 24),
            _header('KM Details'),
            _row('Starting KM', bill.startingKm.toStringAsFixed(0)),
            _row('Ending KM', bill.endingKm.toStringAsFixed(0)),
            _row('Total KM', bill.totalKm.toStringAsFixed(0)),
            const Divider(height: 24),
            _header('Billing Details'),
            _row('Rent Type', bill.rentType.toUpperCase()),
            _row('Rent Units', '${bill.rentUnits}'),
            _row('Rate per ${bill.rentType}', '₹${bill.ratePerUnit.toStringAsFixed(0)}'),
            _row('Rate per KM', '₹${bill.ratePerKm.toStringAsFixed(0)}'),
            _row('KM Amount', '₹${bill.kmAmount.toStringAsFixed(0)}'),
            _row('Driver Bata', '₹${bill.driverBata.toStringAsFixed(0)}'),
            const Divider(height: 24),
            _header('Charges'),
            _row('Toll', '₹${bill.toll.toStringAsFixed(0)}'),
            _row('Permit', '₹${bill.permit.toStringAsFixed(0)}'),
            _row('Parking', '₹${bill.parking.toStringAsFixed(0)}'),
            _row('Other', '₹${bill.otherCharges.toStringAsFixed(0)}'),
            const Divider(height: 24),
            _header('Summary'),
            _row('Total Amount', '₹${bill.totalAmount.toStringAsFixed(0)}'),
            _row('Advance', '₹${bill.advanceAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PAYABLE AMOUNT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '₹${bill.payableAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value),
      ],
    ),
  );
}
