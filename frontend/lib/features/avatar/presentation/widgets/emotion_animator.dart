import 'package:rive/rive.dart';

/// 情感-动画映射驱动。
/// 将情感标签映射为 Rive 状态机输入（Number "Emotion" 或 Trigger），
/// 供 [AvatarRenderer] 的 controller 使用。
///
/// 约定（与 Rive 资源一致时生效）：
/// - Number 输入 `Emotion`：0～1，0 为负向、0.5 中性、1 为正向。
/// - 可选 Trigger 输入：如 `Happy`、`Sad`、`Neutral`、`Blink` 等，按需在 .riv 中配置。
class EmotionAnimator {
  EmotionAnimator._();

  /// 情感标签到 0～1 数值的映射（0=负向, 0.5=中性, 1=正向）
  static const Map<String, double> emotionToValueMap = {
    'happy': 0.85,
    'joy': 0.9,
    'excited': 0.9,
    'grateful': 0.75,
    'calm': 0.6,
    'neutral': 0.5,
    'peaceful': 0.55,
    'sad': 0.15,
    'anxious': 0.25,
    'angry': 0.2,
    'frustrated': 0.25,
    'tired': 0.35,
    'confused': 0.4,
  };

  /// 可选：离散情感对应的 Trigger 名称（若 Rive 状态机中有同名 Trigger）
  static const Map<String, String> _emotionToTrigger = {
    'happy': 'Happy',
    'joy': 'Happy',
    'excited': 'Excited',
    'sad': 'Sad',
    'neutral': 'Neutral',
    'angry': 'Angry',
  };

  /// 将情感标签转换为 0～1 数值（供平滑过渡等使用）。
  static double emotionToValue(String emotion) {
    final normalized = emotion.trim().toLowerCase();
    return emotionToValueMap[normalized] ??
        emotionToValueMap[normalized.replaceAll(RegExp(r'\s+'), '_')] ??
        0.5;
  }

  /// 将情感标签应用到 controller 的状态机。
  /// [emotion] 为当前情感标签（如 "happy"、"sad"），不区分大小写。
  /// [controller] 为 [AvatarRenderer] 通过 [onControllerReady] 提供的控制器。
  /// [numberInputName] 状态机中 Number 输入名，默认 "Emotion"。
  static void applyEmotion(
    RiveWidgetController controller,
    String emotion, {
    String numberInputName = 'Emotion',
  }) {
    final sm = controller.stateMachine;
    if (sm == null) return;

    final normalized = emotion.trim().toLowerCase();
    final value = emotionToValue(normalized);

    sm.number(numberInputName)?.value = value;

    final triggerName = _emotionToTrigger[normalized];
    if (triggerName != null) {
      sm.trigger(triggerName)?.fire();
    }
  }

  /// 仅设置 Number 输入（不触发 Trigger），可用于平滑过渡或外部插值。
  static void setEmotionValue(
    RiveWidgetController controller,
    double value, {
    String numberInputName = 'Emotion',
  }) {
    controller.stateMachine?.number(numberInputName)?.value =
        value.clamp(0.0, 1.0);
  }

  /// 触发一次指定名称的 Trigger（如 "Blink"、"Speak"）。
  static void fireTrigger(RiveWidgetController controller, String triggerName) {
    controller.stateMachine?.trigger(triggerName)?.fire();
  }
}
