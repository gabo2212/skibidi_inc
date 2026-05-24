import 'package:flutter_test/flutter_test.dart';
import 'package:interntask_ai_cloud/config/app_config.dart';
import 'package:interntask_ai_cloud/main.dart';
import 'package:interntask_ai_cloud/services/api_service.dart';
import 'package:interntask_ai_cloud/services/app_controller.dart';
import 'package:interntask_ai_cloud/services/auth_service.dart';

void main() {
  testWidgets('shows login shell when signed out', (tester) async {
    const config = AppConfig(
      awsRegion: '',
      userPoolId: '',
      userPoolClientId: '',
      apiBaseUrl: '',
    );
    final controller = AppController(
      config: config,
      authService: AuthService(),
      apiService: ApiService(config: config),
    );

    await tester.pumpWidget(InternTaskApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('InternTask AI Cloud'), findsOneWidget);
    expect(find.text('Sign in'), findsAtLeastNWidgets(1));
  });
}
