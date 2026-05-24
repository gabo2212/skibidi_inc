import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../theme/newsprint_theme.dart';
import '../widgets/info_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: 'instructor.demo@example.com',
  );
  final _passwordController = TextEditingController(text: 'Password123!');
  bool _submitting = false;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
      _localError = null;
    });
    try {
      await widget.controller.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _localError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: NewsprintColors.ink, width: 2),
                  color: NewsprintColors.background,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: NewsprintColors.ink),
                        ),
                      ),
                      child: Text(
                        'VOL. 1 | CLOUD EDITION | INTERN OPERATIONS DESK',
                        style: textTheme.labelMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 760;
                          final headline = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'InternTask\nAI Cloud',
                                style: textTheme.displayLarge,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Assignment control, proof handling, and instructor review in one AWS-backed field desk.',
                                style: textTheme.bodyLarge,
                                textAlign: TextAlign.justify,
                              ),
                              if (widget.controller.isPreviewMode) ...<Widget>[
                                const SizedBox(height: 18),
                                const InfoBanner(
                                  message:
                                      'Preview mode is active because amplify_outputs.json still has placeholder values. Use an email containing admin, instructor, or intern.',
                                ),
                              ],
                            ],
                          );
                          final form = _LoginForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            submitting: _submitting,
                            localError: _localError,
                            onSubmit: _submit,
                          );
                          if (!wide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                headline,
                                const SizedBox(height: 24),
                                form,
                              ],
                            );
                          }
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(flex: 7, child: headline),
                                const SizedBox(width: 20),
                                const VerticalDivider(width: 1),
                                const SizedBox(width: 20),
                                Expanded(flex: 5, child: form),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.submitting,
    required this.localError,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool submitting;
  final String? localError;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('ACCESS DESK', style: Theme.of(context).textTheme.titleMedium),
          const Divider(height: 24),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Password must be at least 8 characters.';
              }
              return null;
            },
          ),
          if (localError != null) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              localError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: NewsprintColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: submitting ? null : onSubmit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(submitting ? 'SIGNING IN' : 'SIGN IN'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
