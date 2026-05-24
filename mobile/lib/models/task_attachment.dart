class TaskAttachment {
  const TaskAttachment({
    required this.attachmentId,
    required this.fileName,
    required this.contentType,
    required this.uploadedBy,
    required this.createdAt,
    this.uploadUrl,
    this.objectKey,
  });

  final String attachmentId;
  final String fileName;
  final String contentType;
  final String uploadedBy;
  final String createdAt;
  final String? uploadUrl;
  final String? objectKey;

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      attachmentId: json['attachmentId']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? '',
      uploadedBy: json['uploadedBy']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      uploadUrl: json['uploadUrl']?.toString(),
      objectKey: json['objectKey']?.toString() ?? json['s3Key']?.toString(),
    );
  }
}
