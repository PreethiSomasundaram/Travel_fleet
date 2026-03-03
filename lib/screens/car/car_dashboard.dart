import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../widgets/info_card.dart';

/// Lists all cars with colour-coded alerts for expiry / service.
class CarDashboard extends StatefulWidget {
  const CarDashboard({super.key});

  @override
  State<CarDashboard> createState() => _CarDashboardState();
}

class _CarDashboardState extends State<CarDashboard> {
  final _carService = CarService();
  List<CarModel> _cars = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cars = await _carService.getAllCars();
    setState(() {
      _cars = cars;
      _loading = false;
    });
  }

  Color? _alertColor(CarModel car) {
    if (_carService.isExpired(car.fcExpiryDate) ||
        _carService.isExpired(car.insuranceExpiryDate) ||
        _carService.isExpired(car.pucExpiryDate)) {
      return const Color(0xFFEF4444); // error red
    }
    if (_carService.isNearExpiry(car.fcExpiryDate) ||
        _carService.isNearExpiry(car.insuranceExpiryDate) ||
        _carService.isNearExpiry(car.pucExpiryDate) ||
        _carService.isNearService(car)) {
      return const Color(0xFFF59E0B); // warning amber
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Car Management')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.carForm,
        ).then((_) => _load()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _cars.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 64,
                            color: cs.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No cars added yet',
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _cars.length,
                      itemBuilder: (context, i) {
                        final car = _cars[i];
                        return InfoCard(
                          title: '${car.vehicleNumber} (${car.vehicleType})',
                          borderColor: _alertColor(car),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.carForm,
                            arguments: car,
                          ).then((_) => _load()),
                          items: [
                            MapEntry(
                              'Current KM',
                              car.currentKm.toStringAsFixed(0),
                            ),
                            MapEntry(
                              'Next Service',
                              car.nextServiceKm.toStringAsFixed(0),
                            ),
                            MapEntry('FC Expiry', car.fcExpiryDate),
                            MapEntry('Insurance', car.insuranceExpiryDate),
                            MapEntry('PUC Expiry', car.pucExpiryDate),
                          ],
                        );
                      },
                    ),
            ),
    );
  }
}
