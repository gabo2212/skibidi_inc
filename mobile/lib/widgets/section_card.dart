import 'package:flutter/material.dart';

import '../theme/newsprint_theme.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: NewsprintColors.background,
        border: Border.all(color: NewsprintColors.ink),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title.toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: NewsprintColors.ink),
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
