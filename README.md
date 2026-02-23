# 星澜中学 AI 智能学伴平台 (JY-Companion)

> 面向中学生的多智能体 AI 学习伴侣系统，融合学业辅导、心理关怀、健康管理、创意激发与生涯规划于一体。

## 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                    表现层 (Presentation)                  │
│  Flutter Web/Mobile  ·  数字人形象  ·  多模态交互界面      │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────┴──────────────────────────────┐
│                   API 网关层 (Gateway)                    │
│  APISIX  ·  JWT 认证  ·  角色限流  ·  WebSocket 路由      │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────┴──────────────────────────────┐
│                   业务逻辑层 (Business)                   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │              智能中枢 (Intelligent Hub)            │    │
│  │  意图识别 → 智能体路由 → DAG 编排 → 结果聚合       │    │
│  └─────────────────────────────────────────────────┘    │
│                                                         │
│  ┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐   │
│  │ 学业   ││ 课堂   ││ 情感   ││ 健康   ││ 创意   │   │
│  │ 辅导   ││ 复盘   ││ 陪伴   ││ 守护   ││ 创作   │   │
│  └────────┘└────────┘└────────┘└────────┘└────────┘   │
│  ┌────────┐┌─────────────────────────────────────┐     │
│  │ 生涯   ││        人格交互层 (Persona)           │     │
│  │ 规划   ││  3套预设人格 · 情感自适应 · 记忆图谱   │     │
│  └────────┘└─────────────────────────────────────┘     │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │            安全合规层 (Safety & Compliance)       │    │
│  │  3层内容过滤 · 危机干预 · 数据脱敏 · AES-256加密  │    │
│  └─────────────────────────────────────────────────┘    │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────┴──────────────────────────────┐
│                    数据层 (Data)                          │
│  PostgreSQL · Redis · Milvus(向量) · MinIO(对象存储)      │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────┴──────────────────────────────┐
│                   基础设施层 (Infrastructure)             │
│  K8s · Prometheus + Grafana · CI/CD · 蓝绿部署           │
└─────────────────────────────────────────────────────────┘
```

## 核心功能模块

| 智能体 | 功能 | 关键能力 |
|--------|------|----------|
| 学业辅导 | 学科答疑、知识点讲解 | CoT 推理链、苏格拉底式引导、LaTeX 公式渲染 |
| 课堂复盘 | 课堂录音分析与知识整理 | ASR 语音识别、知识图谱、个性化复习计划 |
| 情感陪伴 | 心理疏导与情绪支持 | 7维情绪识别、危机检测、三级干预机制 |
| 健康守护 | 用眼提醒与运动指导 | 久坐检测、屏幕时间监控、运动模板库 |
| 创意创作 | 写作辅导与艺术创作 | AIGC 辅助创作、5维评价体系、作品集管理 |
| 生涯规划 | 升学指导与目标管理 | SMART 目标、学习路径推荐、进度追踪 |

## 安全特性

- **内容安全**: 3 层过滤（26+ 关键词 → 7 逃避模式检测 → 3 上下文规则）
- **危机干预**: 100% 召回率目标，<100ms 响应，自动触发三级预警
- **数据保护**: AES-256-GCM 字段加密、6 策略数据脱敏、TLS 1.3
- **访问控制**: JWT + RBAC 四角色（学生/教师/家长/管理员）

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | Flutter 3.x (Web + Mobile) |
| 后端 | Python 3.12 + FastAPI + SQLAlchemy 2.0 (async) |
| AI 引擎 | Claude API · RAG (Milvus) · ASR/TTS |
| 数据库 | PostgreSQL 16 · Redis 7 |
| 网关 | Apache APISIX |
| 基础设施 | Kubernetes · Prometheus · Grafana · GitHub Actions |
| 包管理 | uv (Python) · Flutter SDK |
| 代码质量 | ruff (lint + format) · pytest (394 tests) |

## 项目结构

```
JY-Companion/
├── backend/                    # FastAPI 后端
│   ├── app/
│   │   ├── api/                # API 路由
│   │   │   └── v1/            # v1 版本端点
│   │   ├── core/              # 核心配置
│   │   │   ├── config.py      # 应用配置
│   │   │   ├── security.py    # JWT + 密码哈希
│   │   │   ├── encryption.py  # AES-256-GCM 加密
│   │   │   └── exceptions.py  # 自定义异常
│   │   ├── models/            # SQLAlchemy 模型
│   │   ├── schemas/           # Pydantic 模式
│   │   ├── services/          # 业务服务
│   │   │   ├── agents/        # 6 大智能体
│   │   │   ├── intelligent_hub/ # 意图识别 + 编排
│   │   │   ├── persona/       # 人格交互系统
│   │   │   ├── content_safety.py
│   │   │   ├── data_masking.py
│   │   │   └── cache.py
│   │   └── integrations/      # 外部系统集成
│   ├── tests/unit/            # 单元测试 (394 tests)
│   ├── alembic/               # 数据库迁移
│   └── pyproject.toml
├── frontend/                   # Flutter 前端
│   └── jy_companion/
├── infrastructure/
│   ├── k8s/                   # Kubernetes 配置
│   │   ├── base/              # Kustomize 基础
│   │   └── overlays/          # 环境覆盖
│   ├── monitoring/            # Prometheus + Grafana
│   ├── gateway/               # APISIX 网关配置
│   └── ci/                    # GitHub Actions
├── openspec/                   # OpenSpec 规格文档
│   └── changes/
│       └── jy-companion-platform/
│           ├── proposal.md
│           ├── design.md
│           ├── tasks.md       # 109 任务清单
│           └── specs/         # 12 模块规格
└── README.md
```

## 快速开始

### 环境要求

- Python 3.12+
- uv (Python 包管理器)
- PostgreSQL 16+
- Redis 7+

### 后端启动

```bash
# 1. 进入后端目录
cd backend

# 2. 安装依赖
uv sync

# 3. 配置环境变量
cp .env.example .env
# 编辑 .env 填入数据库连接等配置

# 4. 运行数据库迁移
uv run alembic upgrade head

# Windows 下若出现 UnicodeDecodeError（连接 Docker 内 PostgreSQL），可改用 Docker 内迁移：
#   cd infrastructure/docker
#   docker compose run --rm migrate
# 或在删除旧数据卷后用 UTF-8 重新初始化：
#   docker compose down postgres
#   docker volume rm docker_postgres_data
#   docker compose up -d postgres
#   等待几秒后回到 backend 执行：uv run alembic upgrade head

# 5. 启动开发服务器
uv run uvicorn app.main:app --reload --port 8000
```

### 运行测试

```bash
cd backend
uv run pytest tests/ -v
# 当前: 394 tests, all passing
```

## API 概览

| 模块 | 端点 | 说明 |
|------|------|------|
| 认证 | `POST /api/v1/auth/register` | 用户注册 |
| | `POST /api/v1/auth/login` | 登录获取 JWT |
| | `POST /api/v1/auth/sso/{provider}` | SSO 单点登录 |
| 对话 | `WS /api/v1/chat/ws` | WebSocket 实时对话 |
| | `POST /api/v1/chat/conversations` | 创建会话 |
| | `GET /api/v1/chat/conversations` | 会话列表 |
| 智能体 | `POST /api/v1/agents/{type}/query` | 智能体查询 |
| 人格 | `GET /api/v1/persona/presets` | 预设人格列表 |
| | `PUT /api/v1/persona/switch` | 切换人格 |
| 管理 | `GET /api/v1/admin/users` | 用户管理 |
| | `GET /api/v1/admin/stats` | 平台统计 |
| | `GET /api/v1/admin/alerts` | 危机预警 |
| | `GET /api/v1/admin/audit` | 内容审计 |
| 健康检查 | `GET /api/v1/health` | 服务健康状态 |

## 生产部署

### Kubernetes 部署

```bash
# 开发环境
kubectl apply -k infrastructure/k8s/base/

# 生产环境 (含 HPA + 备份)
kubectl apply -k infrastructure/k8s/overlays/production/
```

### 生产配置要点

- **HPA**: 3-10 Pod 自动伸缩，CPU 阈值 70%
- **备份**: 每日全量 + 每6小时增量 PostgreSQL 备份
- **监控**: Prometheus 7 目标采集 + Grafana 仪表盘
- **告警**: 包含危机干预专用告警规则（safety-critical）
- **网关**: APISIX 角色级限流（学生 30/min, 教师 100/min）

## 开发计划

| Sprint | 内容 | 状态 |
|--------|------|------|
| Sprint 1 | 项目初始化、技术选型 | ✅ 完成 |
| Sprint 2 | 认证授权、数据库模型 | ✅ 完成 |
| Sprint 3 | 核心对话框架 | ✅ 完成 |
| Sprint 4 | 智能中枢层 | ✅ 完成 |
| Sprint 5 | 学业辅导智能体 | ✅ 完成 |
| Sprint 6 | 课堂复盘智能体 | ✅ 完成 |
| Sprint 7 | 情感陪伴智能体 | ✅ 完成 |
| Sprint 8 | 健康/创意/生涯智能体 | ✅ 完成 |
| Sprint 9 | 人格交互层 | ✅ 完成 |
| Sprint 10 | 多模态交互 | ✅ 完成 |
| Sprint 11 | 安全合规与管理后台 | ✅ 完成 |
| Sprint 12 | 基础设施与部署 | ✅ 完成 |

## 许可证

本项目为星澜中学内部教育项目，仅供学习和研究使用。
