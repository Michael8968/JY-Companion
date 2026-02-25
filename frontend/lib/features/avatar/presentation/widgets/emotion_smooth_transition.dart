import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'emotion_animator.dart';

/// 情感状态平滑过渡驱动（状态机 + 插值）。
/// 使用 [TickerProvider] 驱动每帧插值，将 Rive 状态机中的 Number 输入从当前值平滑过渡到目标值，
/// 满足「流畅度 ≥90%」的过渡效果。
///
/// 用法：在拥有 [TickerProvider] 的 [State] 中创建 [EmotionSmoothDriver]，
/// 在 [initState] 中创建，在 [dispose] 中调用 [dispose]；情感变化时调用 [setTargetEmotion]。
class EmotionSmoothDriver {
  EmotionSmoothDriver(
    this._vsync, {
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeInOut,
    String numberInputName = 'Emotion',
  })  : _duration = duration,
        _curve = curve,
        _numberInputName = numberInputName;

  final TickerProvider _vsync;
  final Duration _duration;
  final Curve _curve;
  final String _numberInputName;

  AnimationController? _controller;
  bool _disposed = false;

  /// 将情感平滑过渡到 [emotionLabel] 对应的数值。
  /// 若 controller 或 stateMachine 不可用则无操作；若目标与当前值接近则直接设值。
  void setTargetEmotion(RiveWidgetController riveController, String emotionLabel) {
    if (_disposed) return;

    final sm = riveController.stateMachine;
    if (sm == null) return;

    final numberInput = sm.number(_numberInputName);
    if (numberInput == null) return;

    final targetValue = EmotionAnimator.emotionToValue(emotionLabel);
    final currentValue = numberInput.value;
    if ((currentValue - targetValue).abs() < 0.005) {
      EmotionAnimator.setEmotionValue(
        riveController,
        targetValue,
        numberInputName: _numberInputName,
      );
      return;
    }

    _controller?.stop();
    _controller?.dispose();
    _controller = AnimationController(
      duration: _duration,
      vsync: _vsync,
    );

    final animation = Tween<double>(begin: currentValue, end: targetValue)
        .animate(CurvedAnimation(parent: _controller!, curve: _curve));

    void onTick() {
      if (_disposed || riveController.stateMachine == null) return;
      EmotionAnimator.setEmotionValue(
        riveController,
        animation.value,
        numberInputName: _numberInputName,
      );
    }

    animation.addListener(onTick);
    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        EmotionAnimator.setEmotionValue(
          riveController,
          targetValue,
          numberInputName: _numberInputName,
        );
        animation.removeListener(onTick);
        _controller?.dispose();
        _controller = null;
      }
    });
    _controller!.forward();
  }

  /// 将情感值平滑过渡到 [targetValue]（0～1），不经过情感标签。
  void setTargetValue(RiveWidgetController riveController, double targetValue) {
    if (_disposed) return;

    final sm = riveController.stateMachine;
    if (sm == null) return;

    final numberInput = sm.number(_numberInputName);
    if (numberInput == null) return;

    final clamped = targetValue.clamp(0.0, 1.0);
    final currentValue = numberInput.value;
    if ((currentValue - clamped).abs() < 0.005) {
      EmotionAnimator.setEmotionValue(
        riveController,
        clamped,
        numberInputName: _numberInputName,
      );
      return;
    }

    _controller?.stop();
    _controller?.dispose();
    _controller = AnimationController(
      duration: _duration,
      vsync: _vsync,
    );

    final animation = Tween<double>(begin: currentValue, end: clamped)
        .animate(CurvedAnimation(parent: _controller!, curve: _curve));

    void onTick() {
      if (_disposed || riveController.stateMachine == null) return;
      EmotionAnimator.setEmotionValue(
        riveController,
        animation.value,
        numberInputName: _numberInputName,
      );
    }

    animation.addListener(onTick);
    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        EmotionAnimator.setEmotionValue(
          riveController,
          clamped,
          numberInputName: _numberInputName,
        );
        animation.removeListener(onTick);
        _controller?.dispose();
        _controller = null;
      }
    });
    _controller!.forward();
  }

  /// 释放驱动（取消未完成的动画并释放 [AnimationController]）。
  void dispose() {
    _disposed = true;
    _controller?.stop();
    _controller?.dispose();
    _controller = null;
  }
}
