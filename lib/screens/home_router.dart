import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'staff/staff_dashboard_screen.dart';
import 'customer/customer_dashboard_screen.dart';

class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!auth.isLoggedIn) {
      // Not authenticated: let MainApp show LoginScreen
      return const SizedBox.shrink();
    }
    // If role hasn't loaded yet, show a lightweight loading indicator
    if (auth.role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Route by role
  return auth.role == 'staff'
    ? const StaffDashboardScreen()
    : const CustomerDashboardScreen();
  }
}
