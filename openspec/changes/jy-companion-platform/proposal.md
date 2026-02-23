## Why

星澜中学作为上海市人工智能教育实验校，现有数字化实践难以满足学生个性化、分层化的自主学习需求。响应国家《关于深入实施"人工智能+"行动的意见》，需构建基于华东师范大学「启创·InnoSpark 1.0」教育大模型的 AI 智能学伴平台，覆盖学业辅导、心理陪伴、健康守护等领域，实现大规模因材施教。

## What Changes

- 从零构建五层架构的 AI 智能学伴平台（基础资源层 → 智能中枢层 → 能力模块层 → 人格交互层 → 应用场景层）
- 实现六大智能体：学业辅导、课堂复盘、情感陪伴、健康守护、创意创作、生涯规划
- 构建跨平台客户端（Flutter iOS/Android/Desktop）+ FastAPI 后端 + AI 推理服务
- 集成 RAG 知识库（Milvus 向量检索 + Neo4j 知识图谱）支撑校本教学资源精准匹配
- 实现人格化对话系统（多学伴角色、数字形象、情感驱动动画）
- 建立内容安全与危机预警体系（违规拦截率 ≥99%，危机预警 ≤30s）
- 完成等保2.0三级合规与数据安全全链路加密

## Capabilities

### New Capabilities

- `auth-system`: 用户认证与权限管理 — OAuth2 + JWT + SSO 统一身份认证，RBAC 四角色权限控制
- `chat-framework`: 核心对话框架 — WebSocket 实时流式对话，多模态输入（文本/语音/图片），上下文管理
- `intelligent-hub`: 智能中枢层 — 意图识别分类、多源情景感知融合、DAG 任务编排与多智能体协同
- `academic-agent`: 学业辅导智能体 — 多学科答疑、CoT 解题引导、错因诊断、举一反三练习推荐
- `classroom-agent`: 课堂复盘智能体 — ASR 课堂转写、结构化摘要、个性化学案生成、疑问点识别
- `emotional-agent`: 情感陪伴智能体 — 多模态情绪识别、共情对话、积极心理学干预、危机预警
- `health-agent`: 健康守护智能体 — 久坐/用眼监测、个性化健康提醒、运动指导
- `creative-agent`: 创意创作智能体 — AIGC 多模态创意激发、创作协作优化、作品评价赏析
- `career-agent`: 生涯规划智能体 — SMART 目标管理、个性化学习路径、进度追踪复盘
- `persona-interaction`: 人格交互层 — 人设配置、风格化文本生成、学伴社区群、数字形象渲染、情感表达映射
- `content-safety`: 内容安全与合规 — 多维内容过滤、价值观对齐、未成年人保护、数据脱敏加密
- `infrastructure`: 基础设施与部署 — Docker/K8s 容器化、CI/CD 流水线、监控告警、灾备方案

## Impact

- `frontend/`: Flutter 跨平台应用（iOS/Android/Desktop），BLoC 状态管理，Rive 数字形象
- `backend/`: FastAPI 后端服务，SQLAlchemy ORM，智能中枢层，六大智能体业务逻辑
- `ai_services/`: LLM 推理服务(vLLM)，RAG 管线，多模态引擎(ASR/TTS/OCR/情感)，内容安全
- `shared/`: gRPC Proto 定义，共享常量，事件定义
- `infrastructure/`: Docker/K8s 配置，监控，部署脚本
- `docs/`: 架构文档，API 设计文档，数据库 Schema
