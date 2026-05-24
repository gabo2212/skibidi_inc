import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/app_user.dart';
import '../models/task_draft.dart';
import '../models/task_item.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.config,
    required this.authService,
    required this.apiService,
  });

  final AppConfig config;
  final AuthService authService;
  final ApiService apiService;

  AppUser? currentUser;
  List<TaskItem> tasks = <TaskItem>[];
  List<TaskDraft> generatedDrafts = <TaskDraft>[];
  bool isBusy = false;
  String? errorMessage;

  bool get isSignedIn => currentUser != null;
  bool get isPreviewMode => config.isPreviewMode;

  Future<void> initialize() async {
    isBusy = true;
    notifyListeners();
    try {
      await authService.initialize(config);
      currentUser = await authService.restoreSession();
      if (currentUser != null) {
        await loadTasks();
      }
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentUser = await authService.signIn(email: email, password: password);
      await loadTasks();
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    currentUser = null;
    tasks = <TaskItem>[];
    generatedDrafts = <TaskDraft>[];
    notifyListeners();
  }

  Future<void> loadTasks() async {
    final user = currentUser;
    if (user == null) {
      return;
    }
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      tasks = await apiService.fetchTasks(
        role: user.role,
        accessToken: await authService.getAccessToken(),
      );
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<TaskItem> createTask(Map<String, dynamic> payload) async {
    final task = await apiService.createTask(
      payload: payload,
      accessToken: await authService.getAccessToken(),
    );
    tasks = <TaskItem>[
      task,
      ...tasks.where((item) => item.taskId != task.taskId),
    ];
    notifyListeners();
    return task;
  }

  Future<List<TaskDraft>> generateTasks(Map<String, dynamic> payload) async {
    generatedDrafts = await apiService.generateTasks(
      payload: payload,
      accessToken: await authService.getAccessToken(),
    );
    notifyListeners();
    return generatedDrafts;
  }

  Future<TaskItem> assignTask({
    required String taskId,
    required String assignedTo,
    required String assignedToName,
  }) async {
    final updated = await apiService.assignTask(
      taskId: taskId,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      accessToken: await authService.getAccessToken(),
    );
    _replaceTask(updated);
    return updated;
  }

  Future<TaskItem> updateTaskStatus({
    required String taskId,
    required String status,
    String? blockedReason,
  }) async {
    final updated = await apiService.updateTaskStatus(
      taskId: taskId,
      status: status,
      blockedReason: blockedReason,
      accessToken: await authService.getAccessToken(),
    );
    _replaceTask(updated);
    return updated;
  }

  Future<TaskItem> addComment({
    required String taskId,
    required String message,
  }) async {
    final updated = await apiService.addComment(
      taskId: taskId,
      message: message,
      accessToken: await authService.getAccessToken(),
    );
    _replaceTask(updated);
    return updated;
  }

  Future<AttachmentUploadSession> requestAttachmentUrl({
    required String taskId,
    required String fileName,
    required String contentType,
    required int sizeBytes,
  }) async {
    return apiService.requestAttachmentUrl(
      taskId: taskId,
      fileName: fileName,
      contentType: contentType,
      sizeBytes: sizeBytes,
      accessToken: await authService.getAccessToken(),
    );
  }

  Future<void> uploadAttachment({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) {
    return apiService.uploadBytes(
      uploadUrl: uploadUrl,
      bytes: bytes,
      contentType: contentType,
    );
  }

  void _replaceTask(TaskItem updatedTask) {
    tasks = tasks
        .map((task) => task.taskId == updatedTask.taskId ? updatedTask : task)
        .toList(growable: false);
    notifyListeners();
  }
}
