import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/task_attachment.dart';
import '../models/task_comment.dart';
import '../models/task_draft.dart';
import '../models/task_item.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AttachmentUploadSession {
  const AttachmentUploadSession({
    required this.attachment,
    required this.uploadUrl,
  });

  final TaskAttachment attachment;
  final String uploadUrl;
}

class ApiService {
  ApiService({required this.config});

  final AppConfig config;
  final http.Client _client = http.Client();

  final List<TaskItem> _previewTasks = <TaskItem>[
    TaskItem.fromJson(<String, dynamic>{
      'taskId': 'task-preview-1',
      'title': 'Prepare internship onboarding checklist',
      'description':
          'List access needs, orientation steps, and acceptance criteria.',
      'assignedTo': 'intern.demo@example.com',
      'assignedToName': 'Intern Demo',
      'createdBy': 'instructor.demo@example.com',
      'createdByName': 'Instructor Demo',
      'status': 'in_progress',
      'priority': 'high',
      'category': 'Operations',
      'deadline': '2026-06-01',
      'source': 'manual',
      'deliverable': 'Shared onboarding document',
      'validationCriteria': 'Checklist reviewed by instructor',
      'comments': <Map<String, dynamic>>[
        <String, dynamic>{
          'commentId': 'comment-preview-1',
          'authorId': 'intern.demo@example.com',
          'authorName': 'Intern Demo',
          'message': 'Draft is ready for review.',
          'createdAt': '2026-05-24T09:30:00Z',
        },
      ],
      'attachments': <Map<String, dynamic>>[],
      'createdAt': '2026-05-24T08:00:00Z',
      'updatedAt': '2026-05-24T09:30:00Z',
    }),
    TaskItem.fromJson(<String, dynamic>{
      'taskId': 'task-preview-2',
      'title': 'Research AWS Bedrock guardrails',
      'description':
          'Summarize safe prompt and output handling for internship tasks.',
      'assignedTo': '',
      'assignedToName': '',
      'createdBy': 'instructor.demo@example.com',
      'createdByName': 'Instructor Demo',
      'status': 'todo',
      'priority': 'medium',
      'category': 'AI',
      'deadline': '2026-06-03',
      'source': 'bedrock',
      'deliverable': 'One-page briefing note',
      'validationCriteria': 'Three practical recommendations documented',
      'comments': <Map<String, dynamic>>[],
      'attachments': <Map<String, dynamic>>[],
      'createdAt': '2026-05-24T10:00:00Z',
      'updatedAt': '2026-05-24T10:00:00Z',
    }),
  ];

  bool get isPreviewMode => !config.hasApiConfig;

  Future<List<TaskItem>> fetchTasks({
    required String role,
    String? accessToken,
  }) async {
    if (isPreviewMode) {
      if (role == 'intern') {
        return _previewTasks
            .where((task) => task.assignedTo.isNotEmpty)
            .toList(growable: false);
      }
      return List<TaskItem>.from(_previewTasks);
    }
    final response = await _client.get(
      _buildUri('/tasks'),
      headers: _headers(accessToken),
    );
    final json = _decode(response);
    _ensureSuccess(response, json);
    final tasks = (json['tasks'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(TaskItem.fromJson)
        .toList(growable: false);
    return tasks;
  }

  Future<TaskItem> createTask({
    required Map<String, dynamic> payload,
    String? accessToken,
  }) async {
    if (isPreviewMode) {
      final now = DateTime.now().toUtc().toIso8601String();
      final item = TaskItem.fromJson(<String, dynamic>{
        'taskId': 'task-preview-${_previewTasks.length + 1}',
        ...payload,
        'assignedTo': payload['assignedTo'] ?? '',
        'assignedToName': payload['assignedToName'] ?? '',
        'createdBy': 'preview-instructor',
        'createdByName': 'Preview Instructor',
        'status': payload['status'] ?? 'todo',
        'priority': payload['priority'] ?? 'medium',
        'category': payload['category'] ?? 'General',
        'deadline': payload['deadline'] ?? '',
        'source': payload['source'] ?? 'manual',
        'deliverable': payload['deliverable'] ?? '',
        'validationCriteria': payload['validationCriteria'] ?? '',
        'comments': <Map<String, dynamic>>[],
        'attachments': <Map<String, dynamic>>[],
        'createdAt': now,
        'updatedAt': now,
      });
      _previewTasks.insert(0, item);
      return item;
    }
    final response = await _client.post(
      _buildUri('/tasks'),
      headers: _headers(accessToken),
      body: jsonEncode(payload),
    );
    final json = _decode(response);
    _ensureSuccess(response, json);
    return TaskItem.fromJson(json['task'] as Map<String, dynamic>);
  }

  Future<List<TaskDraft>> generateTasks({
    required Map<String, dynamic> payload,
    String? accessToken,
  }) async {
    if (isPreviewMode) {
      return <TaskDraft>[
        TaskDraft.fromJson(<String, dynamic>{
          'title': 'Analyze ${payload['objective'] ?? 'intern objective'}',
          'description':
              'Produce a scoped task draft using the provided internship context.',
          'priority': 'medium',
          'category': payload['domain'] ?? 'AI Draft',
          'deliverable': payload['deliverable'] ?? 'Short summary',
          'validationCriteria': 'Instructor confirms scope and clarity',
          'deadline': DateTime.now()
              .add(const Duration(days: 5))
              .toIso8601String()
              .split('T')
              .first,
        }),
      ];
    }
    final response = await _client.post(
      _buildUri('/tasks/generate'),
      headers: _headers(accessToken),
      body: jsonEncode(payload),
    );
    final json = _decode(response);
    _ensureSuccess(response, json);
    return (json['tasks'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(TaskDraft.fromJson)
        .toList(growable: false);
  }

  Future<TaskItem> assignTask({
    required String taskId,
    required String assignedTo,
    required String assignedToName,
    String? accessToken,
  }) async {
    if (isPreviewMode) {
      final index = _previewTasks.indexWhere((task) => task.taskId == taskId);
      final current = _previewTasks[index];
      final updated = current.copyWith(
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );
      _previewTasks[index] = updated;
      return updated;
    }
    final response = await _client.post(
      _buildUri('/tasks/$taskId/assign'),
      headers: _headers(accessToken),
      body: jsonEncode(<String, dynamic>{
        'assignedTo': assignedTo,
        'assignedToName': assignedToName,
      }),
    );
    final json = _decode(response);
    _ensureSuccess(response, json);
    return TaskItem.fromJson(json['task'] as Map<String, dynamic>);
  }

  Future<TaskItem> updateTaskStatus({
    required String taskId,
    required String status,
    String? blockedReason,
    String? accessToken,
  }) async {
    if (isPreviewMode) {
      final index = _previewTasks.indexWhere((task) => task.taskId == taskId);
      final current = _previewTasks[index];
      final updated = current.copyWith(
        status: status,
        blockedReason: blockedReason,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );
      _previewTasks[index] = updated;
      return updated;
    }
    final response = await _client.patch(
      _buildUri('/tasks/$taskId/status'),
      headers: _headers(accessToken),
      body: jsonEncode(<String, dynamic>{
        'status': status,
        'blockedReason': blockedReason,
      }),
    );
    final json = _decode(response);
    _ensureSuccess(response, json);
    return TaskItem.fromJson(json['task'] as Map<String, dynamic>);
  }

  Future<TaskItem> addComment({
    required String taskId,
    required String message,
    String? accessToken,
  }) async {
    if (isPreviewMode) {
      final index = _previewTasks.indexWhere((task) => task.taskId == taskId);
      final current = _previewTasks[index];
      final updatedComments = List<TaskComment>.from(current.comments)
        ..add(
          TaskComment(
            commentId: 'comment-${current.comments.length + 1}',
            authorId: 'preview-user',
            authorName: 'Preview User',
            message: message,
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
      final updated = current.copyWith(
        comments: updatedComments,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );
      _previewTasks[index] = updated;
      return updated;
    }
    final response = await _client.post(
      _buildUri('/tasks/$taskId/comments'),
      headers: _headers(accessToken),
      body: jsonEncode(<String, dynamic>{'message': message}),
    );
    final json = _decode(response);
    _ensureSuccess(response, json);
    return TaskItem.fromJson(json['task'] as Map<String, dynamic>);
  }

  Future<AttachmentUploadSession> requestAttachmentUrl({
    required String taskId,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    String? accessToken,
  }) async {
    if (isPreviewMode) {
      final now = DateTime.now().toUtc().toIso8601String();
      return AttachmentUploadSession(
        attachment: TaskAttachment(
          attachmentId: 'attachment-${DateTime.now().millisecondsSinceEpoch}',
          fileName: fileName,
          contentType: contentType,
          uploadedBy: 'preview-user',
          createdAt: now,
          objectKey: 'tasks/$taskId/$fileName',
          uploadUrl: 'https://example.invalid/upload',
        ),
        uploadUrl: 'https://example.invalid/upload',
      );
    }
    final response = await _client.post(
      _buildUri('/tasks/$taskId/attachment-url'),
      headers: _headers(accessToken),
      body: jsonEncode(<String, dynamic>{
        'fileName': fileName,
        'contentType': contentType,
        'sizeBytes': sizeBytes,
      }),
    );
    final json = _decode(response);
    _ensureSuccess(response, json);
    final attachment = TaskAttachment.fromJson(
      json['attachment'] as Map<String, dynamic>,
    );
    return AttachmentUploadSession(
      attachment: attachment,
      uploadUrl: json['uploadUrl']?.toString() ?? '',
    );
  }

  Future<void> uploadBytes({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    if (isPreviewMode) {
      return;
    }
    final response = await _client.put(
      Uri.parse(uploadUrl),
      headers: <String, String>{'Content-Type': contentType},
      body: bytes,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Upload failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  Uri _buildUri(String path) {
    final base = config.apiBaseUrl.endsWith('/')
        ? config.apiBaseUrl.substring(0, config.apiBaseUrl.length - 1)
        : config.apiBaseUrl;
    return Uri.parse('$base$path');
  }

  Map<String, String> _headers(String? accessToken) {
    return <String, String>{
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _ensureSuccess(http.Response response, Map<String, dynamic> json) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(
      json['message']?.toString() ??
          'Request failed with status ${response.statusCode}',
    );
  }
}
