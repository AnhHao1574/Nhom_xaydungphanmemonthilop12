import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    final user = auth.currentUser!;
    if (user.isAdminRoute) {
      return const AdminDashboardScreen();
    }
    return const HomeScreen();
  }
}
