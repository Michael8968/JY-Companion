# 前端动画性能（移动端 ≥30fps）

为满足「移动端渲染帧率 ≥30fps」，已采用以下做法：

- **Avatar / Rive**：`AvatarRenderer` 内对 `RiveWidget` 使用 `RepaintBoundary` 隔离，避免 Rive 每帧重绘导致整树重绘。
- **情感平滑**：`EmotionSmoothDriver` 仅更新 Rive 状态机输入，不触发 Widget 树 `setState`，减少不必要的 rebuild。
- **呼吸练习**：`BreathingGuideWidget` 中动画圆圈使用 `RepaintBoundary` 包裹，限制重绘范围。

新增动画或高刷新区域时，建议：

1. 对每帧变化的绘制用 `RepaintBoundary` 包一层。
2. 尽量用 `AnimationController` + 回调更新单一子树，避免顶层 `setState`。
3. 列表内动画考虑 `ListView.builder` 等懒加载，避免一屏外也参与布局/绘制。
