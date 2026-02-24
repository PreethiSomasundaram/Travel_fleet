import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../../services/car_service.dart';
import '../../services/trip_service.dart';
import '../../services/billing_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';
import '../../widgets/enhanced_card.dart';
import '../../widgets/alert_card.dart' as alert_widget;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
                      'Welcome back, ${user.name}',
                      style: AppTheme.heading.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Owner • Fleet Management Dashboard',
                      style: AppTheme.bodySmall.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Summary Cards ──────────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      EnhancedCard(
                        title: 'Active Vehicles',
                        value: '$_carCount',
                        icon: Icons.directions_car,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.carDashboard,
                        ),
                      ),
                      EnhancedCard(
                        title: 'Total Trips',
                        value: '$_tripCount',
                        icon: Icons.map,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.tripList),
                      ),
                      EnhancedCard(
                        title: 'Pending Bills',
                        value: '$_billCount',
                        icon: Icons.receipt_long,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.billing),
                      ),
                      EnhancedCard(
                        title: 'Active Alerts',
                        value: '${_alerts.length}',
                        icon: Icons.notifications_active,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Quick Actions ──────────────────────────────────────
                  Text(
                    'Quick Actions',
                    style: AppTheme.subHeading.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionButton(
                          context,
                          Icons.payment,
                          'Payments',
                          AppRoutes.payments,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          context,
                          Icons.event_busy,
                          'Leave Requests',
                          AppRoutes.leaves,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          context,
                          Icons.people,
                          'Driver Management',
                          AppRoutes.driverPayroll,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          context,
                          Icons.settings,
                          'Settings',
                          AppRoutes.login,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Alerts Section ─────────────────────────────────────
                  if (_alerts.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Active Alerts',
                          style: AppTheme.subHeading.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._alerts.map((a) {
                      final severity = a.severity == AlertSeverity.critical
                          ? alert_widget.AlertSeverity.critical
                          : a.severity == AlertSeverity.warning
                          ? alert_widget.AlertSeverity.warning
                          : alert_widget.AlertSeverity.info;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: alert_widget.AlertCard(
                          title: a.title,
                          message: a.message,
                          severity: severity,
                        ),
                      );
                    }),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'All Systems Operational',
                            style: AppTheme.subHeading.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No active alerts. Your fleet is running smoothly.',
                            style: AppTheme.bodySmall.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 140,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(icon, size: 20),
        label: Text(label, textAlign: TextAlign.center),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
      ),
    );
  }
}
