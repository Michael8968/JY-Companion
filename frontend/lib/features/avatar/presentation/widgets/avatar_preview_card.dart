import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/avatar_preset.dart';
import 'avatar_renderer.dart';

/// 预设形象预览卡片，用于形象选择页面。
/// 展示 Rive 动画预览 + 名称 + 描述 + 标签，支持选中高亮。
class AvatarPreviewCard extends StatelessWidget {
  const AvatarPreviewCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final AvatarPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        preset.themeColor != null ? Color(preset.themeColor!) : AppColors.primary;

    return Material(
      color: AppColors.surface,
      borderRadius: AppSpacing.borderRadiusMd,
      elevation: isSelected ? 3 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Rive 动画预览区
              SizedBox(
                width: 100,
                height: 100,
                child: AvatarRenderer(
                  assetPath: preset.assetPath,
                  stateMachineName: preset.stateMachineName,
                  artboardName: preset.artboardName,
                  placeholderSize: 100,
                ),
              ),
              const SizedBox(height: 12),
              // 名称
              Text(
                preset.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : null,
                    ),
              ),
              const SizedBox(height: 4),
              // 描述
              Text(
                preset.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // 标签
              Wrap(
                spacing: 6,
                children: preset.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                  );
                }).toList(),
              ),
              // 选中标记
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(Icons.check_circle, color: color, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
