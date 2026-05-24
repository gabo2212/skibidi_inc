import 'package:flutter/material.dart';

import '../theme/newsprint_theme.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String message;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? NewsprintColors.muted,
        border: Border.all(color: NewsprintColors.ink),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: foregroundColor ?? NewsprintColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
