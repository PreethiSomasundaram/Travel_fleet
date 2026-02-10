import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.loadToken();
  runApp(const TravelFleetApp());
}

/// Root widget for the Travel Fleet Management app.
class TravelFleetApp extends StatelessWidget {
  const TravelFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
