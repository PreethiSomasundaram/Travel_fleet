import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../billing/billing_page.dart';
import '../drivers/drivers_page.dart';
import '../home/home_page.dart';
import '../notifications/notifications_page.dart';
import '../payments/payments_page.dart';
import '../settings/settings_page.dart';
import '../trips/trips_page.dart';
import '../users/users_page.dart';
import '../vehicles/vehicles_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _index = 0;

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;

    final menuItems = [
      const _MenuItem(label: 'Home', icon: Icons.home_outlined, page: HomePage()),
      const _MenuItem(label: 'Trips', icon: Icons.route_outlined, page: TripsPage()),
      const _MenuItem(label: 'Billing', icon: Icons.receipt_long_outlined, page: BillingPage()),
      const _MenuItem(label: 'Vehicles', icon: Icons.directions_car_outlined, page: VehiclesPage()),
      const _MenuItem(label: 'Drivers', icon: Icons.badge_outlined, page: DriversPage()),
      const _MenuItem(label: 'Payments', icon: Icons.payments_outlined, page: PaymentsPage()),
      const _MenuItem(label: 'Alerts', icon: Icons.notifications_none, page: NotificationsPage()),
      const _MenuItem(label: 'Settings', icon: Icons.settings_outlined, page: SettingsPage()),
      if (auth.role == 'owner') const _MenuItem(label: 'Users', icon: Icons.group_outlined, page: UsersPage()),
    ];

    if (_index >= menuItems.length) {
      _index = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Fleet • ${auth.role ?? 'Guest'}'),
      ),
      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(auth.name ?? 'Travel Fleet', style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(auth.emailOrRoleLabel),
                      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: menuItems.length,
                        itemBuilder: (context, i) {
                          final item = menuItems[i];
                          return ListTile(
                            leading: Icon(item.icon),
                            title: Text(item.label),
                            selected: _index == i,
                            onTap: () {
                              setState(() => _index = i);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _index,
              labelType: NavigationRailLabelType.all,
              minWidth: 92,
              onDestinationSelected: (value) => setState(() => _index = value),
              leading: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CircleAvatar(
                  child: Text((auth.name ?? 'U').substring(0, 1).toUpperCase()),
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IconButton(
                  tooltip: 'Logout',
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                ),
              ),
                destinations: menuItems
                  .map((item) => NavigationRailDestination(icon: Icon(item.icon), label: Text(item.label)))
                  .toList(),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: Padding(
                key: ValueKey(_index),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: menuItems[_index].page,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({required this.label, required this.icon, required this.page});

  final String label;
  final IconData icon;
  final Widget page;
}

extension on AuthState {
  String get emailOrRoleLabel {
    final r = role ?? 'employee';
    return r[0].toUpperCase() + r.substring(1);
  }
}
