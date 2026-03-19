import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';

class TripsPage extends ConsumerStatefulWidget {
  const TripsPage({super.key});

  @override
  ConsumerState<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends ConsumerState<TripsPage> {
  final _customerName = TextEditingController();
  final _customerMobile = TextEditingController();
  final _pickupLocation = TextEditingController();
  final _places = TextEditingController();
  final _days = TextEditingController(text: '1');
  DateTime _pickupDateTime = DateTime.now();
  String? _driverId;
  String? _vehicleId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final app = ref.read(appStateProvider.notifier);
      await app.fetchDrivers();
      await app.fetchVehicles();
      await app.fetchTrips();
    });
  }

  @override
  void dispose() {
    _customerName.dispose();
    _customerMobile.dispose();
    _pickupLocation.dispose();
    _places.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _pickPickupDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _pickupDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickupDateTime),
    );

    if (time == null) return;

    setState(() {
      _pickupDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _createTrip() async {
    if (_customerName.text.trim().isEmpty || _customerMobile.text.trim().isEmpty) {
      _show('Customer name and mobile number are required');
      return;
    }

    if (_pickupLocation.text.trim().isEmpty || _driverId == null || _vehicleId == null) {
      _show('Pickup location, driver, and vehicle are required');
      return;
    }

    await ref.read(appStateProvider.notifier).createTrip({
      'pickupDateTime': _pickupDateTime.toIso8601String(),
      'customerName': _customerName.text.trim(),
      'customerMobile': _customerMobile.text.trim(),
      'pickupLocation': _pickupLocation.text.trim(),
      'placesToVisit': _places.text.trim().isEmpty ? ['Local'] : _places.text.split(',').map((e) => e.trim()).toList(),
      'numberOfDays': int.tryParse(_days.text) ?? 1,
      'driverId': _driverId,
      'vehicleId': _vehicleId,
    });

    _customerName.clear();
    _customerMobile.clear();
    _pickupLocation.clear();
    _places.clear();
    _days.text = '1';
    setState(() {
      _driverId = null;
      _vehicleId = null;
      _pickupDateTime = DateTime.now();
    });
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _assignBata(String tripId, double currentAmount) async {
    final controller = TextEditingController(
      text: currentAmount > 0 ? currentAmount.toStringAsFixed(0) : '',
    );

    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Driver Bata'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Bata Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed == null || parsed < 0) {
                _show('Enter a valid amount');
                return;
              }
              Navigator.pop(context, parsed);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (amount == null) return;
    await ref.read(appStateProvider.notifier).assignTripBata(tripId, amount);
    _show('Driver bata assigned');
  }

  Future<void> _startTrip(String tripId) async {
    final controller = TextEditingController();
    final startKm = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Trip'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Start KM'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              if (parsed == null || parsed < 0) {
                _show('Enter valid start KM');
                return;
              }
              Navigator.pop(context, parsed);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (startKm == null) return;
    await ref.read(appStateProvider.notifier).startTrip(tripId, startKm);
    _show('Trip started');
  }

  Future<void> _endTrip(String tripId) async {
    final kmController = TextEditingController();
    bool toll = false;
    bool permit = false;
    bool parking = false;

    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('End Trip'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kmController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'End KM'),
                ),
                CheckboxListTile(
                  value: toll,
                  onChanged: (value) => setDialogState(() => toll = value ?? false),
                  title: const Text('Toll Applicable'),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: permit,
                  onChanged: (value) => setDialogState(() => permit = value ?? false),
                  title: const Text('Permit Applicable'),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  value: parking,
                  onChanged: (value) => setDialogState(() => parking = value ?? false),
                  title: const Text('Parking Applicable'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final endKm = int.tryParse(kmController.text.trim());
                if (endKm == null || endKm < 0) {
                  _show('Enter valid end KM');
                  return;
                }
                Navigator.pop(context, {
                  'endKm': endKm,
                  'tollApplicable': toll,
                  'permitApplicable': permit,
                  'parkingApplicable': parking,
                });
              },
              child: const Text('End Trip'),
            ),
          ],
        ),
      ),
    );

    if (payload == null) return;
    await ref.read(appStateProvider.notifier).endTrip(tripId, payload);
    _show('Trip completed');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final role = ref.watch(authProvider).role;
    final auth = ref.watch(authProvider);
    final isWide = MediaQuery.of(context).size.width > 760;
    final dateLabel = DateFormat('dd MMM yyyy • HH:mm').format(_pickupDateTime);
    final visibleTrips = role == 'driver'
      ? state.trips.where((t) => t.driverName != null && t.driverName == auth.name).toList()
      : state.trips;

    return RefreshIndicator(
      onRefresh: () async {
        final app = ref.read(appStateProvider.notifier);
        await app.fetchDrivers();
        await app.fetchVehicles();
        await app.fetchTrips();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (role == 'owner' || role == 'employee')
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Schedule Trip', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (isWide)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customerName,
                              decoration: const InputDecoration(labelText: 'Customer Name'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _customerMobile,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(labelText: 'Mobile Number'),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      TextField(
                        controller: _customerName,
                        decoration: const InputDecoration(labelText: 'Customer Name'),
                      ),
                      TextField(
                        controller: _customerMobile,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Mobile Number'),
                      ),
                    ],
                    TextField(controller: _pickupLocation, decoration: const InputDecoration(labelText: 'Pickup Location')),
                    TextField(controller: _places, decoration: const InputDecoration(labelText: 'Places to Visit (comma separated)')),
                    TextField(controller: _days, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Number of Days')),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _pickPickupDateTime,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Pickup Date & Time',
                          suffixIcon: Icon(Icons.schedule),
                        ),
                        child: Text(dateLabel),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isWide)
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _driverId,
                              decoration: const InputDecoration(labelText: 'Select Driver'),
                              items: state.drivers
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d.id,
                                      child: Text('${d.name} (${d.phone})'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(() => _driverId = value),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _vehicleId,
                              decoration: const InputDecoration(labelText: 'Select Vehicle'),
                              items: state.vehicles
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v.id,
                                      child: Text(v.number),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(() => _vehicleId = value),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      DropdownButtonFormField<String>(
                        initialValue: _driverId,
                        decoration: const InputDecoration(labelText: 'Select Driver'),
                        items: state.drivers
                            .map(
                              (d) => DropdownMenuItem(
                                value: d.id,
                                child: Text('${d.name} (${d.phone})'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _driverId = value),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _vehicleId,
                        decoration: const InputDecoration(labelText: 'Select Vehicle'),
                        items: state.vehicles
                            .map(
                              (v) => DropdownMenuItem(
                                value: v.id,
                                child: Text(v.number),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _vehicleId = value),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _createTrip,
                      child: const Text('Schedule Trip'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (state.loading) const LinearProgressIndicator(),
          if (state.error != null) Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ...visibleTrips.map(
            (trip) => Card(
              child: ListTile(
                title: Text('${trip.customerName} • ${trip.pickupLocation}'),
                subtitle: Text(
                  'Contact: ${trip.customerMobile}\n'
                  'Driver: ${trip.driverName ?? '-'} | Vehicle: ${trip.vehicleNumber ?? '-'}\n'
                  'Status: ${trip.status} • Days: ${trip.numberOfDays} • Bata: ${trip.driverBataAssigned.toStringAsFixed(0)}',
                ),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    if ((role == 'owner' || role == 'employee') && trip.status != 'completed')
                      OutlinedButton(
                        onPressed: () => _assignBata(trip.id, trip.driverBataAssigned),
                        child: const Text('Assign Bata'),
                      ),
                    if (role == 'driver' && trip.status == 'scheduled')
                      OutlinedButton(
                        onPressed: () => _startTrip(trip.id),
                        child: const Text('Start'),
                      ),
                    if (role == 'driver' && trip.status == 'in_progress')
                      OutlinedButton(
                        onPressed: () => _endTrip(trip.id),
                        child: const Text('End'),
                      ),
                    OutlinedButton(
                      onPressed: () => ref.read(appStateProvider.notifier).addAdvance(trip.id, 1000),
                      child: const Text('Advance'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
