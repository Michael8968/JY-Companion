## ADDED Requirements

### Requirement: 多模态创意激发

通过 AIGC 引擎生成创意素材，激发学生创作灵感。

#### Scenario: 文本创意生成

- **WHEN** 用户输入主题"写一个关于太空探索的科幻故事开头"到 `POST /api/v1/creative/generate`
- **THEN** 系统调用大模型生成故事大纲、角色设定、开头段落
- **AND** 生成响应时间 ≤10 秒

#### Scenario: 图像创意生成

- **WHEN** 用户输入画面描述并选择"生成图片"
- **THEN** 系统调用 AIGC 图像模型生成构图参考
- **AND** 标注"AI 生成"水印

### Requirement: 创作过程协作优化

在创作过程中提供实时智能辅助建议。

#### Scenario: 写作辅助

- **WHEN** 用户在写作过程中请求 `POST /api/v1/creative/optimize` 提交部分文稿
- **THEN** 系统提供修辞推荐、情节结构优化建议
- **AND** 辅助建议相关性 ≥80%

#### Scenario: 突破创作瓶颈

- **WHEN** 用户表达"写不下去了"或"没有灵感"
- **THEN** 系统通过提问引导、头脑风暴、随机灵感卡等方式激发思路
- **AND** 提供 3-5 个不同方向的创作建议

### Requirement: 作品评价与赏析

对用户作品进行多维分析评价。

#### Scenario: 作品多维评价

- **WHEN** 用户提交完成的作品到 `POST /api/v1/creative/evaluate`
- **THEN** 系统从叙事完整性、语言表达、情感深度、结构逻辑、创意独特性等维度分析
- **AND** 评价维度覆盖 ≥5 个
- **AND** 提供改进方向和经典作品对比赏析
