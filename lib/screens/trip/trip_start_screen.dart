import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/input_field.dart';

/// Screen for a driver to start a trip (enter Starting KM).
class TripStartScreen extends StatefulWidget {
  const TripStartScreen({super.key});

  @override
  State<TripStartScreen> createState() => _TripStartScreenState();
}

class _TripStartScreenState extends State<TripStartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripService = TripService();
  final _startingKmCtrl = TextEditingController();

  TripModel? _trip;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _trip ??= ModalRoute.of(context)?.settings.arguments as TripModel?;
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate() || _trip == null) return;
    final km = double.tryParse(_startingKmCtrl.text);
    if (km == null) return;

    await _tripService.startTrip(_trip!.id!, km);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip started!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Trip')),
      body: _trip == null
          ? const Center(child: Text('No trip data'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trip: ${_trip!.placesToVisit}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Pickup: ${_trip!.pickupLocation}'),
                    Text('Date: ${_trip!.pickupDate}'),
                    const SizedBox(height: 24),
                    InputField(
                      label: 'Starting KM',
                      controller: _startingKmCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter starting KM';
                        if (double.tryParse(v) == null) return 'Enter valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Trip'),
                        onPressed: _start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
