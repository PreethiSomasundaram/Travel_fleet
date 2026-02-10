import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/trip_service.dart';
import '../../services/bata_config.dart';
import '../../services/car_service.dart';

/// Driver payroll / work summary screen.
///
/// Shows each driver's total trips, working days, and bata earned.
class DriverPayrollScreen extends StatefulWidget {
  const DriverPayrollScreen({super.key});

  @override
  State<DriverPayrollScreen> createState() => _DriverPayrollScreenState();
}

class _DriverPayrollScreenState extends State<DriverPayrollScreen> {
  final _userService = UserService();
  final _tripService = TripService();
  final _bataConfig = BataConfigService();
  final _carService = CarService();

  List<_DriverSummary> _summaries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final drivers = await _userService.getUsersByRole(AppConstants.roleDriver);
    final bataMap = await _bataConfig.getAllBataConfigs();
    final summaries = <_DriverSummary>[];

    for (final driver in drivers) {
      final trips = await _tripService.getTripsForDriver(driver.id!);
      final endedTrips = trips.where((t) => t.status == 'ended').toList();

      int totalDays = 0;
      double totalBata = 0;

      for (final trip in endedTrips) {
        totalDays += trip.numberOfDays;
        // Look up car type to calculate bata
        if (trip.carId != null) {
          final car = await _carService.getCarById(trip.carId!);
          if (car != null) {
            final rate = bataMap[car.vehicleType] ?? 0;
            totalBata += rate * trip.numberOfDays;
          }
        }
      }

      summaries.add(_DriverSummary(
        driver: driver,
        totalTrips: endedTrips.length,
        totalDays: totalDays,
        totalBata: totalBata,
      ));
    }

    setState(() {
      _summaries = summaries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Payroll')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _summaries.isEmpty
              ? const Center(child: Text('No drivers found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _summaries.length,
                  itemBuilder: (context, i) {
                    final s = _summaries[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.driver.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Phone: ${s.driver.phone}',
                                style: const TextStyle(color: Colors.grey)),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _stat('Trips', '${s.totalTrips}'),
                                _stat('Days', '${s.totalDays}'),
                                _stat('Bata', '₹${s.totalBata.toStringAsFixed(0)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _stat(String label, String value) => Column(
    children: [
      Text(value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );
}

class _DriverSummary {
  final UserModel driver;
  final int totalTrips;
  final int totalDays;
  final double totalBata;

  _DriverSummary({
    required this.driver,
    required this.totalTrips,
    required this.totalDays,
    required this.totalBata,
  });
}
