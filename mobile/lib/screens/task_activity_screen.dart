import 'package:flutter/material.dart';

import '../services/app_controller.dart';

class TaskActivityScreen extends StatefulWidget {
  const TaskActivityScreen({
    super.key,
    required this.controller,
    required this.taskId,
  });

  final AppController controller;
  final String taskId;

  @override
  State<TaskActivityScreen> createState() => _TaskActivityScreenState();
}

class _TaskActivityScreenState extends State<TaskActivityScreen> {
  final _commentController = TextEditingController();
  final _blockedReasonController = TextEditingController();
  late String _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final task = widget.controller.tasks.firstWhere(
      (item) => item.taskId == widget.taskId,
    );
    _status = task.status;
    _blockedReasonController.text = task.blockedReason ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    _blockedReasonController.dispose();
    super.dispose();
  }

  Future<void> _saveStatus() async {
    setState(() => _busy = true);
    try {
      await widget.controller.updateTaskStatus(
        taskId: widget.taskId,
        status: _status,
        blockedReason: _blockedReasonController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Status updated.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update status: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.controller.addComment(
        taskId: widget.taskId,
        message: _commentController.text.trim(),
      );
      _commentController.clear();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comment added.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to add comment: $error')));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status and Comments')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'todo', child: Text('To do')),
              DropdownMenuItem(
                value: 'in_progress',
                child: Text('In progress'),
              ),
              DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
              DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
              DropdownMenuItem(
                value: 'changes_requested',
                child: Text('Changes requested'),
              ),
              DropdownMenuItem(value: 'validated', child: Text('Validated')),
            ],
            onChanged: (value) => setState(() => _status = value ?? 'todo'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _blockedReasonController,
            decoration: const InputDecoration(labelText: 'Blocked reason'),
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _busy ? null : _saveStatus,
            child: Text(_busy ? 'Saving...' : 'Update status'),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Add comment'),
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: _busy ? null : _addComment,
            child: const Text('Post comment'),
          ),
        ],
      ),
    );
  }
}
