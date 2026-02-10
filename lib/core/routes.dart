import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';
import '../screens/owner/owner_dashboard.dart';
import '../screens/employee/employee_dashboard.dart';
import '../screens/driver/driver_dashboard.dart';
import '../screens/car/car_dashboard.dart';
import '../screens/car/car_form_screen.dart';
import '../screens/trip/trip_list_screen.dart';
import '../screens/trip/trip_form_screen.dart';
import '../screens/trip/trip_start_screen.dart';
import '../screens/trip/trip_end_screen.dart';
import '../screens/billing/billing_screen.dart';
import '../screens/billing/bill_detail_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/leave/leave_screen.dart';
import '../screens/driver/driver_payroll_screen.dart';

/// Named routes for the application.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String ownerDashboard = '/owner';
  static const String employeeDashboard = '/employee';
  static const String driverDashboard = '/driver';
  static const String carDashboard = '/cars';
  static const String carForm = '/cars/form';
  static const String tripList = '/trips';
  static const String tripForm = '/trips/form';
  static const String tripStart = '/trips/start';
  static const String tripEnd = '/trips/end';
  static const String billing = '/billing';
  static const String billDetail = '/billing/detail';
  static const String payments = '/payments';
  static const String leaves = '/leaves';
  static const String driverPayroll = '/driver/payroll';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    ownerDashboard: (_) => const OwnerDashboard(),
    employeeDashboard: (_) => const EmployeeDashboard(),
    driverDashboard: (_) => const DriverDashboard(),
    carDashboard: (_) => const CarDashboard(),
    carForm: (_) => const CarFormScreen(),
    tripList: (_) => const TripListScreen(),
    tripForm: (_) => const TripFormScreen(),
    tripStart: (_) => const TripStartScreen(),
    tripEnd: (_) => const TripEndScreen(),
    billing: (_) => const BillingScreen(),
    billDetail: (_) => const BillDetailScreen(),
    payments: (_) => const PaymentScreen(),
    leaves: (_) => const LeaveScreen(),
    driverPayroll: (_) => const DriverPayrollScreen(),
  };
}
