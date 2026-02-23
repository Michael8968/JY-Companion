## ADDED Requirements

### Requirement: 目标管理与拆解

协助用户确立目标并按 SMART 原则科学拆解。

#### Scenario: 创建长期目标

- **WHEN** 用户通过 `POST /api/v1/career/goals` 输入"高考数学考到130分以上"
- **THEN** 系统引导用户按 SMART 原则完善目标（具体、可衡量、可达成、相关、有时限）
- **AND** 自动将目标拆解为 ≥3 层子任务节点

#### Scenario: 目标层级拆解

- **WHEN** 目标创建完成
- **THEN** 系统生成子任务树，如：月度计划 → 周计划 → 每日任务
- **AND** 每个子任务包含预估时间和优先级
- **AND** 目标拆解层级 ≥3 层

#### Scenario: 目标进度更新

- **WHEN** 用户完成子任务并更新 `PUT /api/v1/career/goals/{id}`
- **THEN** 系统自动计算父目标进度百分比
- **AND** 进度变化可视化展示

### Requirement: 个性化学习路径规划

基于兴趣和能力评估，生成动态适配的学习路径。

#### Scenario: 学习路径推荐

- **WHEN** 用户请求 `GET /api/v1/career/learning-path`
- **THEN** 系统基于兴趣倾向、能力评估与发展目标
- **AND** 利用知识图谱推荐课程、书籍、实践项目的序列化学习资源
- **AND** 路径推荐满意度 ≥80%

#### Scenario: 路径动态调整

- **WHEN** 用户完成某阶段学习并更新能力评分
- **THEN** 系统动态调整后续学习路径推荐
- **AND** 保持推荐与当前水平的适配度

### Requirement: 进度追踪与复盘反馈

以仪表盘形式可视化展示目标进度，定期生成复盘报告。

#### Scenario: 周报告生成

- **WHEN** 每周日系统自动触发或用户请求 `GET /api/v1/career/progress-report`
- **THEN** 生成包含甘特图、完成率统计、偏差分析的周报告
- **AND** 提供目标调整和时间管理建议
- **AND** 报告生成周期：每周
