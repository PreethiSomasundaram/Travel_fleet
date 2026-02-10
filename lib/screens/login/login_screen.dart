import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/user_service.dart';
import '../../widgets/input_field.dart';

/// Login screen – authenticates user and routes to the correct dashboard.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _userService = UserService();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final user = await _userService.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
    setState(() => _loading = false);

    if (!mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
      return;
    }

    // Route based on role
    String route;
    switch (user.role) {
      case AppConstants.roleOwner:
        route = AppRoutes.ownerDashboard;
        break;
      case AppConstants.roleEmployee:
        route = AppRoutes.employeeDashboard;
        break;
      case AppConstants.roleDriver:
        route = AppRoutes.driverDashboard;
        break;
      default:
        route = AppRoutes.login;
    }

    Navigator.pushReplacementNamed(context, route, arguments: user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_bus, size: 80, color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                Text(AppConstants.appName, style: AppTheme.heading),
                const SizedBox(height: 8),
                const Text('Fleet Management', style: AppTheme.body),
                const SizedBox(height: 40),
                InputField(
                  label: 'Username',
                  controller: _usernameCtrl,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter username' : null,
                ),
                InputField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
