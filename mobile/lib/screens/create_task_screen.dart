import 'package:flutter/material.dart';

import '../models/task_draft.dart';
import '../services/app_controller.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({
    super.key,
    required this.controller,
    this.initialDraft,
  });

  final AppController controller;
  final TaskDraft? initialDraft;

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _deadlineController;
  late final TextEditingController _deliverableController;
  late final TextEditingController _validationController;
  late final TextEditingController _assignedToController;
  late final TextEditingController _assignedToNameController;
  String _priority = 'medium';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _titleController = TextEditingController(text: draft?.title ?? '');
    _descriptionController = TextEditingController(
      text: draft?.description ?? '',
    );
    _categoryController = TextEditingController(text: draft?.category ?? '');
    _deadlineController = TextEditingController(text: draft?.deadline ?? '');
    _deliverableController = TextEditingController(
      text: draft?.deliverable ?? '',
    );
    _validationController = TextEditingController(
      text: draft?.validationCriteria ?? '',
    );
    _assignedToController = TextEditingController();
    _assignedToNameController = TextEditingController();
    _priority = draft?.priority ?? 'medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _deadlineController.dispose();
    _deliverableController.dispose();
    _validationController.dispose();
    _assignedToController.dispose();
    _assignedToNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.controller.createTask(<String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priority': _priority,
        'category': _categoryController.text.trim(),
        'deadline': _deadlineController.text.trim(),
        'deliverable': _deliverableController.text.trim(),
        'validationCriteria': _validationController.text.trim(),
        'assignedTo': _assignedToController.text.trim(),
        'assignedToName': _assignedToNameController.text.trim(),
        'source': widget.initialDraft == null ? 'manual' : 'bedrock',
      });
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
      ).showSnackBar(SnackBar(content: Text('Unable to create task: $error')));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task title'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (value) =>
                    setState(() => _priority = value ?? 'medium'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Deadline (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _deliverableController,
                decoration: const InputDecoration(labelText: 'Deliverable'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _validationController,
                decoration: const InputDecoration(
                  labelText: 'Validation criteria',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _assignedToController,
                decoration: const InputDecoration(
                  labelText: 'Assigned intern user ID',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _assignedToNameController,
                decoration: const InputDecoration(
                  labelText: 'Assigned intern name',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(_submitting ? 'Saving...' : 'Create task'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
