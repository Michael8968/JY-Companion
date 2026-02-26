# Rive 学伴数字形象资源规范

本文档定义 .riv 文件的制作规范，确保与 Flutter 代码层（`AvatarRenderer`、`EmotionAnimator`、`LipSyncDriver`）无缝对接。

## 需要的文件

| 文件名 | 形象 | 风格 | 主色 |
|--------|------|------|------|
| `xiaoyuan.riv` | 小元 — 学术型 | 圆润卡通，戴眼镜，书卷气 | `#1565C0` |
| `xiaoban.riv` | 小伴 — 陪伴型 | 柔软圆形生物/水滴状，表情丰富 | `#AD1457` |
| `xiaochuang.riv` | 小创 — 创意型 | 几何变形体，色彩鲜明 | `#6A1B9A` |

## 状态机约定（所有形象统一）

**State Machine 名称**: 使用默认（Default），或统一命名 `MainStateMachine`

### 必须的输入（Inputs）

| 类型 | 名称 | 值域 | 用途 |
|------|------|------|------|
| Number | `Emotion` | 0.0 ~ 1.0 | 情感驱动（0=负向, 0.5=中性, 1=正向） |
| Number | `Mouth` | 0.0 ~ 1.0 | 口型同步（0=闭合, 1=最大张开） |
| Trigger | `Speak` | — | TTS 开始说话时触发 |

### 推荐的输入（可选）

| 类型 | 名称 | 用途 |
|------|------|------|
| Trigger | `Happy` | 切换到开心状态 |
| Trigger | `Sad` | 切换到悲伤状态 |
| Trigger | `Neutral` | 回到中性状态 |
| Trigger | `Angry` | 切换到生气状态 |
| Trigger | `Excited` | 切换到兴奋状态 |
| Boolean | `isTalking` | 持续说话状态（替代 Mouth 的简化方案） |

## Emotion 数值映射参考

代码中 `EmotionAnimator` 的映射表：

```
happy    → 0.85    sad       → 0.15
joy      → 0.90    anxious   → 0.25
excited  → 0.90    angry     → 0.20
grateful → 0.75    frustrated→ 0.25
calm     → 0.60    tired     → 0.35
neutral  → 0.50    confused  → 0.40
peaceful → 0.55
```

建议在 Rive 中设计动画混合区间：
- **0.0 ~ 0.3**: 负面表情区（皱眉、低头、嘴角下垂）
- **0.3 ~ 0.7**: 中性过渡区（平静、微微表情变化）
- **0.7 ~ 1.0**: 正面表情区（微笑、眼睛发亮、跳动）

## 动画层建议

1. **Idle 层**: 常驻微动画（轻微呼吸、眨眼），独立循环
2. **Emotion 层**: 受 Number `Emotion` 驱动，混合不同表情
3. **Mouth 层**: 受 Number `Mouth` 驱动，嘴型骨骼动画
4. **Special 层**: Trigger 触发的一次性动画（挥手、惊讶等）

## 技术要求

- **画板尺寸**: 建议 500x500 或 512x512 px
- **文件大小**: 每个 .riv 控制在 500KB 以内（移动端加载性能）
- **帧率**: 动画设计按 60fps，运行时由设备决定实际帧率
- **骨骼**: 面部建议使用骨骼绑定而非逐帧，利于 Number 输入平滑驱动

## 快速开始：从社区模板改造

推荐的社区起点（均 CC BY 许可）：

1. **[Avatar Pack](https://rive.app/community/files/2195-4346-avatar-pack-use-case/)**
   - 3 个角色，已有 idle/happy/sad 状态
   - 适合改造为小元、小伴、小创的基础

2. **[Avatar Creator](https://rive.app/community/files/6236-12120-avatar-creator/)**
   - 完整骨骼绑定 + 状态机示例
   - 适合学习 Rive 状态机设计模式

3. **[My Avatar](https://rive.app/community/files/554-1038-my-avatar/)**
   - 交互式反应动画
   - 适合参考眨眼和 hover 反应实现

### 改造步骤

1. 在 [rive.app](https://rive.app) 注册（免费）并 Remix 上述模板
2. 修改角色外观（配色、五官、服饰）
3. 添加 `Emotion` Number 输入和对应的混合动画
4. 添加 `Mouth` Number 输入和嘴型骨骼
5. 添加 `Speak` Trigger
6. 导出 .riv 文件放到本目录
7. 在 Flutter 中运行验证：`AvatarRenderer(assetPath: 'assets/animations/avatar/xiaoyuan.riv')`
