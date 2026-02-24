import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum SnackbarType { success, error, info, warning }

class JYSnackbar {
  JYSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (Color bg, IconData icon) = switch (type) {
      SnackbarType.success => (AppColors.success, Icons.check_circle_outline),
      SnackbarType.error => (AppColors.error, Icons.error_outline),
      SnackbarType.warning => (AppColors.warning, Icons.warning_amber_outlined),
      SnackbarType.info => (AppColors.info, Icons.info_outline),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: bg,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}
