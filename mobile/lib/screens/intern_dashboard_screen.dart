import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../widgets/section_card.dart';
import 'intern_task_list_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class InternDashboardScreen extends StatelessWidget {
  const InternDashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final tasks = controller.tasks;
    final doneCount = tasks.where((task) => task.status == 'validated').length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intern Dashboard'),
        actions: <Widget>[
          IconButton(
            onPressed: () => controller.loadTasks(),
            icon: const Icon(Icons.refresh),
          ),
          _NotificationsButton(controller: controller),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsScreen(controller: controller),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'Hello, ${controller.currentUser?.displayName ?? 'Intern'}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: SectionCard(
                  title: '${tasks.length} assigned',
                  subtitle: 'Tasks visible to this intern',
                  child: const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SectionCard(
                  title: '$doneCount validated',
                  subtitle: 'Work already approved',
                  child: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          SectionCard(
            title: 'Your next steps',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Open your assigned tasks, update status, and upload proof files from the same workflow.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            InternTaskListScreen(controller: controller),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('View assigned tasks'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final unread = controller.unreadNotificationCount;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NotificationsScreen(controller: controller),
              ),
            );
          },
          icon: const Icon(Icons.notifications_outlined),
        ),
        if (unread > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
