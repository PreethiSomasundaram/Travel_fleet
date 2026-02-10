import '../services/car_service.dart';

/// Alert item shown on the Owner dashboard.
class AlertItem {
  final String title;
  final String message;
  final AlertSeverity severity;

  AlertItem({required this.title, required this.message, required this.severity});
}

enum AlertSeverity { warning, critical }

/// Service that generates alerts for the owner's home screen.
class NotificationService {
  final _carService = CarService();

  /// Returns a list of alerts for expired / near-expiry docs and service KM.
  Future<List<AlertItem>> getAlerts() async {
    final cars = await _carService.getAllCars();
    final alerts = <AlertItem>[];

    for (final car in cars) {
      // FC Expiry
      if (_carService.isExpired(car.fcExpiryDate)) {
        alerts.add(AlertItem(
          title: '${car.vehicleNumber} – FC Expired',
          message: 'FC expired on ${car.fcExpiryDate}',
          severity: AlertSeverity.critical,
        ));
      } else if (_carService.isNearExpiry(car.fcExpiryDate)) {
        alerts.add(AlertItem(
          title: '${car.vehicleNumber} – FC Expiring Soon',
          message: 'FC expires on ${car.fcExpiryDate}',
          severity: AlertSeverity.warning,
        ));
      }

      // Insurance Expiry
      if (_carService.isExpired(car.insuranceExpiryDate)) {
        alerts.add(AlertItem(
          title: '${car.vehicleNumber} – Insurance Expired',
          message: 'Insurance expired on ${car.insuranceExpiryDate}',
          severity: AlertSeverity.critical,
        ));
      } else if (_carService.isNearExpiry(car.insuranceExpiryDate)) {
        alerts.add(AlertItem(
          title: '${car.vehicleNumber} – Insurance Expiring Soon',
          message: 'Insurance expires on ${car.insuranceExpiryDate}',
          severity: AlertSeverity.warning,
        ));
      }

      // PUC Expiry
      if (_carService.isExpired(car.pucExpiryDate)) {
        alerts.add(AlertItem(
          title: '${car.vehicleNumber} – PUC Expired',
          message: 'PUC expired on ${car.pucExpiryDate}',
          severity: AlertSeverity.critical,
        ));
      } else if (_carService.isNearExpiry(car.pucExpiryDate)) {
        alerts.add(AlertItem(
          title: '${car.vehicleNumber} – PUC Expiring Soon',
          message: 'PUC expires on ${car.pucExpiryDate}',
          severity: AlertSeverity.warning,
        ));
      }

      // Service KM
      if (_carService.isNearService(car)) {
        final remaining = car.nextServiceKm - car.currentKm;
        alerts.add(AlertItem(
          title: '${car.vehicleNumber} – Service Due',
          message: '${remaining.toStringAsFixed(0)} km remaining to next service',
          severity: AlertSeverity.warning,
        ));
      }
    }

    return alerts;
  }
}
