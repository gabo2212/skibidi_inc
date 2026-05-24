import 'package:flutter/material.dart';

import '../models/task_item.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onTap});

  final TaskItem task;
  final VoidCallback onTap;

  Color _priorityColor() {
    switch (task.priority) {
      case 'urgent':
        return const Color(0xFF991B1B);
      case 'high':
        return const Color(0xFFB45309);
      case 'medium':
        return const Color(0xFF0369A1);
      default:
        return const Color(0xFF166534);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor();
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(18),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  Chip(label: Text(task.status)),
                  Chip(
                    label: Text(task.priority),
                    backgroundColor: priorityColor.withAlpha(36),
                    labelStyle: TextStyle(color: priorityColor),
                  ),
                  if (task.assignedToName.isNotEmpty)
                    Chip(label: Text('Assigned: ${task.assignedToName}')),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
