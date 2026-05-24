import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import 'create_task_screen.dart';

class AiGenerateTaskScreen extends StatefulWidget {
  const AiGenerateTaskScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AiGenerateTaskScreen> createState() => _AiGenerateTaskScreenState();
}

class _AiGenerateTaskScreenState extends State<AiGenerateTaskScreen> {
  final _objectiveController = TextEditingController(
    text: 'Build a first-week AWS onboarding task',
  );
  final _domainController = TextEditingController(text: 'Cloud');
  final _internNameController = TextEditingController(text: 'Intern Demo');
  final _levelController = TextEditingController(text: 'Junior');
  final _skillsController = TextEditingController(
    text: 'Terraform, AWS, Documentation',
  );
  final _durationController = TextEditingController(text: '1 week');
  final _deliverableController = TextEditingController(
    text: 'Checklist and short status report',
  );
  bool _generating = false;

  @override
  void dispose() {
    _objectiveController.dispose();
    _domainController.dispose();
    _internNameController.dispose();
    _levelController.dispose();
    _skillsController.dispose();
    _durationController.dispose();
    _deliverableController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      await widget.controller.generateTasks(<String, dynamic>{
        'objective': _objectiveController.text.trim(),
        'domain': _domainController.text.trim(),
        'internName': _internNameController.text.trim(),
        'level': _levelController.text.trim(),
        'skills': _skillsController.text
            .split(',')
            .map((skill) => skill.trim())
            .where((skill) => skill.isNotEmpty)
            .toList(growable: false),
        'duration': _durationController.text.trim(),
        'deliverable': _deliverableController.text.trim(),
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Generation failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final drafts = widget.controller.generatedDrafts;
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Tasks with Bedrock')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          TextField(
            controller: _objectiveController,
            decoration: const InputDecoration(labelText: 'Objective'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _domainController,
            decoration: const InputDecoration(labelText: 'Domain'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _internNameController,
            decoration: const InputDecoration(labelText: 'Intern name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _levelController,
            decoration: const InputDecoration(labelText: 'Level'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _skillsController,
            decoration: const InputDecoration(
              labelText: 'Skills (comma separated)',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _durationController,
            decoration: const InputDecoration(labelText: 'Duration'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _deliverableController,
            decoration: const InputDecoration(labelText: 'Deliverable'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _generating ? null : _generate,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_generating ? 'Generating...' : 'Generate drafts'),
          ),
          const SizedBox(height: 24),
          ...drafts.map(
            (draft) => Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      draft.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(draft.description),
                    const SizedBox(height: 10),
                    Text('Deliverable: ${draft.deliverable}'),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonal(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CreateTaskScreen(
                                controller: widget.controller,
                                initialDraft: draft,
                              ),
                            ),
                          );
                        },
                        child: const Text('Use this draft'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
