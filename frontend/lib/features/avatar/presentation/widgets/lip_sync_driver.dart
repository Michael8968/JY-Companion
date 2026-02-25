import 'package:rive/rive.dart';

/// TTS 口型同步驱动：将 TTS 播放状态映射到 Rive 面部口型动画。
///
/// 约定（与 Rive 资源一致时生效）：
/// - Trigger `Speak`：开始说话时 fire，用于触发口型动画。
/// - Number `Mouth`：0～1 表示口型开合程度，0=闭合，1=最大张开。
///
/// 为满足「误差 ≤100ms」，请在 TTS 播放开始/结束的同一回调中立即调用
/// [startSpeaking] / [stopSpeaking]，避免额外延迟。
class LipSyncDriver {
  LipSyncDriver({
    this.speakTriggerName = 'Speak',
    this.mouthNumberName = 'Mouth',
  });

  final String speakTriggerName;
  final String mouthNumberName;

  RiveWidgetController? _controller;
  bool _isSpeaking = false;

  /// 绑定 Rive 控制器（由 [AvatarRenderer.onControllerReady] 传入）。
  void bind(RiveWidgetController controller) {
    _controller = controller;
  }

  /// 解绑控制器。
  void unbind() {
    _controller = null;
    _isSpeaking = false;
  }

  /// 是否已绑定且正在说话。
  bool get isSpeaking => _isSpeaking && _controller != null;

  /// TTS 开始播放时调用，驱动口型开始（fire Speak + 设 Mouth 为开口）。
  void startSpeaking() {
    final sm = _controller?.stateMachine;
    if (sm == null) return;
    _isSpeaking = true;
    sm.trigger(speakTriggerName)?.fire();
    sm.number(mouthNumberName)?.value = 0.7;
  }

  /// TTS 结束播放时调用，驱动口型闭合。
  void stopSpeaking() {
    final sm = _controller?.stateMachine;
    if (sm == null) return;
    _isSpeaking = false;
    sm.number(mouthNumberName)?.value = 0.0;
  }

  /// 按当前音频电平更新口型开合（0～1），用于更精细的同步。
  /// 若 TTS 播放器能提供实时音量或 phoneme 等级，可每帧/每 50ms 调用以提升同步精度。
  void setMouthLevel(double level) {
    final sm = _controller?.stateMachine;
    if (sm == null) return;
    sm.number(mouthNumberName)?.value = level.clamp(0.0, 1.0);
  }
}
