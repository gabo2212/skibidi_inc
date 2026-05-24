import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../widgets/task_tile.dart';
import 'task_detail_screen.dart';

class InstructorTaskListScreen extends StatelessWidget {
  const InstructorTaskListScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructor Task List')),
      body: RefreshIndicator(
        onRefresh: controller.loadTasks,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: controller.tasks
              .map(
                (task) => TaskTile(
                  task: task,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TaskDetailScreen(
                          controller: controller,
                          taskId: task.taskId,
                        ),
                      ),
                    );
                  },
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
