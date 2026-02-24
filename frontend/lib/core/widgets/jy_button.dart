import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum JYButtonStyle { primary, secondary, text, icon }

class JYButton extends StatelessWidget {
  const JYButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = JYButtonStyle.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final JYButtonStyle style;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget button;
    switch (style) {
      case JYButtonStyle.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
      case JYButtonStyle.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
      case JYButtonStyle.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
      case JYButtonStyle.icon:
        button = IconButton.filled(
          onPressed: effectiveOnPressed,
          icon: Icon(icon ?? Icons.arrow_forward),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
        );
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
