import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum AgentType {
  academic('academic', '学业辅导', Icons.auto_stories, AppColors.academic),
  classroom('classroom', '课堂复盘', Icons.class_, AppColors.classroom),
  emotional('emotional', '情感陪伴', Icons.favorite, AppColors.emotional),
  health('health', '健康守护', Icons.health_and_safety, AppColors.health),
  creative('creative', '创意创作', Icons.palette, AppColors.creative),
  career('career', '生涯规划', Icons.trending_up, AppColors.career);

  final String value;
  final String displayName;
  final IconData icon;
  final Color color;

  const AgentType(this.value, this.displayName, this.icon, this.color);

  static AgentType fromString(String value) {
    return AgentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AgentType.academic,
    );
  }
}
