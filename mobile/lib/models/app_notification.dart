class AppNotification {
  const AppNotification({
    required this.notificationId,
    required this.userId,
    required this.taskId,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  final String notificationId;
  final String userId;
  final String taskId;
  final String title;
  final String message;
  final bool read;
  final String createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['notificationId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      taskId: json['taskId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      read: json['read'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      notificationId: notificationId,
      userId: userId,
      taskId: taskId,
      title: title,
      message: message,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
