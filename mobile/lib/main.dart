import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'screens/login_screen.dart';
import 'screens/role_home_screen.dart';
import 'services/api_service.dart';
import 'services/app_controller.dart';
import 'services/auth_service.dart';
import 'theme/newsprint_theme.dart';
import 'widgets/newsprint_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootstrapApp());
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  AppController? _controller;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final config = await AppConfig.load();
      final controller = AppController(
        config: config,
        authService: AuthService(),
        apiService: ApiService(config: config),
      );
      await controller.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _controller = controller;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Unable to load app configuration: $_loadError'),
            ),
          ),
        ),
      );
    }
    final controller = _controller;
    if (controller == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return InternTaskApp(controller: controller);
  }
}

class InternTaskApp extends StatelessWidget {
  const InternTaskApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'InternTask AI Cloud',
          debugShowCheckedModeBanner: false,
          theme: NewsprintTheme.build(),
          builder: (context, child) =>
              NewsprintBackground(child: child ?? const SizedBox.shrink()),
          home: controller.isSignedIn
              ? RoleHomeScreen(controller: controller)
              : LoginScreen(controller: controller),
        );
      },
    );
  }
}
