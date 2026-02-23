## Context

晋元中学 AI 智能学伴平台是一个从零构建的教育 AI 系统。项目基于华东师范大学「启创·InnoSpark 1.0」教育大模型，采用五层架构，涵盖六大智能体。当前仓库仅有产品说明书文档，无任何代码。团队 10+ 人，6 个月交付。

## Goals / Non-Goals

**Goals:**
- 构建可支撑 500+ 并发用户的稳定平台
- 实现六大智能体全功能覆盖
- 达成产品说明书中所有性能与安全指标
- 建立可持续演进的代码架构和 CI/CD 体系

**Non-Goals:**
- AR/可穿戴设备集成（列入后续版本）
- 3D 数字形象（首期使用 2D Rive 动画）
- 多语言国际化（首期仅支持中文）
- 手势与体态识别（首期不集成摄像头姿态分析）

---

## Decisions

### Decision 1: Monorepo 单仓库结构

采用 Monorepo 管理前端、后端、AI 服务、基础设施代码。

**理由**: 团队 10+ 人规模适合单仓协作，跨模块变更可原子提交，共享 CI/CD 流水线，减少跨仓库同步成本。

```
JY-Companion/
├── frontend/          # Flutter 跨平台应用
├── backend/           # FastAPI 后端服务
├── ai_services/       # AI 推理服务
├── shared/            # 跨服务共享（Proto/常量/事件）
├── infrastructure/    # Docker/K8s/监控配置
├── scripts/           # 工具脚本
└── docs/              # 文档
```

### Decision 2: 前端架构 — Flutter + BLoC + Clean Architecture

**选型**: Flutter 3.24+ / Dart 3.5+

**理由**: 一套代码覆盖 iOS、Android、Desktop 三端，BLoC 事件驱动模式适合复杂状态管理（多智能体切换、流式对话、情感动画），Clean Architecture 分层保持模块独立性。

**核心依赖**:
| 用途 | 库 |
|------|-----|
| 状态管理 | flutter_bloc ^8.1 |
| 路由 | go_router ^14.0 |
| 网络 | dio ^5.4 + web_socket_channel ^3.0 |
| 本地存储 | hive_ce ^2.6 + drift ^2.18 |
| DI | get_it + injectable |
| 模型 | freezed + json_serializable |
| 数字形象 | rive ^0.13 |
| 语音 | speech_to_text ^7.0 + just_audio ^0.9 |
| 图表 | fl_chart ^0.68 |
| 数学公式 | flutter_math_fork ^0.7 |

**目录约定**: 每个 feature 遵循 `data/` → `domain/` → `presentation/` 三层结构。

### Decision 3: 后端架构 — FastAPI + 异步全链路

**选型**: Python FastAPI ^0.115 + uvicorn ^0.32

**理由**: 与 AI/ML 生态（PyTorch、vLLM、sentence-transformers）无缝衔接，原生异步支持高并发 WebSocket 连接，Pydantic 自动 API 文档。

**核心依赖**:
| 用途 | 库 |
|------|-----|
| ORM | SQLAlchemy ^2.0 (async) + Alembic ^1.14 |
| 认证 | python-jose + authlib |
| 任务队列 | Celery ^5.4 |
| 缓存 | Redis ^7.4 |
| 日志 | structlog ^24.4 |
| 监控 | prometheus-fastapi-instrumentator |
| 测试 | pytest + pytest-asyncio |
| 包管理 | uv ^0.5 |

**后端分层**:
```
app/
├── api/v1/        # 路由层（薄，只做参数校验和转发）
├── services/      # 业务逻辑层
├── repositories/  # 数据访问层
├── hub/           # 智能中枢层（意图识别 + 编排）
├── agents/        # 六大智能体实现
├── persona/       # 人格交互层后端
└── models/        # ORM 模型
```

### Decision 4: 数据库多引擎策略

| 引擎 | 版本 | 用途 | 理由 |
|------|------|------|------|
| PostgreSQL | 16+ | 核心业务数据（用户/会话/学习记录/预警） | 关系型事务强一致，pgvector 扩展备选 |
| Milvus | 2.4+ | 向量检索（知识库/会话语义检索） | 高性能 ANN 搜索，HNSW 索引 |
| Neo4j | 5.x | 知识图谱（学科→知识点→练习题） | 多跳查询、路径发现、关联推理 |
| Redis | 7.4+ | 缓存 + 消息 + 限流 | 情景快照/会话缓存/限流计数器 |
| MongoDB | 7.0+ | 非结构化数据（课堂笔记/创作内容） | 灵活 Schema |
| MinIO | -- | 对象存储（音频/图片/视频/头像） | S3 兼容，私有化部署 |

### Decision 5: AI 推理服务架构

**LLM 推理**: vLLM ^0.6 部署 InnoSpark 1.0，支持高吞吐批处理推理。

**RAG 管线**:
```
用户查询 → BGE-large-zh 向量化 → Milvus Top-K 检索 → 重排序(Reranker)
                                                          ↓
                                    Neo4j 知识图谱关联查询 → 合并上下文 → LLM 生成
```

**多模态服务**:
| 能力 | 引擎 | 部署方式 |
|------|------|----------|
| ASR | FunASR (Paraformer-large) | 独立微服务 |
| TTS | CosyVoice / VITS | 独立微服务 |
| OCR | PaddleOCR | 独立微服务 |
| 情感识别 | 自训练多模态融合模型 | 独立微服务 |

**服务间通信**: gRPC（高频低延迟调用）+ HTTP（管理接口）

### Decision 6: 智能中枢层 — DAG 任务编排

意图识别 → 智能体路由 → DAG 任务编排 → 结果聚合。

```
用户输入 → [意图分类器] → intent_label + confidence
              ↓
         [情景引擎] → context_snapshot (画像+历史+环境)
              ↓
         [任务规划器] → 分解为子任务 DAG
              ↓
         [编排器] → 并行/串行调度智能体 → 聚合结果
              ↓
         [人格控制器] → 风格化包装 → 流式输出
```

**智能体基类设计**: 所有智能体继承 `BaseAgent`，统一接口：
- `async def process(input, context) -> AgentResponse`
- `async def health_check() -> bool`
- `def get_capabilities() -> list[str]`

### Decision 7: 危机预警快速通道 [SAFETY-CRITICAL]

危机预警不经过 LLM 推理，在请求管道前置做同步检查：

```
用户消息 → [关键词前置检查(同步, <100ms)] → 命中? → [立即告警(Redis Pub/Sub)]
                  ↓ 未命中                              ↓
            正常对话流程                        推送教师/家长/心理专员
```

**理由**: 确保 ≤30 秒响应时间，LLM 推理可能耗时 3-10 秒，关键词前置检查在毫秒级完成。

### Decision 8: 团队分工（10+ 人）

| 角色 | 人数 | 负责 |
|------|------|------|
| 架构师 | 1 | 架构设计、技术决策、跨模块协调 |
| Flutter 高级 | 1 | 前端架构、对话UI、数字形象渲染 |
| Flutter 工程师 | 1 | 智能体页面、数据可视化 |
| 后端高级 | 1 | FastAPI架构、智能中枢、认证安全 |
| 后端工程师 | 1 | 智能体业务逻辑、数据接口 |
| AI/ML 高级 | 1 | LLM 微调/部署、RAG、Prompt |
| AI/ML 工程师 | 1 | 多模态(ASR/TTS/OCR)、内容安全 |
| 数据工程师 | 1 | 知识图谱、向量库、ETL |
| DevOps/SRE | 1 | CI/CD、K8s、监控 |
| 测试工程师 | 1 | 测试策略、自动化、性能/安全 |
| 设计师 | 1 | UI/UX、数字形象、原型 |

### Decision 9: 数据库 Schema 核心设计

**用户系统**: `users` (UUID PK, role enum, SSO 关联) → `user_profiles` (JSONB 画像标签, 768维向量)

**对话系统**: `conversations` (agent_type, persona_id, context_snapshot JSONB) → `messages` (role, content_type, emotion_label, intent_label)

**学业**: `learning_records` (subject, error_type, difficulty, knowledge_points JSONB) → `error_records` (mastery_status, recommended_exercises)

**情感**: `emotion_records` (valence, arousal, source) + `crisis_alerts` [SAFETY-CRITICAL] (alert_level, response_time_ms, ≤30s)

**人设**: `personas` (≥20维 personality JSONB, system_prompt) → `user_personas` (多对多绑定)

### Decision 10: API 设计规范

- 前缀: `/api/v1/`
- 格式: RESTful JSON + WebSocket (实时对话)
- 认证: OAuth 2.0 + JWT (Authorization: Bearer)
- 限流: 学生 100/min, 教师 500/min, 管理员不限
- 版本: URL 路径版本控制
- 文档: FastAPI 自动 OpenAPI 文档
