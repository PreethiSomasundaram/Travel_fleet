import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../models/user_model.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../../services/user_service.dart';

/// Driver dashboard – view assigned trips, start/end trips, apply leave.
class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final _tripService = TripService();
  List<TripModel> _myTrips = [];
  bool _loading = true;
  UserModel? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _user = ModalRoute.of(context)?.settings.arguments as UserModel?;
    if (_user != null) _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (_user == null) return;
    final trips = await _tripService.getTripsForDriver(_user!.id!);
    setState(() {
      _myTrips = trips;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_busy),
            tooltip: 'Leaves',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.leaves,
              arguments: _user,
            ),
          ),
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
              onRefresh: _loadTrips,
              child: _myTrips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.route,
                            size: 64,
                            color: cs.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No trips assigned',
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _myTrips.length,
                      itemBuilder: (context, index) {
                        final trip = _myTrips[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              _statusIcon(trip.status),
                              color: _statusColor(trip.status, cs),
                            ),
                            title: Text(trip.placesToVisit),
                            subtitle: Text(
                              '${trip.pickupDate} • ${trip.pickupLocation}\n'
                              'Status: ${trip.status.toUpperCase()}',
                            ),
                            isThreeLine: true,
                            trailing: _tripAction(trip, cs),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget? _tripAction(TripModel trip, ColorScheme cs) {
    if (trip.status == 'created') {
      return ElevatedButton(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.tripStart,
          arguments: trip,
        ).then((_) => _loadTrips()),
        child: const Text('Start'),
      );
    } else if (trip.status == 'started') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: Colors.white,
        ),
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.tripEnd,
          arguments: trip,
        ).then((_) => _loadTrips()),
        child: const Text('End'),
      );
    }
    return Icon(Icons.check_circle, color: cs.tertiary);
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'started':
        return Icons.play_circle_fill;
      case 'ended':
        return Icons.check_circle;
      default:
        return Icons.schedule;
    }
  }

  Color _statusColor(String status, ColorScheme cs) {
    switch (status) {
      case 'started':
        return cs.primary;
      case 'ended':
        return cs.tertiary;
      default:
        return cs.onSurface.withOpacity(0.4);
    }
  }
}
