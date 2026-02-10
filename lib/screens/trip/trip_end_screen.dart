import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/input_field.dart';

/// Screen for a driver to end a trip (enter Ending KM and charges).
class TripEndScreen extends StatefulWidget {
  const TripEndScreen({super.key});

  @override
  State<TripEndScreen> createState() => _TripEndScreenState();
}

class _TripEndScreenState extends State<TripEndScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripService = TripService();

  final _endingKmCtrl = TextEditingController();
  final _tollCtrl = TextEditingController(text: '0');
  final _permitCtrl = TextEditingController(text: '0');
  final _parkingCtrl = TextEditingController(text: '0');
  final _otherCtrl = TextEditingController(text: '0');

  TripModel? _trip;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _trip ??= ModalRoute.of(context)?.settings.arguments as TripModel?;
  }

  Future<void> _endTrip() async {
    if (!_formKey.currentState!.validate() || _trip == null) return;
    final km = double.tryParse(_endingKmCtrl.text);
    if (km == null) return;

    // Validate ending KM > starting KM
    if (_trip!.startingKm != null && km <= _trip!.startingKm!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ending KM must be greater than Starting KM')),
      );
      return;
    }

    // Save charges first
    await _tripService.updateCharges(
      _trip!.id!,
      toll: double.tryParse(_tollCtrl.text) ?? 0,
      permit: double.tryParse(_permitCtrl.text) ?? 0,
      parking: double.tryParse(_parkingCtrl.text) ?? 0,
      otherCharges: double.tryParse(_otherCtrl.text) ?? 0,
    );

    await _tripService.endTrip(_trip!.id!, km);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip ended!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('End Trip')),
      body: _trip == null
          ? const Center(child: Text('No trip data'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trip: ${_trip!.placesToVisit}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (_trip!.startingKm != null)
                      Text('Starting KM: ${_trip!.startingKm!.toStringAsFixed(0)}'),
                    const SizedBox(height: 24),
                    InputField(
                      label: 'Ending KM',
                      controller: _endingKmCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter ending KM';
                        if (double.tryParse(v) == null) return 'Enter valid number';
                        return null;
                      },
                    ),
                    const Divider(height: 32),
                    const Text('Applicable Charges',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    InputField(
                      label: 'Toll',
                      controller: _tollCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    InputField(
                      label: 'Permit',
                      controller: _permitCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    InputField(
                      label: 'Parking',
                      controller: _parkingCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    InputField(
                      label: 'Other Charges',
                      controller: _otherCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.stop),
                        label: const Text('End Trip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: _endTrip,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
