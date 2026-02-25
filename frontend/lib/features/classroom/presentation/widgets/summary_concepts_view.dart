import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// 摘要图表视图：概念/要点卡片展示。
class SummaryConceptsView extends StatelessWidget {
  const SummaryConceptsView({
    super.key,
    this.concepts,
    this.keyPoints,
  });

  final Map<String, dynamic>? concepts;
  final Map<String, dynamic>? keyPoints;

  @override
  Widget build(BuildContext context) {
    final conceptItems = _flattenToItems(concepts);
    final pointItems = _flattenToItems(keyPoints);
    if (conceptItems.isEmpty && pointItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (conceptItems.isNotEmpty) ...[
          Text(
            '核心概念',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: conceptItems
                .map((e) => Chip(
                      label: Text(e),
                      backgroundColor:
                          AppColors.classroom.withValues(alpha: 0.1),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (pointItems.isNotEmpty) ...[
          Text(
            '要点',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...pointItems.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: Padding(
                  padding: AppSpacing.paddingMd,
                  child: Text(e),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<String> _flattenToItems(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return [];
    final list = <String>[];
    for (final e in map.entries) {
      if (e.value is String) {
        list.add('${e.key}: ${e.value}');
      } else if (e.value is List) {
        for (final item in e.value as List) {
          list.add(item.toString());
        }
      } else if (e.value is Map) {
        for (final k in (e.value as Map).entries) {
          list.add('${k.key}: ${k.value}');
        }
      }
    }
    return list;
  }
}
