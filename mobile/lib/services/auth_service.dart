import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import '../config/app_config.dart';
import '../models/app_user.dart';

class AuthService {
  bool _configured = false;
  AppConfig? _config;
  AppUser? _previewUser;
  String? _previewToken;

  Future<void> initialize(AppConfig config) async {
    _config = config;
    if (!config.hasAuthConfig || _configured) {
      return;
    }
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(config.buildAmplifyConfigJson());
    _configured = true;
  }

  Future<AppUser?> restoreSession() async {
    final config = _config;
    if (config == null) {
      return null;
    }
    if (!config.hasAuthConfig) {
      return _previewUser;
    }
    try {
      final dynamic session = await Amplify.Auth.fetchAuthSession();
      final bool isSignedIn = session.isSignedIn == true;
      if (!isSignedIn) {
        return null;
      }
      return _buildUserFromSession();
    } catch (_) {
      return null;
    }
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final config = _config;
    if (config == null) {
      throw StateError('Auth service has not been initialized.');
    }
    if (!config.hasAuthConfig) {
      _previewUser = AppUser.preview(email);
      _previewToken = 'preview-access-token';
      return _previewUser!;
    }
    final dynamic result = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );
    if (result.isSignedIn != true) {
      throw StateError(
        'Sign in requires an additional step. Confirm the user or reset the password if needed.',
      );
    }
    return _buildUserFromSession();
  }

  Future<void> signOut() async {
    final config = _config;
    if (config == null || !config.hasAuthConfig) {
      _previewUser = null;
      _previewToken = null;
      return;
    }
    await Amplify.Auth.signOut();
  }

  Future<String?> getAccessToken() async {
    final config = _config;
    if (config == null) {
      return null;
    }
    if (!config.hasAuthConfig) {
      return _previewToken;
    }
    final dynamic session = await Amplify.Auth.fetchAuthSession();
    if (session.isSignedIn != true) {
      return null;
    }
    final dynamic tokens = session.userPoolTokensResult.value;
    return tokens.accessToken.raw as String?;
  }

  Future<AppUser> _buildUserFromSession() async {
    final dynamic authUser = await Amplify.Auth.getCurrentUser();
    final dynamic session = await Amplify.Auth.fetchAuthSession();
    final dynamic tokens = session.userPoolTokensResult.value;
    final String accessToken = tokens.accessToken.raw as String? ?? '';
    final List<String> groups = List<String>.from(
      (tokens.accessToken.groups as List<dynamic>? ?? <dynamic>[]),
    );
    final role = groups.contains('admin')
        ? 'admin'
        : groups.contains('instructor')
        ? 'instructor'
        : 'intern';
    _previewToken = accessToken;
    return AppUser(
      userId: authUser.userId as String? ?? '',
      email: authUser.username as String? ?? '',
      displayName: authUser.username as String? ?? '',
      role: role,
      groups: groups,
    );
  }
}
