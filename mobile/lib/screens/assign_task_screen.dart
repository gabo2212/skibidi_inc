import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../services/app_controller.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({
    super.key,
    required this.controller,
    required this.task,
  });

  final AppController controller;
  final TaskItem task;

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  late final TextEditingController _internIdController;
  late final TextEditingController _internNameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _internIdController = TextEditingController(text: widget.task.assignedTo);
    _internNameController = TextEditingController(
      text: widget.task.assignedToName,
    );
  }

  @override
  void dispose() {
    _internIdController.dispose();
    _internNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.controller.assignTask(
        taskId: widget.task.taskId,
        assignedTo: _internIdController.text.trim(),
        assignedToName: _internNameController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to assign task: $error')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Task')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _internIdController,
              decoration: const InputDecoration(
                labelText: 'Intern user ID or email',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _internNameController,
              decoration: const InputDecoration(labelText: 'Intern name'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_saving ? 'Assigning...' : 'Assign task'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
