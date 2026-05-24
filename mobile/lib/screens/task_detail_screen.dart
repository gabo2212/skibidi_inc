import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../services/app_controller.dart';
import '../widgets/section_card.dart';
import 'assign_task_screen.dart';
import 'proof_upload_screen.dart';
import 'task_activity_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({
    super.key,
    required this.controller,
    required this.taskId,
  });

  final AppController controller;
  final String taskId;

  @override
  Widget build(BuildContext context) {
    final TaskItem task = controller.tasks.firstWhere(
      (item) => item.taskId == taskId,
    );
    final user = controller.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            task.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Chip(label: Text(task.status)),
              Chip(label: Text(task.priority)),
              Chip(label: Text(task.category)),
            ],
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Overview',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(task.description),
                const SizedBox(height: 12),
                Text(
                  'Assigned to: ${task.assignedToName.isEmpty ? 'Not assigned yet' : task.assignedToName}',
                ),
                const SizedBox(height: 8),
                Text('Deliverable: ${task.deliverable}'),
                const SizedBox(height: 8),
                Text('Validation: ${task.validationCriteria}'),
                const SizedBox(height: 8),
                Text(
                  'Deadline: ${task.deadline.isEmpty ? 'Not set' : task.deadline}',
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Actions',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                if (user.isInstructor)
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AssignTaskScreen(
                            controller: controller,
                            task: task,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Assign task'),
                  ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TaskActivityScreen(
                          controller: controller,
                          taskId: task.taskId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.sync_alt),
                  label: const Text('Status and comments'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProofUploadScreen(
                          controller: controller,
                          taskId: task.taskId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload proof'),
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Comments',
            child: Column(
              children: task.comments.isEmpty
                  ? const <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('No comments yet.'),
                      ),
                    ]
                  : task.comments
                        .map(
                          (comment) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(comment.authorName),
                            subtitle: Text(comment.message),
                            trailing: Text(comment.createdAt.split('T').first),
                          ),
                        )
                        .toList(growable: false),
            ),
          ),
          SectionCard(
            title: 'Attachments',
            child: Column(
              children: task.attachments.isEmpty
                  ? const <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('No proof files uploaded yet.'),
                      ),
                    ]
                  : task.attachments
                        .map(
                          (attachment) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(attachment.fileName),
                            subtitle: Text(attachment.contentType),
                          ),
                        )
                        .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}
