/// 预设学伴数字形象配置。
///
/// 每个预设对应一个 .riv 文件，包含统一的状态机约定：
/// - State Machine: 默认（或指定名称）
/// - Number "Emotion": 0～1（0=负向, 0.5=中性, 1=正向）
/// - Number "Mouth": 0～1（口型开合度）
/// - Trigger "Speak": 开始说话
/// - 可选 Trigger: Happy / Sad / Neutral / Angry / Excited
class AvatarPreset {
  const AvatarPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
    this.stateMachineName,
    this.artboardName,
    this.themeColor,
    this.tags = const [],
  });

  /// 唯一标识
  final String id;

  /// 显示名称
  final String name;

  /// 简短描述
  final String description;

  /// .riv 资源路径（相对于 assets/）
  final String assetPath;

  /// 状态机名称，null 使用默认
  final String? stateMachineName;

  /// Artboard 名称，null 使用默认
  final String? artboardName;

  /// 主题色（十六进制），用于 UI 搭配
  final int? themeColor;

  /// 标签：如 "学术"、"陪伴"、"创意"
  final List<String> tags;

  /// ── 预设形象列表 ──

  static const xiaoyuan = AvatarPreset(
    id: 'xiaoyuan',
    name: '小元',
    description: '学术型伙伴，擅长学科辅导与课堂回顾',
    assetPath: 'assets/animations/avatar/xiaoyuan.riv',
    themeColor: 0xFF1565C0,
    tags: ['学术', '辅导'],
  );

  static const xiaoban = AvatarPreset(
    id: 'xiaoban',
    name: '小伴',
    description: '温暖陪伴型，善于倾听与情感支持',
    assetPath: 'assets/animations/avatar/xiaoban.riv',
    themeColor: 0xFFAD1457,
    tags: ['陪伴', '情感'],
  );

  static const xiaochuang = AvatarPreset(
    id: 'xiaochuang',
    name: '小创',
    description: '创意探索型，激发灵感与头脑风暴',
    assetPath: 'assets/animations/avatar/xiaochuang.riv',
    themeColor: 0xFF6A1B9A,
    tags: ['创意', '探索'],
  );

  /// 所有预设
  static const List<AvatarPreset> all = [xiaoyuan, xiaoban, xiaochuang];

  /// 按 id 查找
  static AvatarPreset? findById(String id) {
    for (final preset in all) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  /// 默认形象
  static const AvatarPreset defaultPreset = xiaoyuan;
}
