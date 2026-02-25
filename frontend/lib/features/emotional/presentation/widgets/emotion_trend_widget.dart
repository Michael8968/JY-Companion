import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/emotion_record.dart';

/// 情绪趋势：近期限效价/情绪分布简易展示。
class EmotionTrendWidget extends StatelessWidget {
  const EmotionTrendWidget({super.key, required this.emotions});

  final List<EmotionRecord> emotions;

  @override
  Widget build(BuildContext context) {
    if (emotions.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }
    final reversed = emotions.toList().reversed.toList();
    final maxValence = 1.0;
    final minValence = -1.0;

    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '效价趋势（近 ${emotions.length} 条）',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: reversed.take(14).map((e) {
                final normalized = (e.valence - minValence) /
                    (maxValence - minValence);
                final height = normalized.clamp(0.1, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 160 * height,
                          decoration: BoxDecoration(
                            color: _valenceColor(e.valence),
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.emotionDisplay.substring(0, 1),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '情绪分布',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._groupByEmotion(emotions).entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: Text(
                          _emotionDisplay(e.key),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: e.value / emotions.length,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.emotional,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${e.value}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Map<String, int> _groupByEmotion(List<EmotionRecord> list) {
    final map = <String, int>{};
    for (final e in list) {
      map[e.emotionLabel] = (map[e.emotionLabel] ?? 0) + 1;
    }
    return map;
  }

  String _emotionDisplay(String label) {
    switch (label) {
      case 'happy':
        return '开心';
      case 'anxious':
        return '焦虑';
      case 'depressed':
        return '低落';
      case 'calm':
        return '平静';
      case 'angry':
        return '生气';
      case 'sad':
        return '难过';
      case 'fearful':
        return '害怕';
      default:
        return label;
    }
  }

  Color _valenceColor(double v) {
    if (v >= 0.3) return AppColors.success;
    if (v <= -0.3) return AppColors.error;
    return AppColors.emotional;
  }
}
