import 'package:flutter/material.dart';

/// Reusable themed SnackBar helper for KooraSpot.
class KSSnackBar {
  KSSnackBar._();

  static const _successColor = Color(0xFF016D47);
  static const _errorColor = Color(0xFFBA1A1A);
  static const _infoColor = Color(0xFFE68A00);

  static void success(BuildContext context, String message) =>
      _show(context, message, _successColor, Icons.check_circle);

  static void error(BuildContext context, String message) =>
      _show(context, message, _errorColor, Icons.error_outline);

  static void info(BuildContext context, String message) =>
      _show(context, message, _infoColor, Icons.info_outline);

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
