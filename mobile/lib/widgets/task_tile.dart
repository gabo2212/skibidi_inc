import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../theme/newsprint_theme.dart';

class TaskTile extends StatefulWidget {
  const TaskTile({super.key, required this.task, required this.onTap});

  final TaskItem task;
  final VoidCallback onTap;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _hovered = false;

  Color _priorityColor() {
    switch (widget.task.priority) {
      case 'urgent':
        return NewsprintColors.accent;
      case 'high':
        return NewsprintColors.ink;
      case 'medium':
        return NewsprintColors.neutral700;
      default:
        return NewsprintColors.neutral500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor();
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6),
        transform: Matrix4.translationValues(
          _hovered ? -2 : 0,
          _hovered ? -2 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: _hovered
              ? NewsprintColors.neutral100
              : NewsprintColors.background,
          border: Border.all(color: NewsprintColors.ink),
          boxShadow: _hovered
              ? const <BoxShadow>[
                  BoxShadow(
                    color: NewsprintColors.ink,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ListTile(
          onTap: widget.onTap,
          contentPadding: const EdgeInsets.all(18),
          title: Text(
            widget.task.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Chip(label: Text(widget.task.status.toUpperCase())),
                    Chip(
                      label: Text(widget.task.priority.toUpperCase()),
                      backgroundColor: priorityColor.withAlpha(20),
                      labelStyle: TextStyle(color: priorityColor),
                    ),
                    if (widget.task.assignedToName.isNotEmpty)
                      Chip(
                        label: Text(
                          'ASSIGNED: ${widget.task.assignedToName.toUpperCase()}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
