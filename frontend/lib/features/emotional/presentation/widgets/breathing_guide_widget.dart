import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// 4-7-8 呼吸练习引导：吸气 4 秒、屏息 7 秒、呼气 8 秒。
class BreathingGuideWidget extends StatefulWidget {
  const BreathingGuideWidget({super.key});

  @override
  State<BreathingGuideWidget> createState() => _BreathingGuideWidgetState();
}

class _BreathingGuideWidgetState extends State<BreathingGuideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _phase = '准备';
  int _countdown = 0;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 19), // 4+7+8
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _runCycle();
  }

  void _runCycle() {
    _phase = '吸气';
    _countdown = 4;
    _controller.forward(from: 0);
    _tick();
  }

  void _tick() {
    _timer?.cancel();
    if (!mounted || !_isRunning) return;
    if (_countdown > 0) {
      _timer = Timer(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _countdown--);
        _tick();
      });
      return;
    }
    if (_phase == '吸气') {
      _phase = '屏息';
      _countdown = 7;
      _controller.forward(from: 0.21); // 4/19
      setState(() {});
      _tick();
      return;
    }
    if (_phase == '屏息') {
      _phase = '呼气';
      _countdown = 8;
      _controller.forward(from: 0.58); // 11/19
      setState(() {});
      _tick();
      return;
    }
    setState(() {
      _phase = '准备';
      _isRunning = false;
      _controller.reset();
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _phase = '准备';
      _countdown = 0;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          Text(
            '4-7-8 呼吸法',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '吸气 4 秒 → 屏息 7 秒 → 呼气 8 秒，有助于放松与入睡。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Container(
                width: 160 + _scaleAnimation.value * 40,
                height: 160 + _scaleAnimation.value * 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emotional.withValues(
                    alpha: 0.2 + (_scaleAnimation.value - 0.6) * 0.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _countdown > 0 ? '$_countdown' : _phase,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.emotional,
                        ),
                  ),
                ),
              );
            },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _phase,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning)
                ElevatedButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('开始'),
                )
              else
                OutlinedButton.icon(
                  onPressed: _stop,
                  icon: const Icon(Icons.stop),
                  label: const Text('停止'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
