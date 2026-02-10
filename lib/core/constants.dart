/// Application-wide constants for Travel Fleet Management.
///
/// No hard-coded values in screens – all configurable values live here.
library;

class AppConstants {
  AppConstants._();

  // ── App Meta ──────────────────────────────────────────────────────────────
  static const String appName = 'Travel Fleet';
  static const String appVersion = '1.0.0';

  // ── User Roles ────────────────────────────────────────────────────────────
  static const String roleOwner = 'owner';
  static const String roleEmployee = 'employee';
  static const String roleDriver = 'driver';

  // ── Vehicle Types ─────────────────────────────────────────────────────────
  static const List<String> vehicleTypes = [
    'Sedan',
    'MPV',
    'SUV',
    'Tempo Traveller',
    'Bus',
  ];

  // ── Rent Types ────────────────────────────────────────────────────────────
  static const String rentTypeDay = 'day';
  static const String rentTypeHour = 'hour';

  // ── Trip Statuses ─────────────────────────────────────────────────────────
  static const String tripCreated = 'created';
  static const String tripStarted = 'started';
  static const String tripEnded = 'ended';

  // ── Payment Statuses ──────────────────────────────────────────────────────
  static const String paymentPaid = 'paid';
  static const String paymentPending = 'pending';

  // ── Leave Types ───────────────────────────────────────────────────────────
  static const String leaveFullDay = 'full_day';
  static const String leaveHalfDay = 'half_day';

  // ── Leave Statuses ────────────────────────────────────────────────────────
  static const String leavePending = 'pending';
  static const String leaveApproved = 'approved';
  static const String leaveRejected = 'rejected';

  // ── Advance Types ─────────────────────────────────────────────────────────
  static const String advanceBooking = 'booking';
  static const String advanceFuel = 'fuel';

  // ── Alert Thresholds ──────────────────────────────────────────────────────
  /// Number of days before an expiry date to show a warning.
  static const int expiryWarningDays = 15;

  /// KM remaining to next service to show a warning.
  static const int serviceWarningKm = 300;
}
