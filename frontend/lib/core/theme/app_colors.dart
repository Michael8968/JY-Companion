import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary: education-friendly blue
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);
  static const Color onPrimary = Colors.white;

  // Secondary: warm orange for engagement
  static const Color secondary = Color(0xFFFF8F00);
  static const Color secondaryLight = Color(0xFFFFC046);
  static const Color onSecondary = Colors.white;

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0288D1);

  // Neutrals
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);

  // Agent type colors
  static const Color academic = Color(0xFF1565C0);
  static const Color classroom = Color(0xFF00838F);
  static const Color emotional = Color(0xFFAD1457);
  static const Color health = Color(0xFF2E7D32);
  static const Color creative = Color(0xFF6A1B9A);
  static const Color career = Color(0xFFEF6C00);

  // Chat bubble colors
  static const Color userBubble = Color(0xFF1565C0);
  static const Color userBubbleText = Colors.white;
  static const Color assistantBubble = Color(0xFFFFFFFF);
  static const Color assistantBubbleText = Color(0xFF212121);
}
