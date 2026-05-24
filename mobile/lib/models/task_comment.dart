class TaskComment {
  const TaskComment({
    required this.commentId,
    required this.authorId,
    required this.authorName,
    required this.message,
    required this.createdAt,
  });

  final String commentId;
  final String authorId;
  final String authorName;
  final String message;
  final String createdAt;

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      commentId: json['commentId']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
