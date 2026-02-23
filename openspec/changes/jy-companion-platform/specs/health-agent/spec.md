## ADDED Requirements

### Requirement: 久坐与用眼行为监测

通过终端设备监测用户使用时长和用眼距离。

#### Scenario: 连续使用计时

- **WHEN** 学生连续使用平台超过 40 分钟
- **THEN** 系统强制触发休息提醒弹窗，要求至少休息 5 分钟
- **AND** 提醒触达率 ≥95%

#### Scenario: 屏幕时间上报

- **WHEN** 客户端每 5 分钟调用 `POST /api/v1/health/screen-time` 上报使用数据
- **THEN** 系统记录屏幕使用时长、姿态评分、面部距离
- **AND** 监测准确率 ≥90%

### Requirement: 个性化健康提醒

基于用户行为数据和健康模型，智能推送健康提醒。

#### Scenario: 智能推送提醒

- **WHEN** 系统检测到用户连续使用 25 分钟
- **THEN** 推送"起身活动一下"或"远眺放松"等温和提醒
- **AND** 提醒内容根据时间段和使用场景个性化调整

#### Scenario: 获取提醒配置

- **WHEN** 用户请求 `GET /api/v1/health/reminders`
- **THEN** 返回当前的提醒间隔、强制休息阈值、通知方式等配置
- **AND** 支持通过 `PUT /api/v1/health/reminders` 自定义配置

### Requirement: 运动计划与动作指导

根据用户体质数据生成个性化微运动计划。

#### Scenario: 获取运动计划

- **WHEN** 用户请求 `GET /api/v1/health/exercise-plan`
- **THEN** 系统根据年龄、性别、日常活动强度生成每日微运动计划
- **AND** 包含拉伸、力量、协调三类动作，每组 5-10 分钟
- **AND** 动作校正反馈延迟 ≤1 秒（使用计算机视觉时）
