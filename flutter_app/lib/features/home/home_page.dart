import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  double _driverEarnings(dynamic driver) {
    final salaryFromDays = driver.totalWorkingDays * driver.salaryPerDay;
    final salaryFromHours = driver.totalWorkingHours * (driver.salaryPerDay / 8);
    final tripSalary = driver.totalTripsCompleted * driver.salaryPerTrip;
    return (salaryFromDays > salaryFromHours ? salaryFromDays : salaryFromHours) + tripSalary + driver.totalBataEarned;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final app = ref.read(appStateProvider.notifier);
      await Future.wait([
        app.fetchTrips(),
        app.fetchBills(),
        app.fetchVehicles(),
        app.fetchDrivers(),
        app.fetchPayments(),
        app.fetchNotifications(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final myDriver = state.drivers.where((d) => d.loginEmail != null && d.loginEmail == auth.email).cast<dynamic>().toList();
    final hasDriverProfile = myDriver.isNotEmpty;
    final earning = hasDriverProfile ? _driverEarnings(myDriver.first) : 0.0;

    return RefreshIndicator(
      onRefresh: () async {
        final app = ref.read(appStateProvider.notifier);
        await Future.wait([
          app.fetchTrips(),
          app.fetchBills(),
          app.fetchVehicles(),
          app.fetchDrivers(),
          app.fetchPayments(),
          app.fetchNotifications(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Welcome, ${auth.name ?? 'User'}', style: theme.textTheme.headlineSmall),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatTile(title: 'Trips', value: state.trips.length.toString(), icon: Icons.route_outlined),
              if (auth.role != 'driver')
                _StatTile(title: 'Bills', value: state.bills.length.toString(), icon: Icons.receipt_long_outlined),
              _StatTile(title: 'Vehicles', value: state.vehicles.length.toString(), icon: Icons.directions_car_outlined),
              _StatTile(title: 'Drivers', value: state.drivers.length.toString(), icon: Icons.badge_outlined),
              _StatTile(title: 'Payments', value: state.payments.length.toString(), icon: Icons.payments_outlined),
              if (auth.role == 'driver')
                _StatTile(
                  title: 'My Earnings',
                  value: earning.toStringAsFixed(0),
                  icon: Icons.currency_rupee,
                ),
              _StatTile(
                title: 'Unread Alerts',
                value: state.notifications.where((n) => !n.isRead).length.toString(),
                icon: Icons.notifications_none,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tileWidth = width > 640 ? (width - 68) / 2 : width - 32;

    return SizedBox(
      width: tileWidth,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 3),
                    Text(value, style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
