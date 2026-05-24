import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class AppConfig {
  const AppConfig({
    required this.awsRegion,
    required this.userPoolId,
    required this.userPoolClientId,
    required this.apiBaseUrl,
    required this.s3BucketName,
    required this.passwordPolicy,
  });

  final String awsRegion;
  final String userPoolId;
  final String userPoolClientId;
  final String apiBaseUrl;
  final String s3BucketName;
  final Map<String, dynamic> passwordPolicy;

  static const String _assetPath = 'assets/config/amplify_outputs.json';

  static const Map<String, dynamic> _defaultPasswordPolicy = <String, dynamic>{
    'min_length': 8,
    'require_lowercase': true,
    'require_uppercase': true,
    'require_numbers': true,
    'require_symbols': true,
  };

  bool get hasAuthConfig =>
      !_isPlaceholder(awsRegion) &&
      !_isPlaceholder(userPoolId) &&
      !_isPlaceholder(userPoolClientId);

  bool get hasApiConfig => !_isPlaceholder(apiBaseUrl);

  bool get isPreviewMode => !hasAuthConfig || !hasApiConfig;

  static Future<AppConfig> load() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      if (raw.trim().isEmpty) {
        return _placeholderConfig();
      }
      final Map<String, dynamic> json =
          jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(json);
    } catch (_) {
      return _placeholderConfig();
    }
  }

  static AppConfig _fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> auth =
        (json['auth'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<String, dynamic> custom =
        (json['custom'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<String, dynamic> policy =
        (auth['password_policy'] as Map<String, dynamic>?) ??
            _defaultPasswordPolicy;

    return AppConfig(
      awsRegion: auth['aws_region']?.toString() ?? '',
      userPoolId: auth['user_pool_id']?.toString() ?? '',
      userPoolClientId: auth['user_pool_client_id']?.toString() ?? '',
      apiBaseUrl: custom['api_base_url']?.toString() ?? '',
      s3BucketName: custom['s3_bucket_name']?.toString() ?? '',
      passwordPolicy: policy,
    );
  }

  static AppConfig _placeholderConfig() {
    return const AppConfig(
      awsRegion: '',
      userPoolId: '',
      userPoolClientId: '',
      apiBaseUrl: '',
      s3BucketName: '',
      passwordPolicy: _defaultPasswordPolicy,
    );
  }

  String buildAmplifyConfigJson() {
    final Map<String, dynamic> amplifyConfig = <String, dynamic>{
      'UserAgent': 'aws-amplify-cli/2.0',
      'Version': '1.0',
      'auth': <String, dynamic>{
        'plugins': <String, dynamic>{
          'awsCognitoAuthPlugin': <String, dynamic>{
            'UserAgent': 'aws-amplify-cli/0.1.0',
            'Version': '0.1.0',
            'IdentityManager': <String, dynamic>{
              'Default': <String, dynamic>{},
            },
            'CognitoUserPool': <String, dynamic>{
              'Default': <String, dynamic>{
                'PoolId': userPoolId,
                'AppClientId': userPoolClientId,
                'Region': awsRegion,
              },
            },
            'Auth': <String, dynamic>{
              'Default': <String, dynamic>{
                'authenticationFlowType': 'USER_SRP_AUTH',
                'usernameAttributes': <String>['email'],
                'signupAttributes': <String>['email'],
                'passwordProtectionSettings': <String, dynamic>{
                  'passwordPolicyMinLength':
                      passwordPolicy['min_length'] ?? 8,
                  'passwordPolicyCharacters': _passwordPolicyCharacters(),
                },
                'mfaConfiguration': 'OFF',
                'mfaTypes': <String>['SMS'],
                'verificationMechanisms': <String>['EMAIL'],
              },
            },
          },
        },
      },
    };
    return jsonEncode(amplifyConfig);
  }

  List<String> _passwordPolicyCharacters() {
    final List<String> chars = <String>[];
    if (passwordPolicy['require_lowercase'] == true) {
      chars.add('REQUIRES_LOWERCASE');
    }
    if (passwordPolicy['require_uppercase'] == true) {
      chars.add('REQUIRES_UPPERCASE');
    }
    if (passwordPolicy['require_numbers'] == true) {
      chars.add('REQUIRES_NUMBERS');
    }
    if (passwordPolicy['require_symbols'] == true) {
      chars.add('REQUIRES_SYMBOLS');
    }
    return chars;
  }

  static bool _isPlaceholder(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return true;
    }
    final lower = trimmed.toLowerCase();
    return lower.startsWith('<') ||
        lower.contains('placeholder') ||
        lower.contains('your-') ||
        lower == 'todo';
  }
}
