## Phase 1: 基础建设 (第1-2月)

### 1. Sprint 1 — 项目初始化与基础架构 (第1-2周)

- [x] 1.1 创建 Monorepo 目录结构、`.gitignore`、`Makefile`、`.editorconfig`
- [ ] 1.2 Flutter 项目初始化 (`flutter create`)，配置 BLoC / go_router / dio / get_it
- [x] 1.3 FastAPI 项目初始化，创建 `pyproject.toml`(uv)、目录结构、`main.py`
- [x] 1.4 编写 `docker-compose.yml` (PostgreSQL + Redis + Milvus + Neo4j + MinIO)
- [x] 1.5 配置 GitHub Actions CI Pipeline (backend lint+test, frontend lint+test+build)
- [ ] 1.6 UI 设计系统：色彩规范、字体规范、基础组件库（Figma）
- [x] 1.7 数据库 Schema 初版 ER 设计文档
- [ ] 1.8 AI 服务 GPU 环境搭建与配置

#### Milestone: Flutter 空壳可运行 + FastAPI health check + Docker 一键启动

### 2. Sprint 2 — 认证系统与核心数据模型 (第3-4周)

- [x] 2.1 实现 User / Role / Session 数据库模型 + Alembic 迁移脚本
- [x] 2.2 实现 OAuth2 + JWT 认证 API (`POST /api/v1/auth/login`, `/register`, `/refresh`)
- [x] 2.3 实现 RBAC 权限中间件（student / teacher / parent / admin 四角色）
- [x] 2.4 实现 API 限流中间件（slowapi: 100/min学生, 500/min教师）
- [ ] 2.5 Flutter 登录/注册 UI + Auth BLoC 状态管理
- [ ] 2.6 Flutter 网络层封装（dio 拦截器、JWT 自动刷新、错误处理）
- [x] 2.7 实现 Conversation / Message 数据库模型
- [ ] 2.8 InnoSpark 1.0 模型加载测试、推理基准性能报告
- [ ] 2.9 教育语料收集与整理（高中各学科）

#### Milestone: 用户可在 App 注册登录，JWT Token 正常流转

### 3. Sprint 3 — 核心对话框架与 LLM 接入 (第5-6周)

- [x] 3.1 实现 WebSocket 实时对话接口 `WS /api/v1/chat/ws`
- [x] 3.2 实现 ChatService：上下文管理、历史消息加载、流式输出
- [x] 3.3 部署 vLLM 推理服务，封装 LLM API 调用层
- [x] 3.4 设计基础 Prompt 模板框架（System Prompt + 人设注入占位）
- [ ] 3.5 Flutter 对话 UI：聊天气泡、流式文本渲染(StreamBuilder)、消息列表
- [ ] 3.6 Flutter WebSocket 客户端 + 消息 BLoC 状态管理
- [x] 3.7 实现内容安全过滤基础版（关键词库 + 基础分类器）
- [x] 3.8 搭建 pytest 测试框架（conftest.py、fixtures、test DB）

#### Milestone: 用户可在 App 与 LLM 流式对话，内容安全过滤生效

### 4. Sprint 4 — 智能中枢层 + RAG 基础 (第7-8周)

- [ ] 4.1 实现意图识别分类器 `hub/intent_classifier.py`（NLU 服务）
- [ ] 4.2 实现智能体能力注册表 `hub/agent_registry.py` + 路由分发逻辑
- [ ] 4.3 实现 DAG 任务编排器基础版 `hub/orchestrator.py`
- [ ] 4.4 部署向量嵌入服务（BGE-large-zh），集成 Milvus SDK
- [ ] 4.5 实现 RAG 管线：文档分块 → 向量嵌入 → Milvus 检索 → 重排序
- [ ] 4.6 导入高中核心学科知识库到 Milvus（数学、物理、化学）
- [ ] 4.7 构建 Neo4j 知识图谱基础 Schema，导入学科知识点实体关系
- [ ] 4.8 重构对话接口：意图识别 → 路由 → 智能体 → RAG 增强 → 流式返回

#### Phase 1 Milestone: 端到端完整链路 — 用户输入→意图识别→路由→LLM+RAG→流式返回

---

## Phase 2: 核心智能体上线 (第2-4月)

### 5. Sprint 5 — 学业辅导智能体 (第9-10周)

- [ ] 5.1 实现 `agents/academic_agent.py` 多学科答疑引擎
- [ ] 5.2 设计 CoT 解题路径 Prompt 模板 `prompt_templates/academic.py`
- [ ] 5.3 实现错因诊断分析逻辑 `services/academic_service.py`
- [ ] 5.4 实现举一反三练习推荐（动态题库筛选 + 难度自适应）
- [ ] 5.5 部署 PaddleOCR 服务 `ai_services/multimodal/ocr_service.py`
- [ ] 5.6 Flutter 学业辅导页面：题目输入(文本+拍照OCR)、分步解答、错题本
- [ ] 5.7 实现 LearningRecord / ErrorRecord 数据模型 + CRUD API
- [ ] 5.8 扩充知识库（语文、英语学科）
- [ ] 5.9 学业辅导模块单元测试 + 集成测试（覆盖率 ≥80%）

### 6. Sprint 6 — 课堂复盘智能体 + ASR (第11-12周)

- [ ] 6.1 部署 FunASR (Paraformer-large) 语音识别服务
- [ ] 6.2 实现 `agents/classroom_agent.py` 课堂录音转写 + 结构化摘要
- [ ] 6.3 实现个性化学案生成逻辑（用户画像 + 知识图谱匹配）
- [ ] 6.4 实现疑问点自动识别算法（语速分析 + 重复讲解检测）
- [ ] 6.5 Flutter 课堂复盘页面：录音上传、摘要展示（大纲/图表双视图）、学案查看
- [ ] 6.6 实现用户画像数据模型 + 动态更新服务
- [ ] 6.7 集成 MinIO 对象存储（音频/文档上传下载）
- [ ] 6.8 500 并发性能压测（Locust/k6）

#### Milestone: 学业辅导 + 课堂复盘两大核心智能体端到端可用

### 7. Sprint 7 — 情感陪伴智能体 + 危机预警 [SAFETY-CRITICAL] (第13-14周)

- [ ] 7.1 实现 `agents/emotional_agent.py` 共情对话生成（心理学微调 Prompt）
- [ ] 7.2 实现多模态情绪识别融合 `ai_services/multimodal/emotion_detector.py`
- [ ] 7.3 **[CRITICAL] 实现危机预警系统：高风险关键词库 + 阈值监测 + 前置同步检查**
- [ ] 7.4 **[CRITICAL] 实现危机告警即时推送（Redis Pub/Sub → 教师/家长/心理专员）**
- [ ] 7.5 构建积极心理学干预策略库（≥50 条标准化策略）
- [ ] 7.6 Flutter 情感陪伴页面：情绪日记、呼吸练习引导、放松动画、情绪趋势图
- [ ] 7.7 实现 EmotionRecord / CrisisAlert 数据模型 + API
- [ ] 7.8 **[CRITICAL] 危机预警端到端测试：验证 ≤30s 响应、100% 召回率**

### 8. Sprint 8 — 健康守护 + 创意创作 + 生涯规划 (第15-16周)

- [ ] 8.1 实现 `agents/health_agent.py` 久坐/用眼监测 + 40分钟强制提醒
- [ ] 8.2 实现健康提醒推送（Celery 定时任务 + 推送通知）
- [ ] 8.3 实现 `agents/creative_agent.py` AIGC 文本 + 图像生成
- [ ] 8.4 实现 `agents/career_agent.py` SMART 目标管理 + 学习路径推荐
- [ ] 8.5 Flutter 健康守护页面：屏幕时间统计、运动计划、提醒配置
- [ ] 8.6 Flutter 创意创作页面：创意生成、作品评价、作品库
- [ ] 8.7 Flutter 生涯规划页面：目标管理、甘特图、进度报告
- [ ] 8.8 部署 CosyVoice TTS 语音合成服务
- [ ] 8.9 六大智能体全集成测试

#### Phase 2 Milestone: 六大智能体全部可用，智能中枢完整链路打通，危机预警验证通过

---

## Phase 3: 人格交互层 (第4-5月)

### 9. Sprint 9 — 人格化对话系统 + 数字形象 (第17-18周)

- [ ] 9.1 实现人设配置系统 `persona/persona_manager.py`（≥20 维度参数管理）
- [ ] 9.2 实现风格化文本生成控制 `persona/style_controller.py`（人设参数实时注入 Prompt）
- [ ] 9.3 实现人设记忆图谱 `persona/memory_graph.py`（跨会话一致性维护）
- [ ] 9.4 实现学伴社区群管理 API（多角色绑定/切换，≥5 个学伴）
- [ ] 9.5 设计 2-3 个预设学伴数字形象（Rive 动画资源）
- [ ] 9.6 Flutter 数字形象渲染器 `features/avatar/avatar_renderer.dart`（Rive 集成）
- [ ] 9.7 实现情感-动画映射驱动 `features/avatar/emotion_animator.dart`
- [ ] 9.8 人格一致性测试：跨 10 轮对话一致率 ≥90%

### 10. Sprint 10 — 多模态交互完善 + 情感表达 (第19-20周)

- [ ] 10.1 实现语音对话完整链路：录音 → ASR → LLM → TTS → 播放
- [ ] 10.2 实现口型同步（TTS 音频 → Rive 面部动画驱动，误差 ≤100ms）
- [ ] 10.3 构建情感表达映射规则库（≥100 条情感→语音/动画映射）
- [ ] 10.4 实现情感状态平滑过渡（状态机 + 插值算法，流畅度 ≥90%）
- [ ] 10.5 前端动画性能优化（移动端渲染帧率 ≥30fps）
- [ ] 10.6 优化多通道情感融合算法（融合准确率 > 单模态 +8%）
- [ ] 10.7 全平台 UI 适配测试（iOS/Android/Desktop 一致性 ≥95%）
- [ ] 10.8 对接 SSO 学校统一身份认证 `integrations/sso_provider.py`

#### Phase 3 Milestone: 数字形象实时渲染+情感驱动，语音交互闭环，人格化跨会话一致

---

## Phase 4: 安全优化 (第5月)

### 11. Sprint 11 — 性能优化 + 安全合规 + 管理后台 (第21-22周)

- [ ] 11.1 部署 APISIX API 网关（限流/认证/路由统一管理）
- [ ] 11.2 性能压测与优化：500 并发 / 5000 QPS 达标验证
- [ ] 11.3 P95 响应时间优化至 ≤3s（缓存策略 + 模型量化 + 批处理）
- [ ] 11.4 实施 TLS 1.3 + AES-256/SM4 全链路加密
- [ ] 11.5 实现数据脱敏规则引擎（掩码/泛化/哈希多策略）
- [ ] 11.6 实现管理后台 API（用户管理、数据统计、内容审核、预警处理）
- [ ] 11.7 实现管理后台前端界面
- [ ] 11.8 升级内容安全分类器（违规拦截率 ≥99%）
- [ ] 11.9 等保 2.0 三级自检清单核对
- [ ] 11.10 全量安全渗透测试（OWASP Top 10）

---

## Phase 5: 部署上线 (第5-6月)

### 12. Sprint 12 — 生产部署 + UAT + 上线 (第23-24周)

- [ ] 12.1 K8s 生产环境部署（蓝绿部署策略）
- [ ] 12.2 完善 Prometheus + Grafana 监控大屏
- [ ] 12.3 实施灾备方案（双活 + 每日全量备份 + 实时增量备份，RTO≤4h RPO≤1h）
- [ ] 12.4 对接学校教务系统数据 `integrations/school_system.py`
- [ ] 12.5 UAT 用户验收测试（学生/教师/家长三方参与）
- [ ] 12.6 iOS App Store + Android 应用商店 / MDM 分发包准备
- [ ] 12.7 编写用户手册与培训材料
- [ ] 12.8 Bug 修复 + 最终性能优化
- [ ] 12.9 产品说明书验收标准逐项核对

#### Final Milestone: 全部验收标准达标，生产环境稳定运行，App 上架/分发

---

## Verify

- [ ] V.1 所有 spec 中的 WHEN/THEN/AND 场景有对应的自动化测试覆盖
- [ ] V.2 后端单元测试覆盖率 ≥80%，前端核心模块测试覆盖率 ≥80%
- [ ] V.3 性能指标达标：500 并发 / 5000 QPS / P95 ≤3s
- [ ] V.4 安全指标达标：内容拦截率 ≥99% / 危机预警 ≤30s / TLS 1.3 全链路
- [ ] V.5 用户满意度调查：学生 ≥85%、教师 ≥80%、家长 ≥75%
- [ ] V.6 等保 2.0 三级合规自检通过
- [ ] V.7 跨平台一致性 ≥95%、移动端崩溃率 ≤0.1%
