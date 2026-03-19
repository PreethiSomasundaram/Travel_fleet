import 'package:flutter/material.dart';

import '../features/auth/login_page.dart';
import '../features/dashboard/dashboard_page.dart';

class AppRouter {
  static const login = '/login';
  static const dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
