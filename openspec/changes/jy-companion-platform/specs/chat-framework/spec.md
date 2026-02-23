## ADDED Requirements

### Requirement: WebSocket 实时对话

通过 WebSocket 建立持久连接，支持 LLM 流式文本输出。

#### Scenario: 建立 WebSocket 连接

- **WHEN** 客户端携带有效 JWT 连接 `WS /api/v1/chat/ws?token={jwt}`
- **THEN** 服务端验证 Token 有效性，建立 WebSocket 连接
- **AND** 返回连接确认消息 `{"type": "connected", "user_id": "..."}`

#### Scenario: 流式消息生成

- **WHEN** 客户端通过 WebSocket 发送 `{"type": "message", "conversation_id": "...", "content": "这道题怎么解？"}`
- **THEN** 服务端依次返回 `stream_start` → 多个 `stream_chunk` → `stream_end`
- **AND** 每个 chunk 包含增量文本，stream_end 包含 token 用量和响应时间元数据
- **AND** 常规问答 P95 响应时间 ≤3 秒

#### Scenario: 连接异常恢复

- **WHEN** WebSocket 连接因网络波动断开
- **THEN** 客户端在 5 秒内自动重连
- **AND** 恢复到断开前的会话上下文，不丢失对话历史

### Requirement: 会话管理

支持创建、查询、删除会话，会话关联特定智能体类型。

#### Scenario: 创建新会话

- **WHEN** 用户调用 `POST /api/v1/chat/conversations` 并指定 `agent_type: "academic"`
- **THEN** 系统创建会话记录，关联用户ID、智能体类型、人设ID
- **AND** 返回会话 ID 和初始欢迎消息

#### Scenario: 加载历史消息

- **WHEN** 用户请求 `GET /api/v1/chat/conversations/{id}/messages?page=1&size=20`
- **THEN** 返回该会话最近 20 条消息，按时间倒序
- **AND** 每条消息包含 role、content、content_type、emotion_label、created_at

### Requirement: 多模态输入

支持文本、语音、图片三种输入方式。

#### Scenario: 图片输入（拍照提问）

- **WHEN** 用户拍照并发送图片消息 `{"content_type": "image", "attachments": ["base64..."]}`
- **THEN** 系统调用 OCR 服务提取文字，结合文字内容进行理解和回答
- **AND** 返回对图片内容的分析结果

#### Scenario: 语音输入

- **WHEN** 用户发送语音消息 `{"content_type": "audio", "attachments": ["base64..."]}`
- **THEN** 系统调用 ASR 服务将语音转为文本
- **AND** 将转写文本作为用户输入继续对话流程
