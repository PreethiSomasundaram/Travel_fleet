import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';

/// Lists all trips with status indicators.
class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  final _tripService = TripService();
  List<TripModel> _trips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trips = await _tripService.getAllTrips();
    setState(() {
      _trips = trips;
      _loading = false;
    });
  }

  Color _statusColor(String s, ColorScheme cs) {
    switch (s) {
      case 'started':
        return cs.primary;
      case 'ended':
        return cs.tertiary;
      default:
        return cs.onSurface.withOpacity(0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.tripForm,
        ).then((_) => _load()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _trips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 64,
                            color: cs.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No trips yet',
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _trips.length,
                      itemBuilder: (context, i) {
                        final trip = _trips[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(trip.status, cs),
                              child: Text(
                                trip.status[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(trip.placesToVisit),
                            subtitle: Text(
                              '${trip.pickupDate} • ${trip.pickupLocation}\n'
                              '${trip.numberOfDays} day(s)',
                            ),
                            isThreeLine: true,
                            trailing: trip.status == 'ended'
                                ? IconButton(
                                    icon: Icon(
                                      Icons.receipt_long,
                                      color: cs.secondary,
                                    ),
                                    tooltip: 'Generate Bill',
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.billing,
                                      arguments: trip,
                                    ),
                                  )
                                : null,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.tripForm,
                              arguments: trip,
                            ).then((_) => _load()),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
