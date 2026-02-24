import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: _actions.map((action) {
        return _ActionCard(
          icon: action.icon,
          label: action.label,
          color: action.color,
          onTap: () => _onActionTap(context, action.agentType),
        );
      }).toList(),
    );
  }

  void _onActionTap(BuildContext context, String agentType) {
    // Navigate to conversations page, creating a new conversation will be handled there
    context.go('/home/conversations');
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: AppSpacing.borderRadiusMd,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String agentType;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.agentType,
  });
}

const _actions = [
  _QuickAction(
    icon: Icons.auto_stories,
    label: '学业辅导',
    color: AppColors.academic,
    agentType: 'academic',
  ),
  _QuickAction(
    icon: Icons.class_,
    label: '课堂复盘',
    color: AppColors.classroom,
    agentType: 'classroom',
  ),
  _QuickAction(
    icon: Icons.favorite,
    label: '情感陪伴',
    color: AppColors.emotional,
    agentType: 'emotional',
  ),
  _QuickAction(
    icon: Icons.health_and_safety,
    label: '健康守护',
    color: AppColors.health,
    agentType: 'health',
  ),
  _QuickAction(
    icon: Icons.palette,
    label: '创意创作',
    color: AppColors.creative,
    agentType: 'creative',
  ),
  _QuickAction(
    icon: Icons.trending_up,
    label: '生涯规划',
    color: AppColors.career,
    agentType: 'career',
  ),
];
