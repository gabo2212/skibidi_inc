import 'package:flutter/material.dart';

import '../services/app_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Session',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text('Email: ${user?.email ?? 'Unknown'}'),
                  const SizedBox(height: 8),
                  Text('Role: ${user?.role ?? 'Unknown'}'),
                  const SizedBox(height: 8),
                  Text(
                    'Preview mode: ${controller.isPreviewMode ? 'Yes' : 'No'}',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () async {
                      await controller.signOut();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    },
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
