import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../../services/car_service.dart';
import '../../services/trip_service.dart';
import '../../services/billing_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';
import '../../widgets/summary_tile.dart';

/// Owner dashboard – full access to all data and alerts.
class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final _carService = CarService();
  final _tripService = TripService();
  final _billingService = BillingService();
  final _notificationService = NotificationService();

  int _carCount = 0;
  int _tripCount = 0;
  int _billCount = 0;
  List<AlertItem> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cars = await _carService.getAllCars();
    final trips = await _tripService.getAllTrips();
    final bills = await _billingService.getAllBills();
    final alerts = await _notificationService.getAlerts();

    setState(() {
      _carCount = cars.length;
      _tripCount = trips.length;
      _billCount = bills.length;
      _alerts = alerts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)?.settings.arguments as UserModel?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
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

                  // ── Summary Tiles ──────────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [
                      SummaryTile(
                        label: 'Cars',
                        value: '$_carCount',
                        icon: Icons.directions_car,
                        color: Colors.blue,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.carDashboard),
                      ),
                      SummaryTile(
                        label: 'Trips',
                        value: '$_tripCount',
                        icon: Icons.map,
                        color: Colors.green,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.tripList),
                      ),
                      SummaryTile(
                        label: 'Bills',
                        value: '$_billCount',
                        icon: Icons.receipt_long,
                        color: Colors.orange,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.billing),
                      ),
                      SummaryTile(
                        label: 'Alerts',
                        value: '${_alerts.length}',
                        icon: Icons.warning_amber_rounded,
                        color: _alerts.isEmpty ? Colors.grey : Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Quick Actions ──────────────────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _actionChip(Icons.payment, 'Payments', AppRoutes.payments),
                      _actionChip(Icons.event_busy, 'Leaves', AppRoutes.leaves),
                      _actionChip(Icons.people, 'Drivers', AppRoutes.driverPayroll),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Alerts ─────────────────────────────────────────────
                  if (_alerts.isNotEmpty) ...[
                    const Text('⚠️ Alerts', style: AppTheme.subHeading),
                    const SizedBox(height: 8),
                    ..._alerts.map(
                      (a) => Card(
                        color: a.severity == AlertSeverity.critical
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                        child: ListTile(
                          leading: Icon(
                            a.severity == AlertSeverity.critical
                                ? Icons.error
                                : Icons.warning,
                            color: a.severity == AlertSeverity.critical
                                ? Colors.red
                                : Colors.orange,
                          ),
                          title: Text(a.title),
                          subtitle: Text(a.message),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _actionChip(IconData icon, String label, String route) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => Navigator.pushNamed(context, route),
    );
  }
}
