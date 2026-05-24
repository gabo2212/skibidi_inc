import 'task_attachment.dart';
import 'task_comment.dart';

class TaskItem {
  const TaskItem({
    required this.taskId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdBy,
    required this.createdByName,
    required this.status,
    required this.priority,
    required this.category,
    required this.deadline,
    required this.source,
    required this.deliverable,
    required this.validationCriteria,
    required this.comments,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.blockedReason,
  });

  final String taskId;
  final String title;
  final String description;
  final String assignedTo;
  final String assignedToName;
  final String createdBy;
  final String createdByName;
  final String status;
  final String priority;
  final String category;
  final String deadline;
  final String source;
  final String deliverable;
  final String validationCriteria;
  final List<TaskComment> comments;
  final List<TaskAttachment> attachments;
  final String createdAt;
  final String updatedAt;
  final String? blockedReason;

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final commentsRaw = (json['comments'] as List<dynamic>? ?? <dynamic>[]);
    final attachmentsRaw =
        (json['attachments'] as List<dynamic>? ?? <dynamic>[]);
    return TaskItem(
      taskId: json['taskId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      assignedTo: json['assignedTo']?.toString() ?? '',
      assignedToName: json['assignedToName']?.toString() ?? '',
      createdBy: json['createdBy']?.toString() ?? '',
      createdByName: json['createdByName']?.toString() ?? '',
      status: json['status']?.toString() ?? 'todo',
      priority: json['priority']?.toString() ?? 'medium',
      category: json['category']?.toString() ?? 'General',
      deadline: json['deadline']?.toString() ?? '',
      source: json['source']?.toString() ?? 'manual',
      deliverable: json['deliverable']?.toString() ?? '',
      validationCriteria: json['validationCriteria']?.toString() ?? '',
      comments: commentsRaw
          .whereType<Map<String, dynamic>>()
          .map(TaskComment.fromJson)
          .toList(growable: false),
      attachments: attachmentsRaw
          .whereType<Map<String, dynamic>>()
          .map(TaskAttachment.fromJson)
          .toList(growable: false),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      blockedReason: json['blockedReason']?.toString(),
    );
  }

  TaskItem copyWith({
    String? assignedTo,
    String? assignedToName,
    String? status,
    List<TaskComment>? comments,
    List<TaskAttachment>? attachments,
    String? updatedAt,
    String? blockedReason,
  }) {
    return TaskItem(
      taskId: taskId,
      title: title,
      description: description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy,
      createdByName: createdByName,
      status: status ?? this.status,
      priority: priority,
      category: category,
      deadline: deadline,
      source: source,
      deliverable: deliverable,
      validationCriteria: validationCriteria,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      blockedReason: blockedReason ?? this.blockedReason,
    );
  }
}
