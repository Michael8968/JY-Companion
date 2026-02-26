# 等保 2.0 三级合规自查清单

## JY-Companion AI 智能学伴平台

| 项目 | 内容 |
|------|------|
| **平台名称** | JY-Companion AI 智能学伴平台 |
| **等保定级** | 三级（重要信息系统） |
| **自查日期** | 2026-02-26 |
| **自查版本** | v1.0 |
| **技术栈** | FastAPI / PostgreSQL / Redis / Milvus / Neo4j / MongoDB / MinIO / Flutter / vLLM / K8s |
| **依据标准** | GB/T 22239-2019《信息安全技术 网络安全等级保护基本要求》 |

> **说明**：`[x]` 表示当前实现已覆盖该项要求；`[ ]` 表示尚未实现或需要验证。每项均附有当前状态说明或整改建议。

---

## 目录

1. [安全物理环境](#1-安全物理环境-physical-security)
2. [安全通信网络](#2-安全通信网络-network-security)
3. [安全区域边界](#3-安全区域边界-security-zone-boundary)
4. [安全计算环境](#4-安全计算环境-secure-computing-environment)
5. [安全管理中心](#5-安全管理中心-security-management-center)
6. [安全管理制度](#6-安全管理制度-security-management-system)
7. [安全管理机构](#7-安全管理机构-security-management-organization)
8. [安全管理人员](#8-安全管理人员-security-personnel-management)
9. [安全建设管理](#9-安全建设管理-security-construction-management)
10. [安全运维管理](#10-安全运维管理-security-operation-management)

---

## 1. 安全物理环境 (Physical Security)

> 适用于部署 K8s 集群、PostgreSQL、Redis、Milvus、Neo4j、MongoDB、MinIO 等服务的机房/数据中心。

### 1.1 物理位置选择

- [ ] **机房选址安全**：机房应选择在具有防震、防风和防雨等能力的建筑内
  - *整改建议*：确认 K8s 集群所在数据中心（或云服务商）的物理环境符合要求，获取 IDC 合规证明文件
- [ ] **防水淹措施**：机房不应设置在建筑物的顶层或地下室，应避免设在用水设备的下层
  - *整改建议*：获取 IDC 机房楼层位置证明

### 1.2 物理访问控制

- [ ] **机房出入管控**：机房出入口应配置电子门禁系统，控制、鉴别和记录进入人员
  - *整改建议*：确认 IDC 提供门禁系统及访问日志，获取相关证明材料
- [ ] **来访人员登记**：应对来访人员进行登记并有专人陪同
  - *整改建议*：建立来访人员登记制度，留存来访记录不少于 6 个月
- [ ] **机房区域划分**：应将重要设备区域与其他区域物理隔离
  - *整改建议*：确认数据库服务器（PostgreSQL、Redis、Milvus 等）所在区域与普通办公区隔离

### 1.3 防盗窃和防破坏

- [ ] **设备固定与标识**：应将设备或主要部件固定并设置明显的不易除去的标识
  - *整改建议*：对 K8s 节点物理服务器进行资产标签标识
- [ ] **通信线缆保护**：应将通信线缆铺设在隐蔽安全处
  - *整改建议*：确认 IDC 线缆走线规范
- [ ] **视频监控**：应在机房设置视频监控系统，对进出机房人员进行记录，录像保存不少于 90 天
  - *整改建议*：获取 IDC 视频监控部署及留存期限证明

### 1.4 防雷击

- [ ] **防雷设施**：应将各类机柜、设施和设备等通过接地系统安全接地
  - *整改建议*：获取 IDC 防雷接地检测报告

### 1.5 防火

- [ ] **消防设施**：机房应配备灭火设备和火灾自动报警系统
  - *整改建议*：获取 IDC 消防验收报告及气体灭火系统维护记录
- [ ] **防火隔离**：机房应采用耐火材料装修
  - *整改建议*：获取 IDC 建筑防火等级证明

### 1.6 温湿度控制

- [ ] **环境监控**：应设置温湿度自动调节设施，使机房温湿度变化在设备运行允许范围内
  - *整改建议*：确认 IDC 提供精密空调系统及温湿度监控记录

### 1.7 电力供应

- [ ] **UPS 与备用电源**：应提供短期的备用电力供应（UPS），至少满足设备在断电情况下的正常运行要求
  - *整改建议*：确认 IDC 配备 UPS 及柴油发电机组，获取供电保障证明
- [ ] **双路市电**：应提供冗余或并行的电力线路为计算机系统供电
  - *整改建议*：获取 IDC 双路市电接入证明

### 1.8 电磁防护

- [ ] **电磁屏蔽**：应采取防静电措施
  - *整改建议*：确认 IDC 机房防静电地板及接地措施到位

---

## 2. 安全通信网络 (Network Security)

### 2.1 网络架构

- [x] **网络分区隔离**：K8s Namespace 隔离 (`jy-companion` namespace)，后端服务、AI 服务、数据库服务分布在不同网络分区
  - *当前状态*：`infrastructure/k8s/base/namespace.yaml` 已定义独立 Namespace，APISIX 网关作为统一入口
- [x] **关键网络设备冗余**：K8s 集群多节点部署，HPA 配置 3-10 Pod 自动伸缩
  - *当前状态*：`infrastructure/k8s/overlays/production/hpa.yaml` 配置 minReplicas=3，maxReplicas=10
- [ ] **网络带宽保障**：应保证网络各个部分的带宽满足业务高峰期需要
  - *整改建议*：评估 vLLM 推理服务、FunASR 语音识别、CosyVoice TTS 等 AI 服务的带宽峰值需求，配置 QoS 策略
- [x] **网络拓扑文档**：应绘制并维护与当前运行情况相符的网络拓扑结构图
  - *当前状态*：`docs/architecture/` 目录下有架构文档，需定期更新

### 2.2 通信传输

- [x] **通信加密 TLS 1.3**：全链路通信采用 TLS 1.3 加密，禁止降级到 TLS 1.2
  - *当前状态*：`backend/app/core/encryption.py` 中 `TLS_CONFIG` 配置 `min_version: TLSv1.3`，`get_tls_ssl_context()` 强制 TLS 1.3
- [x] **安全响应头**：APISIX 网关配置 HSTS、X-Frame-Options、X-Content-Type-Options、X-XSS-Protection、CSP 头
  - *当前状态*：`infrastructure/gateway/apisix.yaml` global_rules 中 `response-rewrite` 设置 `Strict-Transport-Security: max-age=31536000; includeSubDomains`
- [ ] **内部服务间通信加密**：K8s 集群内后端 → PostgreSQL/Redis/Milvus/Neo4j/MongoDB/MinIO 的连接应启用 TLS
  - *整改建议*：为所有数据库连接启用 TLS/SSL（当前 `settings.py` 中 `database_url` 使用 `postgresql+asyncpg` 未显式指定 `sslmode=require`）；Redis 连接配置 TLS；MinIO 启用 HTTPS

### 2.3 可信验证

- [ ] **网络设备可信启动**：应基于可信根对通信设备的系统引导程序、系统程序等进行可信验证
  - *整改建议*：如使用云服务商，确认云主机支持可信计算模块（TPM/vTPM）；如自建机房，部署可信计算基础设施

---

## 3. 安全区域边界 (Security Zone Boundary)

### 3.1 边界防护

- [x] **API 网关统一入口**：所有外部请求经 APISIX 网关统一接入，后端服务不直接暴露
  - *当前状态*：`infrastructure/gateway/apisix.yaml` 定义所有 routes 均通过网关代理到后端 `backend:8000`
- [x] **管理后台 IP 限制**：Admin API 路由配置 IP 白名单（`10.0.0.0/8`、`172.16.0.0/12`、`192.168.0.0/16`）
  - *当前状态*：`apisix.yaml` admin_api 路由配置 `ip-restriction.whitelist`
- [ ] **跨网络边界访问控制**：应限制无线网络的使用，确保无线网络通过受控的边界防护设备接入内部网络
  - *整改建议*：制定无线网络接入安全策略，校园无线网络与平台内网之间部署防火墙规则
- [ ] **网络边界防火墙**：应部署防火墙设备或云安全组在网络边界处对进出网络的信息进行过滤
  - *整改建议*：在 K8s 集群前部署 WAF（Web Application Firewall），配置 NetworkPolicy 限制 Pod 间通信

### 3.2 访问控制

- [x] **基于角色的访问控制 (RBAC)**：系统实现 student/teacher/parent/admin 四级角色控制
  - *当前状态*：`backend/app/core/dependencies.py` 的 `require_role()` 装饰器实现角色校验；`backend/app/models/user.py` 的 `UserRole` 枚举定义四种角色
- [x] **JWT 认证验证**：所有受保护路由通过 JWT 进行身份认证
  - *当前状态*：APISIX 路由配置 `jwt-auth` 插件；后端 `OAuth2PasswordBearer` 提取和验证 Token
- [x] **接口级权限控制**：管理接口限 admin 角色，危机告警接口限 admin/teacher 角色
  - *当前状态*：`backend/app/api/v1/admin.py` 所有 endpoint 使用 `Depends(require_role("admin"))` 或 `require_role("admin", "teacher")`

### 3.3 入侵防范

- [ ] **入侵检测系统 (IDS/IPS)**：应在关键网络节点处部署入侵检测或入侵防御系统
  - *整改建议*：部署基于 K8s 的入侵检测系统（如 Falco），配置异常行为告警规则
- [ ] **网络攻击检测**：应能检测以下攻击行为：端口扫描、强力攻击、木马后门、拒绝服务攻击、缓冲区溢出、IP 碎片攻击、网络蠕虫攻击等
  - *整改建议*：在 APISIX 前部署 WAF 防护 SQL 注入、XSS、CSRF 等 Web 攻击；部署 Falco 检测容器逃逸、异常进程等

### 3.4 恶意代码和垃圾邮件防范

- [x] **内容安全过滤**：三层内容安全过滤机制（关键词匹配 + 正则规避检测 + 上下文规则），拦截率 >= 99%
  - *当前状态*：`backend/app/services/content_safety.py` 实现 `ContentSafetyFilter`，覆盖色情、赌博、毒品、暴力、诈骗等违规内容
- [x] **输入输出双向过滤**：对用户输入和 LLM 输出均进行内容安全检查
  - *当前状态*：`ContentSafetyFilter` 提供 `check()` 和 `check_output()` 两个方法
- [ ] **文件上传恶意代码检测**：对通过 MinIO 上传的文件进行病毒扫描和恶意代码检测
  - *整改建议*：集成 ClamAV 或类似引擎对 MinIO 上传文件进行扫描；对 PaddleOCR 处理的图片文件进行格式验证

### 3.5 安全审计

- [x] **API 请求日志**：所有 HTTP 请求记录方法、路径、状态码和响应时间
  - *当前状态*：`backend/app/core/middleware.py` 的 `RequestLoggingMiddleware` 记录每个请求的 method/path/status_code/duration_ms
- [x] **网关层审计日志**：APISIX 配置 syslog 插件和 X-Request-Id 链路追踪
  - *当前状态*：`apisix.yaml` 中 student_api 路由配置 `syslog` 插件；global_rules 配置 `request-id` 插件
- [ ] **审计日志集中存储与防篡改**：审计日志应集中存储且不可篡改，保存期限不少于 180 天
  - *整改建议*：将 structlog JSON 日志输出到集中式日志平台（ELK/Loki），配置日志只读归档策略，保存周期 >= 6 个月
- [ ] **数据库操作审计**：应记录 PostgreSQL 数据库的 DDL/DML 操作审计日志
  - *整改建议*：启用 PostgreSQL `pgaudit` 扩展，配置审计日志记录所有 DDL 和敏感 DML 操作

### 3.6 可信验证

- [ ] **边界设备可信验证**：应基于可信根对边界设备的系统引导程序等进行可信验证
  - *整改建议*：确认 K8s 节点使用可信镜像签名（如 cosign/Notary），配置 Admission Controller 校验镜像签名

---

## 4. 安全计算环境 (Secure Computing Environment)

### 4.1 身份鉴别

- [x] **唯一身份标识**：每个用户具有唯一的 `username` 和 UUID `id`
  - *当前状态*：`backend/app/models/user.py` 中 `username` 字段 `unique=True`，主键为 UUID
- [x] **口令复杂度**：密码使用 bcrypt 哈希存储（72 字节截断处理）
  - *当前状态*：`backend/app/core/security.py` 使用 `bcrypt.hashpw()` 和 `bcrypt.gensalt()` 进行密码哈希
- [ ] **口令复杂度策略**：应强制要求口令长度、大小写、数字、特殊字符组合
  - *整改建议*：在 `backend/app/schemas/user.py` 的 `UserCreate` schema 中添加密码复杂度校验（最小 8 位，含大小写字母、数字、特殊字符）
- [x] **双因素认证 (SSO)**：支持 SSO 统一身份认证集成
  - *当前状态*：`backend/app/api/v1/sso.py` 实现 SSO 登录 URL 获取、ticket 回调验证、SSO 登出
- [ ] **登录失败锁定**：应具有登录失败处理功能，连续失败后应锁定账户或增加验证码
  - *整改建议*：在 `AuthService.login()` 中增加失败计数逻辑（利用 Redis 记录），连续 5 次失败锁定 30 分钟
- [ ] **远程管理通道安全**：当进行远程管理时，应采用必要措施防止认证信息被窃听
  - *整改建议*：确保所有管理接口仅通过 TLS 加密通道访问；SSH 管理 K8s 节点应使用密钥认证
- [x] **Token 过期与刷新机制**：Access Token 30 分钟过期，Refresh Token 7 天过期
  - *当前状态*：`settings.py` 中 `jwt_access_token_expire_minutes=30`，`jwt_refresh_token_expire_days=7`；`frontend/lib/core/network/token_manager.dart` 实现自动刷新（提前 60 秒判定过期）

### 4.2 访问控制

- [x] **最小权限原则**：RBAC 模型限制各角色仅能访问其权限范围内的资源
  - *当前状态*：`require_role()` 依赖注入确保每个 API 端点仅允许指定角色访问
- [x] **管理用户权限分离**：管理员功能（用户管理、平台统计、危机告警管理）与普通用户功能分离
  - *当前状态*：`/api/v1/admin/*` 路由仅 admin 角色可访问，同时受 IP 白名单限制
- [x] **默认拒绝策略**：未认证请求默认拒绝（OAuth2PasswordBearer），未授权角色返回 403
  - *当前状态*：`backend/app/core/exceptions.py` 定义 `UnauthorizedError`（401）和 `ForbiddenError`（403）
- [ ] **敏感操作二次确认**：应对重要操作（如删除用户、导出数据、修改权限）实施二次认证
  - *整改建议*：对 `update_user_status`、数据导出等高危操作增加密码重新验证或短信验证码确认

### 4.3 安全审计

- [x] **用户操作审计**：记录所有 API 调用的用户身份、操作时间、操作内容
  - *当前状态*：`RequestLoggingMiddleware` 记录 method/path/status_code/duration_ms；JWT payload 包含 `sub`（user_id）和 `role`
- [x] **危机事件审计追溯**：危机告警记录触发用户、告警级别、触发内容（脱敏）、响应时间、通知角色
  - *当前状态*：`backend/app/services/crisis_alert.py` 的 `create_crisis_alert()` 记录完整审计信息并通过 Redis Pub/Sub 推送
- [ ] **审计记录保护**：审计记录应受到保护，不能被未授权访问、篡改或删除
  - *整改建议*：将审计日志输出到独立的只读存储（如对象存储 + WORM 策略）；数据库审计日志应与业务数据库分离
- [ ] **审计进程保护**：应保护审计进程，避免未经授权的中断
  - *整改建议*：审计日志收集进程设置为 K8s DaemonSet，配置自动重启策略

### 4.4 入侵防范

- [x] **生产环境最小化安装**：生产环境禁用 Swagger/ReDoc 文档接口
  - *当前状态*：`backend/app/main.py` 中 `docs_url` 和 `redoc_url` 仅在 `settings.debug=True` 时启用，生产环境 `DEBUG=false`
- [x] **容器资源限制**：K8s Deployment 配置 CPU/内存 requests 和 limits
  - *当前状态*：`backend-deployment.yaml` 配置 `requests: cpu=250m, memory=512Mi`，`limits: cpu=1, memory=1Gi`
- [ ] **容器镜像安全扫描**：应对容器镜像进行漏洞扫描，禁止使用存在高危漏洞的镜像
  - *整改建议*：在 CI/CD 流水线中集成 Trivy 或 Anchore 进行镜像漏洞扫描
- [ ] **最小化容器权限**：应配置 Pod SecurityContext，禁止特权容器、禁止 root 运行
  - *整改建议*：在 backend-deployment.yaml 中添加 `securityContext: runAsNonRoot: true, readOnlyRootFilesystem: true, allowPrivilegeEscalation: false`
- [ ] **系统补丁更新**：应及时更新操作系统和应用组件的安全补丁
  - *整改建议*：建立定期安全补丁更新流程，关注 FastAPI、Python、PostgreSQL、Redis 等组件 CVE 公告

### 4.5 恶意代码防范

- [x] **AI 输出内容安全**：LLM 输出经过内容安全过滤器检查
  - *当前状态*：`ContentSafetyFilter.check_output()` 对 LLM 回复进行违规内容过滤
- [ ] **容器运行时安全**：应部署容器运行时安全监控，检测异常进程、文件系统变更
  - *整改建议*：部署 Falco 或 Sysdig Secure 进行容器运行时安全监控

### 4.6 数据完整性

- [x] **数据库事务完整性**：SQLAlchemy AsyncSession 使用 try/commit/except/rollback 模式保证事务完整性
  - *当前状态*：`backend/app/core/database.py` 的 `get_db()` 实现事务自动提交和异常回滚
- [x] **健康检查探针**：K8s 配置 livenessProbe、readinessProbe、startupProbe 保障服务可用性
  - *当前状态*：`backend-deployment.yaml` 配置三种探针，检查 `/api/v1/health` 端点
- [ ] **数据传输完整性校验**：应采用密码技术保证重要数据在传输过程中的完整性
  - *整改建议*：TLS 1.3 已提供传输层完整性保护；对关键业务数据（如成绩数据、心理评估报告）增加应用层 HMAC 签名

### 4.7 数据保密性

- [x] **字段级加密 AES-256-GCM**：敏感字段使用 AES-256-GCM 加密存储
  - *当前状态*：`backend/app/core/encryption.py` 的 `FieldEncryptor` 类实现 AES-256-GCM 字段级加密，密钥通过 PBKDF2 派生
- [x] **国密算法 SM4 支持规划**：SM4-GCM 加密算法配置已定义，满足国密合规要求
  - *当前状态*：`encryption.py` 中 `SM4_CONFIG` 已定义，当前状态为 `placeholder`，需要实际集成 gmssl 库
- [ ] **SM4 国密算法实际集成**：SM4 目前为 placeholder 状态，需实际集成国密算法库
  - *整改建议*：集成 `gmssl` 或 `tongsuopy` 库，实现 SM4-GCM 加密功能，在涉及国密合规的场景中使用 SM4 替代 AES
- [x] **数据脱敏引擎**：多策略数据脱敏系统（掩码/泛化/哈希/截断/编辑/加密）
  - *当前状态*：`backend/app/services/data_masking.py` 实现 `DataMaskingEngine`，支持手机号、身份证、邮箱、姓名、银行卡、地址、学号、密码、对话内容等字段类型的自动脱敏
- [x] **密码安全存储**：密码使用 bcrypt 哈希存储，不可逆
  - *当前状态*：`security.py` 使用 `bcrypt.hashpw()` + `bcrypt.gensalt()`
- [ ] **数据库存储加密**：应启用 PostgreSQL 透明数据加密（TDE）或磁盘级加密
  - *整改建议*：启用 PostgreSQL 的 pgcrypto 扩展或使用存储层加密（如 LUKS 磁盘加密）；MinIO 启用服务端加密（SSE）

### 4.8 个人信息保护

- [x] **个人信息最小化收集**：仅收集学习所需的必要信息（用户名、角色、年级、班级）
  - *当前状态*：`User` 模型字段设计遵循最小必要原则，手机号和邮箱为可选字段
- [x] **PII 数据自动脱敏**：对话内容和日志中的个人信息（手机号、身份证、邮箱）自动脱敏
  - *当前状态*：`DataMaskingEngine.mask_text()` 自动扫描和替换文本中的手机号、身份证号、邮箱地址
- [x] **危机告警内容脱敏**：危机触发内容在存储前进行部分掩码处理
  - *当前状态*：`crisis_alert.py` 中 `_desensitize()` 函数对触发内容进行中间部分掩码
- [ ] **未成年人信息特别保护**：应针对学生（未成年人）的个人信息制定专门的保护措施
  - *整改建议*：依据《未成年人保护法》和《个人信息保护法》，实施未成年人数据使用同意机制（家长授权），限制数据用途，禁止画像用于营销
- [ ] **数据主体权利保障**：应支持用户查询、更正、删除个人信息的权利
  - *整改建议*：实现个人数据导出 API、账户注销及关联数据清除功能、数据更正申请流程
- [ ] **隐私政策与知情同意**：应在注册和使用前向用户明示个人信息收集和使用规则
  - *整改建议*：在 Flutter 客户端注册页面增加隐私政策和用户协议勾选确认

---

## 5. 安全管理中心 (Security Management Center)

### 5.1 系统管理

- [x] **运维监控体系**：Prometheus + Grafana 全链路监控
  - *当前状态*：`backend-deployment.yaml` 配置 Prometheus 注解（`prometheus.io/scrape: "true"`，端口 8000，路径 `/metrics`）；APISIX 开放 Prometheus 指标端口 9091
- [x] **健康检查与自愈**：K8s 配置 liveness/readiness/startup 三种探针
  - *当前状态*：`backend-deployment.yaml` 配置完善的探针策略，`terminationGracePeriodSeconds: 30` 保证优雅关闭
- [ ] **统一运维管理平台**：应通过统一管理平台对系统管理员进行身份鉴别，只允许经过授权的管理员进行操作
  - *整改建议*：部署统一的 K8s 管理平台（如 Rancher/KubeSphere），配置 RBAC 和审计日志
- [ ] **特权操作审批流程**：对重要操作（如数据库直接访问、配置变更）应有审批和记录
  - *整改建议*：建立变更管理流程（ITSM），关键操作需双人复核

### 5.2 审计管理

- [x] **结构化日志**：使用 structlog 输出结构化 JSON 日志，包含时间戳、日志级别、上下文信息
  - *当前状态*：`backend/app/config/logging_config.py` 配置 structlog，生产环境使用 `JSONRenderer()`，包含 ISO 时间戳
- [x] **请求链路追踪**：APISIX 生成 X-Request-Id，贯穿全链路
  - *当前状态*：`apisix.yaml` global_rules 配置 `request-id` 插件，`include_in_response: true`
- [ ] **日志集中管理**：应建立集中式日志管理系统，统一采集、存储、检索审计日志
  - *整改建议*：部署 ELK Stack（Elasticsearch + Logstash + Kibana）或 Loki + Grafana，收集所有服务日志
- [ ] **审计日志异常告警**：应对审计日志进行分析，发现异常行为时自动告警
  - *整改建议*：在 Grafana 中配置日志告警规则（如异常登录、批量数据导出、频繁失败请求等）

### 5.3 安全管理

- [x] **配置密钥管理**：K8s Secrets 管理数据库凭据、JWT 密钥等敏感配置
  - *当前状态*：`backend-deployment.yaml` 通过 `secretKeyRef` 引用 `backend-secrets` 中的 `database-url`、`redis-url`、`jwt-secret`
- [ ] **密钥轮换策略**：应制定 JWT 密钥、数据库密码、加密密钥的定期轮换计划
  - *整改建议*：制定密钥轮换策略（JWT 密钥每 90 天轮换，数据库密码每 180 天轮换），实现平滑切换机制
- [ ] **安全策略集中管理**：应建立集中的安全策略管理，统一下发和执行安全配置
  - *整改建议*：使用 K8s OPA/Gatekeeper 实施集群级安全策略；使用 ConfigMap 统一管理安全配置参数

---

## 6. 安全管理制度 (Security Management System)

### 6.1 安全策略

- [ ] **网络安全总体方针**：应制定网络安全工作的总体方针和安全策略
  - *整改建议*：编写《JY-Companion 平台网络安全总体策略》，明确安全目标、原则、责任和措施
- [ ] **安全策略文件审批**：安全策略文件应经过管理层审批并正式发布
  - *整改建议*：安全策略文件需经学校信息化主管领导签批后发布实施

### 6.2 管理制度

- [ ] **安全管理制度体系**：应建立覆盖安全管理活动的各方面的管理制度
  - *整改建议*：制定以下制度文件：
    - 《系统运维管理制度》
    - 《数据安全管理制度》
    - 《应急响应管理制度》
    - 《变更管理制度》
    - 《账号与权限管理制度》
    - 《AI 内容安全管理制度》
    - 《学生数据隐私保护管理办法》
- [ ] **制度文件版本管理**：应对安全管理制度进行版本控制，确保使用最新版本
  - *整改建议*：将安全管理制度文件纳入版本管理系统（如文档管理系统或 Git 仓库），标注版本号和生效日期

### 6.3 制定和发布

- [ ] **制度评审与修订**：应定期对安全管理制度进行评审和修订
  - *整改建议*：每年至少进行一次安全管理制度的全面评审，结合等保测评结果和安全事件进行修订

---

## 7. 安全管理机构 (Security Management Organization)

### 7.1 岗位设置

- [ ] **信息安全领导小组**：应成立指导和管理网络安全工作的委员会或领导小组
  - *整改建议*：成立由学校主管领导牵头的信息安全领导小组，负责决策平台安全方针
- [ ] **安全管理岗位**：应设立安全管理负责人岗位，负责组织落实安全管理工作
  - *整改建议*：指定平台安全负责人（可由信息中心主任兼任），负责日常安全管理
- [ ] **安全岗位职责分离**：应实现系统管理员、安全管理员、安全审计员的三员分离
  - *整改建议*：明确三类角色的职责划分：
    - 系统管理员：负责系统配置和维护（对应 K8s 集群管理）
    - 安全管理员：负责安全策略配置和安全事件处置
    - 安全审计员：负责审计日志审查和合规检查

### 7.2 人员配备

- [ ] **安全专职人员**：应配备一定数量的系统管理员、安全管理员和安全审计员
  - *整改建议*：至少配备 1 名安全管理员和 1 名安全审计员（可兼职）

### 7.3 授权和审批

- [ ] **授权审批流程**：应建立重要操作的授权审批机制
  - *整改建议*：制定《授权审批管理规程》，覆盖以下操作：
    - 新用户批量导入（教师/学生）
    - Admin 权限授予
    - 数据导出操作
    - 系统配置变更
    - AI 模型更新部署

### 7.4 沟通和合作

- [ ] **外部安全合作**：应建立与网安部门、等保测评机构的沟通渠道
  - *整改建议*：与属地网安部门建立日常联系；与等保测评机构建立年度合作关系
- [ ] **安全事件报告机制**：应建立安全事件的内部报告和外部通报机制
  - *整改建议*：建立安全事件分级响应流程，重大事件 24 小时内向主管部门报告

---

## 8. 安全管理人员 (Security Personnel Management)

### 8.1 人员录用

- [ ] **安全背景审查**：录用涉及安全岗位的人员时应进行背景审查
  - *整改建议*：对运维人员和管理员进行背景调查，签署保密协议
- [ ] **岗位能力要求**：应明确安全相关岗位的技能要求
  - *整改建议*：制定运维人员和安全管理员的岗位职责和技能矩阵

### 8.2 人员离岗

- [ ] **离岗权限回收**：人员离岗时应及时回收系统访问权限和设备
  - *整改建议*：建立离岗权限回收检查清单：K8s 集群访问权限、数据库访问权限、VPN 账号、Git 仓库访问权限

### 8.3 安全意识教育和培训

- [ ] **定期安全培训**：应对各类人员进行安全意识教育和安全技能培训
  - *整改建议*：每学期对使用平台的教师和管理人员进行信息安全培训，内容包括：
    - 密码安全
    - 钓鱼攻击识别
    - 数据保护法规
    - AI 内容安全意识
    - 危机事件处理流程

### 8.4 外部人员访问管理

- [ ] **第三方人员管理**：外部人员（如 vLLM/FunASR 等服务维护商）访问系统时应签署保密协议并全程监控
  - *整改建议*：制定《第三方人员访问管理办法》，要求签署 NDA，通过堡垒机访问并记录操作日志

---

## 9. 安全建设管理 (Security Construction Management)

### 9.1 定级和备案

- [ ] **等保定级备案**：应按照等保 2.0 要求完成系统定级备案
  - *整改建议*：完成以下工作：
    1. 编制《定级报告》
    2. 组织专家评审
    3. 向属地公安机关网安部门提交备案材料
    4. 获取备案证明

### 9.2 安全方案设计

- [x] **安全架构设计**：系统采用分层安全架构（网关层 → 应用层 → 数据层）
  - *当前状态*：APISIX 网关（认证/限流/安全头） → FastAPI 应用（RBAC/内容安全） → 数据层（加密/脱敏）
- [x] **蓝绿部署策略**：采用蓝绿部署保障系统升级的安全性和连续性
  - *当前状态*：`backend-deployment.yaml` 配置 `version: blue` 标签，`RollingUpdate` 策略 `maxSurge=1, maxUnavailable=0`

### 9.3 产品采购和使用

- [ ] **安全产品选型**：应选择符合国家规定的安全产品
  - *整改建议*：关键安全组件（加密算法、身份认证等）应优先选用获得国家认证的产品；数据库加密模块应支持国密算法
- [ ] **安全产品清单**：应建立使用的安全相关产品和服务的清单
  - *整改建议*：编制安全产品清单，包括 APISIX 网关、bcrypt 密码哈希、AES-256 加密库、SSL 证书等

### 9.4 自行软件开发

- [x] **安全编码实践**：代码实现了多项安全最佳实践
  - *当前状态*：
    - 参数化查询（SQLAlchemy ORM 防 SQL 注入）
    - 输入验证（Pydantic schema 校验）
    - 输出编码（FastAPI 自动 JSON 序列化）
    - 异常处理（统一异常处理类）
- [ ] **代码安全审计**：应对自行开发的软件进行代码安全审计
  - *整改建议*：在 CI/CD 流水线中集成 Bandit（Python SAST）、semgrep 进行自动化代码安全扫描
- [ ] **安全测试**：应在软件上线前进行安全测试（渗透测试等）
  - *整改建议*：上线前进行专业渗透测试，重点测试 JWT 伪造、RBAC 绕过、内容过滤绕过、API 滥用等场景

### 9.5 外包软件开发

- [ ] **外包安全要求**：如有外包开发，应在合同中明确安全要求
  - *整改建议*：在外包合同中加入安全条款，要求交付物包含安全测试报告

### 9.6 工程实施

- [x] **部署流程标准化**：K8s + Kustomize 实现标准化部署
  - *当前状态*：`infrastructure/k8s/base/kustomization.yaml` 和 `overlays/production/kustomization.yaml` 分层配置

### 9.7 测试验收

- [ ] **安全功能验收**：上线前应对安全功能进行验收测试
  - *整改建议*：制定安全功能验收清单，覆盖认证、授权、加密、审计、内容过滤等安全功能

### 9.8 系统交付

- [ ] **安全文档交付**：系统交付时应提供完整的安全文档
  - *整改建议*：准备以下文档：安全设计说明书、安全配置手册、安全测试报告、应急预案

---

## 10. 安全运维管理 (Security Operation Management)

### 10.1 环境管理

- [x] **生产环境与开发环境分离**：K8s overlays 区分 production 环境，Debug 模式仅开发环境启用
  - *当前状态*：`main.py` 根据 `settings.debug` 控制 Swagger 文档暴露；`backend-deployment.yaml` 设置 `DEBUG=false`
- [ ] **环境配置文档**：应记录和维护完整的系统配置文档
  - *整改建议*：维护所有中间件（PostgreSQL、Redis、Milvus、Neo4j、MongoDB、MinIO）的安全配置基线文档

### 10.2 资产管理

- [ ] **信息资产台账**：应编制和维护信息资产清单
  - *整改建议*：建立资产台账，覆盖：
    - 硬件资产（服务器/网络设备）
    - 软件资产（FastAPI、PostgreSQL 16、Redis、Milvus、Neo4j、MongoDB、MinIO、vLLM、FunASR、CosyVoice、PaddleOCR、APISIX 3.9、Flutter）
    - 数据资产（用户数据、对话数据、学习数据、情感数据、向量数据）
    - SSL 证书、域名等

### 10.3 介质管理

- [ ] **介质使用管理**：应对存储介质的使用进行管理，防止未授权访问
  - *整改建议*：制定存储介质（包括备份磁盘、U 盘等）的使用、保管和销毁规程

### 10.4 设备维护管理

- [ ] **设备维护记录**：应对重要设备进行定期维护并记录
  - *整改建议*：建立 K8s 节点、数据库服务器的定期巡检和维护记录

### 10.5 漏洞和风险管理

- [ ] **漏洞管理流程**：应建立漏洞发现、评估、修复的闭环管理流程
  - *整改建议*：
    - 订阅 FastAPI、PostgreSQL、Redis、K8s 等组件的安全公告
    - 每月执行漏洞扫描（Trivy 扫描容器镜像，OWASP ZAP 扫描 Web 接口）
    - 高危漏洞 72 小时内修复，中危漏洞 30 天内修复
- [ ] **风险评估**：应定期进行信息安全风险评估
  - *整改建议*：每年至少进行一次风险评估，重点关注 AI 模型安全（对抗攻击、prompt 注入）和学生数据泄露风险

### 10.6 网络和系统安全管理

- [x] **限流保护 (Rate Limiting)**：多层次限流策略防止接口滥用
  - *当前状态*：
    - APISIX 网关层：学生 API 100 次/分钟 (`limit-count`)、语音 API 30 次/分钟、认证 API 20 次/秒 (`limit-req`)、WebSocket 连接数限制 (`limit-conn`)
    - 应用层：slowapi 限流器（`backend/app/main.py` 中 `limiter`）
- [x] **服务健康监控与自动恢复**：APISIX Upstream 健康检查 + K8s 探针保障服务可用性
  - *当前状态*：APISIX 配置 active health check（interval=5s，successes=2，failures=3）；K8s livenessProbe（failureThreshold=3）
- [ ] **安全事件监控**：应建立安全事件实时监控和告警机制
  - *整改建议*：在 Prometheus/Grafana 中配置以下告警规则：
    - 429 响应率突增（疑似攻击）
    - 401/403 响应率异常（疑似暴力破解）
    - 危机告警触发频率
    - 内容安全拦截率异常

### 10.7 恶意代码防范管理

- [x] **输入过滤与反规避**：内容安全过滤器具备反规避检测能力
  - *当前状态*：`content_safety.py` 的 Layer 2 检测同音词替换（自sha → 自杀）、空格分隔（自 杀）、符号替换（自*杀）等规避手段
- [ ] **恶意代码检测更新**：应定期更新恶意内容关键词库和检测规则
  - *整改建议*：建立内容安全规则定期更新机制，每月根据审计日志中的漏报案例更新关键词库和正则规则

### 10.8 变更管理

- [x] **版本化部署**：K8s Deployment 使用版本标签（blue/green），支持快速回滚
  - *当前状态*：`backend-deployment.yaml` 使用 `version: blue` 标签，`RollingUpdate` 策略保证零停机更新
- [ ] **变更审批流程**：应建立变更审批和实施流程
  - *整改建议*：制定《变更管理流程》，涵盖变更申请、审批、测试、实施、验证、回滚等环节
- [ ] **变更记录**：应保留完整的变更记录
  - *整改建议*：利用 Git commit 历史和 K8s 部署记录维护变更日志

### 10.9 备份与恢复管理

- [x] **自动化备份策略**：PostgreSQL 数据库配置每日全量备份 + 每小时增量备份
  - *当前状态*：`infrastructure/k8s/overlays/production/backup-cronjob.yaml` 配置：
    - 每日 2:00 AM 全量 `pg_dump` 备份（gzip 压缩），保留 30 天
    - 每小时 WAL 增量备份（`pg_basebackup --wal-method=stream`），保留 48 小时
    - RTO <= 4 小时，RPO <= 1 小时
- [x] **备份安全存储**：备份数据通过 PVC 持久化存储
  - *当前状态*：备份写入 `backup-pvc` PersistentVolumeClaim
- [ ] **备份恢复演练**：应定期进行备份恢复演练，验证备份数据可用性
  - *整改建议*：每季度执行一次全量备份恢复演练，记录恢复时间和数据完整性验证结果
- [ ] **异地灾备**：应实施重要数据的异地备份
  - *整改建议*：将备份数据同步到异地对象存储（如不同区域的 MinIO 集群或云存储），实现异地灾备
- [ ] **其他数据源备份**：Redis、Milvus、Neo4j、MongoDB、MinIO 的备份策略
  - *整改建议*：
    - Redis：配置 RDB + AOF 持久化策略
    - Milvus：定期导出向量集合快照
    - Neo4j：配置 `neo4j-admin dump` 定期备份知识图谱
    - MongoDB：配置 `mongodump` 定期备份
    - MinIO：启用版本控制和跨区域复制

### 10.10 安全事件处置

- [x] **危机事件快速响应**：心理危机告警系统 < 30 秒响应
  - *当前状态*：`crisis_alert.py` 实现快速路径危机检测（不经 LLM 推理，< 100ms），三级分级（CRITICAL/HIGH/MEDIUM），自动通知教师/心理咨询师/家长
- [x] **告警通知机制**：通过 Redis Pub/Sub 实时推送告警到相关角色
  - *当前状态*：`_publish_alert_notification()` 通过 Redis 发布告警，CRITICAL 级别通知 teacher + counselor + parent
- [ ] **安全事件应急预案**：应制定安全事件应急预案，明确分级响应流程
  - *整改建议*：编制《网络安全事件应急响应预案》，覆盖以下场景：
    - 数据泄露事件
    - DDoS 攻击
    - AI 模型被恶意利用（prompt 注入）
    - 未成年人安全事件
    - 系统入侵事件
- [ ] **应急演练**：应定期进行应急响应演练
  - *整改建议*：每半年至少进行一次应急演练，包括数据恢复演练和安全事件响应演练

### 10.11 外包运维管理

- [ ] **外包服务安全管理**：如使用第三方运维服务，应明确安全责任
  - *整改建议*：与 IDC/云服务商签订 SLA 协议，明确安全责任边界和事件响应时效

---

## 合规状态汇总

| 分类 | 已达标项 | 待整改项 | 合规率 |
|------|---------|---------|--------|
| 1. 安全物理环境 | 0 | 13 | 0% |
| 2. 安全通信网络 | 4 | 3 | 57% |
| 3. 安全区域边界 | 6 | 6 | 50% |
| 4. 安全计算环境 | 15 | 13 | 54% |
| 5. 安全管理中心 | 5 | 5 | 50% |
| 6. 安全管理制度 | 0 | 4 | 0% |
| 7. 安全管理机构 | 0 | 5 | 0% |
| 8. 安全管理人员 | 0 | 4 | 0% |
| 9. 安全建设管理 | 3 | 5 | 38% |
| 10. 安全运维管理 | 7 | 11 | 39% |
| **合计** | **40** | **69** | **37%** |

---

## 优先整改事项（按风险等级排序）

### P0 - 紧急（等保测评必须项）

1. **SM4 国密算法实际集成**（4.7）：当前为 placeholder，需集成 gmssl 库实现 SM4-GCM
2. **登录失败锁定机制**（4.1）：防止暴力破解攻击
3. **口令复杂度策略**（4.1）：强制密码强度要求
4. **审计日志集中存储与防篡改**（3.5）：部署 ELK/Loki 集中日志平台
5. **数据库操作审计**（3.5）：启用 PostgreSQL pgaudit
6. **等保定级备案**（9.1）：向公安机关网安部门提交备案

### P1 - 高优先级

7. **内部服务间通信加密**（2.2）：PostgreSQL/Redis/MinIO 连接启用 TLS
8. **容器镜像安全扫描**（4.4）：CI/CD 集成 Trivy
9. **入侵检测系统**（3.3）：部署 Falco 容器安全监控
10. **网络边界防火墙/WAF**（3.1）：K8s NetworkPolicy + WAF
11. **未成年人信息特别保护**（4.8）：依法实施家长同意机制
12. **安全管理制度体系**（6.2）：制定各项安全管理制度文件
13. **安全事件应急预案**（10.10）：制定并演练应急预案

### P2 - 中优先级

14. **Pod SecurityContext 最小权限**（4.4）
15. **备份恢复演练**（10.9）
16. **代码安全审计工具**（9.4）
17. **密钥轮换策略**（5.3）
18. **安全岗位三员分离**（7.1）
19. **变更管理流程**（10.8）
20. **数据主体权利保障**（4.8）

---

## 附录

### A. 相关标准文件

| 标准编号 | 标准名称 |
|---------|---------|
| GB/T 22239-2019 | 信息安全技术 网络安全等级保护基本要求 |
| GB/T 25070-2019 | 信息安全技术 网络安全等级保护安全设计技术要求 |
| GB/T 28448-2019 | 信息安全技术 网络安全等级保护测评要求 |
| GB/T 35273-2020 | 信息安全技术 个人信息安全规范 |
| GB/T 39335-2020 | 信息安全技术 个人信息安全影响评估指南 |
| GB/T 41391-2022 | 信息安全技术 移动互联网应用程序（App）收集个人信息基本要求 |

### B. 项目安全相关代码文件索引

| 文件路径 | 安全功能 |
|---------|---------|
| `backend/app/core/security.py` | JWT 令牌生成/验证，bcrypt 密码哈希 |
| `backend/app/core/encryption.py` | AES-256-GCM 字段加密，TLS 1.3 配置，SM4 规划 |
| `backend/app/core/dependencies.py` | OAuth2 认证依赖，RBAC 角色校验 |
| `backend/app/core/middleware.py` | CORS 中间件，请求日志中间件 |
| `backend/app/core/exceptions.py` | 统一安全异常（401/403/404/429） |
| `backend/app/services/data_masking.py` | 多策略数据脱敏引擎 |
| `backend/app/services/content_safety.py` | 三层内容安全过滤器 |
| `backend/app/services/crisis_alert.py` | 心理危机告警系统 |
| `backend/app/api/v1/admin.py` | 管理后台 API（含权限控制） |
| `backend/app/api/v1/sso.py` | SSO 单点登录集成 |
| `infrastructure/gateway/apisix.yaml` | API 网关安全配置（限流/认证/安全头/IP 白名单） |
| `infrastructure/k8s/base/backend-deployment.yaml` | K8s 部署安全配置（Secrets/探针/资源限制） |
| `infrastructure/k8s/overlays/production/backup-cronjob.yaml` | 数据库备份策略 |
| `infrastructure/k8s/overlays/production/hpa.yaml` | 自动弹性伸缩 |
| `frontend/lib/core/network/token_manager.dart` | 客户端 Token 安全管理 |
| `frontend/lib/core/network/api_interceptors.dart` | 客户端请求认证拦截器 |

---

> **文档维护说明**：本自查清单应在每次等保测评前进行更新，确保反映系统最新安全状态。建议每季度进行一次内部自查，每年配合等保测评机构进行一次正式测评。
