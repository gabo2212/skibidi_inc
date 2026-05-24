import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: foregroundColor ?? const Color(0xFF14532D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
