import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// 放松动画：渐变脉冲圆环。
class RelaxationAnimationWidget extends StatefulWidget {
  const RelaxationAnimationWidget({super.key});

  @override
  State<RelaxationAnimationWidget> createState() =>
      _RelaxationAnimationWidgetState();
}

class _RelaxationAnimationWidgetState extends State<RelaxationAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          Text(
            '放松一下',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '跟随节奏深呼吸，让身心放松。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 48),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              final scale = 0.85 + t * 0.3;
              final opacity = 0.3 + t * 0.5;
              return Center(
                child: Container(
                  width: 120 * scale,
                  height: 120 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emotional.withValues(alpha: opacity),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          Text(
            '闭上眼睛，感受呼吸。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}
