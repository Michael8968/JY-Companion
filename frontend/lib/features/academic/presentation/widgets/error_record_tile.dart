import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/error_record.dart';

class ErrorRecordTile extends StatelessWidget {
  const ErrorRecordTile({
    super.key,
    required this.record,
    required this.onReview,
  });

  final ErrorRecord record;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.academic.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Text(
                      record.subject.displayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.academic,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    record.errorTypeDisplay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    record.masteryStatusDisplay,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _masteryColor(record.masteryStatus),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                record.question,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '错误答案：${record.wrongAnswer}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text('标记复习 (${record.reviewCount})'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _masteryColor(String status) {
    switch (status) {
      case 'weak':
        return AppColors.error;
      case 'improving':
        return AppColors.warning;
      case 'mastered':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.question,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '错误答案',
                style: Theme.of(ctx).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                record.wrongAnswer,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    ),
              ),
              if (record.correctAnswer != null) ...[
                const SizedBox(height: 12),
                Text(
                  '正确答案',
                  style: Theme.of(ctx).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  record.correctAnswer!,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                      ),
                ),
              ],
              if (record.errorAnalysis != null) ...[
                const SizedBox(height: 12),
                Text(
                  '错因分析',
                  style: Theme.of(ctx).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  record.errorAnalysis!,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onReview();
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('标记复习'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
