class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.deliverable,
    required this.validationCriteria,
    required this.deadline,
  });

  final String title;
  final String description;
  final String priority;
  final String category;
  final String deliverable;
  final String validationCriteria;
  final String deadline;

  factory TaskDraft.fromJson(Map<String, dynamic> json) {
    return TaskDraft(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      category: json['category']?.toString() ?? 'AI Draft',
      deliverable: json['deliverable']?.toString() ?? '',
      validationCriteria: json['validationCriteria']?.toString() ?? '',
      deadline: json['deadline']?.toString() ?? '',
    );
  }
}
