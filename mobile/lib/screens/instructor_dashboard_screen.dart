import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../widgets/info_banner.dart';
import '../widgets/section_card.dart';
import 'ai_generate_task_screen.dart';
import 'create_task_screen.dart';
import 'instructor_task_list_screen.dart';
import 'settings_screen.dart';

class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final tasks = controller.tasks;
    final assignedCount = tasks
        .where((task) => task.assignedTo.isNotEmpty)
        .length;
    final inProgressCount = tasks
        .where((task) => task.status == 'in_progress')
        .length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
        actions: <Widget>[
          IconButton(
            onPressed: () => controller.loadTasks(),
            icon: const Icon(Icons.refresh),
          ),
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
            'Welcome back, ${controller.currentUser?.displayName ?? 'Instructor'}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (controller.isPreviewMode)
            const InfoBanner(
              message:
                  'The app is showing a local preview because AWS outputs are not filled in yet. Once Terraform is deployed, rerun the export script and the same UI will call Cognito and API Gateway.',
            ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: SectionCard(
                  title: '$assignedCount assigned',
                  subtitle: 'Tasks currently linked to interns',
                  child: const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SectionCard(
                  title: '$inProgressCount in progress',
                  subtitle: 'Tasks actively moving forward',
                  child: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          SectionCard(
            title: 'Quick actions',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CreateTaskScreen(controller: controller),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_task),
                  label: const Text('Create task'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            AiGenerateTaskScreen(controller: controller),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate with AI'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            InstructorTaskListScreen(controller: controller),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Open task list'),
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Project status',
            subtitle:
                'This summary is tuned for demo screenshots and teacher walkthroughs.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Total tasks: ${tasks.length}'),
                const SizedBox(height: 8),
                Text(
                  'Bedrock drafts ready: ${controller.generatedDrafts.length}',
                ),
                const SizedBox(height: 8),
                Text(
                  controller.isPreviewMode
                      ? 'Authentication mode: local preview'
                      : 'Authentication mode: Cognito user pool',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
