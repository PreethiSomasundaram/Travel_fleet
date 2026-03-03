import 'package:flutter/material.dart';
import '../../models/bill_model.dart';

/// Detailed view of a single bill.
class BillDetailScreen extends StatelessWidget {
  const BillDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bill = ModalRoute.of(context)?.settings.arguments as BillModel?;
    final cs = Theme.of(context).colorScheme;

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
            _header(context, 'Trip Information'),
            _row(context, 'Vehicle', bill.vehicleNumber),
            _row(context, 'Places', bill.placesToVisit),
            _row(context, 'Trip Date', bill.tripDate),
            _row(context, 'Start', bill.startDateTime),
            _row(context, 'End', bill.endDateTime),
            const Divider(height: 24),
            _header(context, 'KM Details'),
            _row(context, 'Starting KM', bill.startingKm.toStringAsFixed(0)),
            _row(context, 'Ending KM', bill.endingKm.toStringAsFixed(0)),
            _row(context, 'Total KM', bill.totalKm.toStringAsFixed(0)),
            const Divider(height: 24),
            _header(context, 'Billing Details'),
            _row(context, 'Rent Type', bill.rentType.toUpperCase()),
            _row(context, 'Rent Units', '${bill.rentUnits}'),
            _row(
              context,
              'Rate per ${bill.rentType}',
              '₹${bill.ratePerUnit.toStringAsFixed(0)}',
            ),
            _row(
              context,
              'Rate per KM',
              '₹${bill.ratePerKm.toStringAsFixed(0)}',
            ),
            _row(context, 'KM Amount', '₹${bill.kmAmount.toStringAsFixed(0)}'),
            _row(
              context,
              'Driver Bata',
              '₹${bill.driverBata.toStringAsFixed(0)}',
            ),
            const Divider(height: 24),
            _header(context, 'Charges'),
            _row(context, 'Toll', '₹${bill.toll.toStringAsFixed(0)}'),
            _row(context, 'Permit', '₹${bill.permit.toStringAsFixed(0)}'),
            _row(context, 'Parking', '₹${bill.parking.toStringAsFixed(0)}'),
            _row(context, 'Other', '₹${bill.otherCharges.toStringAsFixed(0)}'),
            const Divider(height: 24),
            _header(context, 'Summary'),
            _row(
              context,
              'Total Amount',
              '₹${bill.totalAmount.toStringAsFixed(0)}',
            ),
            _row(
              context,
              'Advance',
              '₹${bill.advanceAmount.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PAYABLE AMOUNT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    '₹${bill.payableAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: cs.primary,
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

  Widget _header(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );

  Widget _row(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(value),
      ],
    ),
  );
}
