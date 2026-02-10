import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/summary_tile.dart';

/// Employee dashboard – can add bookings, assign car/driver, enter advances.
class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final _tripService = TripService();
  int _tripCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final trips = await _tripService.getAllTrips();
    setState(() {
      _tripCount = trips.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)?.settings.arguments as UserModel?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.login),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Welcome, ${user.name}',
                        style: AppTheme.heading,
                      ),
                    ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [
                      SummaryTile(
                        label: 'Total Trips',
                        value: '$_tripCount',
                        icon: Icons.map,
                        color: Colors.green,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.tripList),
                      ),
                      SummaryTile(
                        label: 'New Booking',
                        value: '+',
                        icon: Icons.add_circle_outline,
                        color: Colors.blue,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.tripForm),
                      ),
                      SummaryTile(
                        label: 'Cars',
                        value: '→',
                        icon: Icons.directions_car,
                        color: Colors.teal,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.carDashboard),
                      ),
                      SummaryTile(
                        label: 'Billing',
                        value: '→',
                        icon: Icons.receipt_long,
                        color: Colors.orange,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.billing),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
