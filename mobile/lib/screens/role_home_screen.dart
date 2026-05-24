import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import 'instructor_dashboard_screen.dart';
import 'intern_dashboard_screen.dart';

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;
    if (user.isInstructor) {
      return InstructorDashboardScreen(controller: controller);
    }
    return InternDashboardScreen(controller: controller);
  }
}
