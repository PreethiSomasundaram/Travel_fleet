import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../models/user_model.dart';
import '../../services/trip_service.dart';
import '../../services/user_service.dart';
import '../../widgets/enhanced_card.dart';

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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await UserService().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (user != null) ...[
                    Text(
                      'Welcome, ${user.name}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage trips, cars and billing',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.1,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      EnhancedCard(
                        title: 'Total Trips',
                        value: '$_tripCount',
                        icon: Icons.map_outlined,
                        backgroundColor: cs.tertiary.withOpacity(0.1),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.tripList),
                      ),
                      EnhancedCard(
                        title: 'New Booking',
                        value: '+',
                        icon: Icons.add_circle_outline,
                        backgroundColor: cs.primary.withOpacity(0.1),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.tripForm),
                      ),
                      EnhancedCard(
                        title: 'Cars',
                        value: '→',
                        icon: Icons.directions_car_outlined,
                        backgroundColor: cs.secondary.withOpacity(0.1),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.carDashboard,
                        ),
                      ),
                      EnhancedCard(
                        title: 'Billing',
                        value: '→',
                        icon: Icons.receipt_long_outlined,
                        backgroundColor: const Color(
                          0xFFF59E0B,
                        ).withOpacity(0.1),
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
