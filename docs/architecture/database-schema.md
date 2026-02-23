# 数据库 Schema 设计 V1.0

## 概述

平台采用多引擎数据库策略：
- **PostgreSQL 16+** — 核心业务数据（用户、会话、学习记录、预警、审计）
- **Milvus 2.4+** — 向量检索（知识库嵌入、会话语义检索）
- **Neo4j 5.x** — 知识图谱（学科→知识点→练习题关系）
- **Redis 7.4+** — 缓存、消息队列、限流计数器
- **MongoDB 7.0+** — 非结构化数据（课堂笔记、创作内容）
- **MinIO** — 对象存储（音频、图片、视频、头像资源）

---

## PostgreSQL ER 模型

### 实体关系总览

```
users ──1:1── user_profiles
  │
  ├──1:N── conversations ──1:N── messages
  │                                  │
  │                          message_vectors (→ Milvus)
  │
  ├──1:N── learning_records ──1:1── error_records
  │
  ├──1:N── emotion_records
  │
  ├──1:N── crisis_alerts [SAFETY-CRITICAL]
  │
  ├──1:N── health_records
  │
  ├──M:N── personas (via user_personas)
  │
  ├──1:N── goals (self-referencing hierarchy)
  │
  └──1:N── audit_logs

classroom_sessions ──1:N── study_plans
```

### 核心表定义

#### users — 用户表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| username | VARCHAR(50) UNIQUE | 用户名 |
| email | VARCHAR(255) | 邮箱 |
| phone | VARCHAR(20) | 手机号 |
| password_hash | VARCHAR(255) | 密码哈希 |
| role | ENUM(student,teacher,parent,admin) | 角色 |
| display_name | VARCHAR(100) | 显示名 |
| avatar_url | VARCHAR(500) | 头像 URL |
| grade | VARCHAR(20) | 年级 |
| class_name | VARCHAR(50) | 班级 |
| student_id | VARCHAR(50) | 学号 |
| parent_of | UUID FK→users | 家长关联学生 |
| sso_provider | VARCHAR(50) | SSO 提供方 |
| sso_external_id | VARCHAR(255) | SSO 外部 ID |
| status | VARCHAR(20) | active/disabled |
| last_login_at | TIMESTAMPTZ | 最后登录 |
| created_at | TIMESTAMPTZ | 创建时间 |
| updated_at | TIMESTAMPTZ | 更新时间 |

#### user_profiles — 用户画像表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 用户 |
| learning_style | JSONB | 学习风格标签 |
| ability_scores | JSONB | 各科能力评分 |
| interest_tags | JSONB | 兴趣标签 |
| emotion_baseline | JSONB | 情绪基线 |
| health_profile | JSONB | 健康数据 |
| updated_at | TIMESTAMPTZ | 更新时间 |

#### conversations — 会话表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 用户 |
| agent_type | VARCHAR(30) | academic/classroom/emotional/health/creative/career |
| persona_id | UUID FK→personas | 关联人设 |
| title | VARCHAR(200) | 会话标题 |
| status | VARCHAR(20) | active/archived |
| context_snapshot | JSONB | 情景快照 |
| message_count | INTEGER | 消息数 |
| last_message_at | TIMESTAMPTZ | 最后消息时间 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### messages — 消息表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| conversation_id | UUID FK→conversations | 会话 |
| role | ENUM(user,assistant,system) | 角色 |
| content_type | VARCHAR(20) | text/image/audio/file |
| content | TEXT | 内容 |
| metadata | JSONB | 附加信息 |
| token_count | INTEGER | Token 用量 |
| intent_label | VARCHAR(50) | 意图标签 |
| intent_confidence | FLOAT | 意图置信度 |
| emotion_label | VARCHAR(30) | 情绪标签 |
| emotion_score | FLOAT | 情绪分数 |
| is_flagged | BOOLEAN | 安全标记 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### learning_records — 学习记录表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 用户 |
| subject | VARCHAR(30) | 学科 |
| topic | VARCHAR(200) | 知识点 |
| question_text | TEXT | 题目文本 |
| question_image | VARCHAR(500) | 题目图片 URL |
| answer_text | TEXT | 解答 |
| is_correct | BOOLEAN | 是否正确 |
| error_type | VARCHAR(50) | 错误类型 |
| difficulty | FLOAT | 难度 0-1 |
| time_spent_sec | INTEGER | 耗时(秒) |
| knowledge_points | JSONB | 关联知识点 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### error_records — 错题本
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 用户 |
| learning_record_id | UUID FK→learning_records | 学习记录 |
| subject | VARCHAR(30) | 学科 |
| error_analysis | TEXT | AI 错因分析 |
| knowledge_gaps | JSONB | 薄弱知识点 |
| recommended_exercises | JSONB | 推荐练习 |
| mastery_status | ENUM(weak,improving,mastered) | 掌握状态 |
| review_count | INTEGER | 复习次数 |
| last_reviewed_at | TIMESTAMPTZ | 最后复习 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### classroom_sessions — 课堂记录表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| teacher_id | UUID FK→users | 教师 |
| subject | VARCHAR(30) | 学科 |
| class_name | VARCHAR(50) | 班级 |
| session_date | DATE | 上课日期 |
| audio_url | VARCHAR(500) | 录音 URL |
| transcript | TEXT | 转写文本 |
| summary_outline | JSONB | 大纲摘要 |
| summary_visual | JSONB | 图表摘要 |
| doubt_points | JSONB | 疑问点 |
| duration_min | INTEGER | 时长(分钟) |
| status | VARCHAR(20) | processing/completed/failed |
| created_at | TIMESTAMPTZ | 创建时间 |

#### study_plans — 个性化学案表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 学生 |
| session_id | UUID FK→classroom_sessions | 课堂 |
| review_points | JSONB | 复习要点 |
| exercises | JSONB | 练习题 |
| resources | JSONB | 拓展资源 |
| completion_rate | FLOAT | 完成率 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### emotion_records — 情绪记录表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 用户 |
| emotion_label | VARCHAR(30) | 情绪标签 |
| valence | FLOAT | 效价 [-1,1] |
| arousal | FLOAT | 唤醒度 [0,1] |
| source | VARCHAR(30) | text/voice/visual/multimodal |
| confidence | FLOAT | 置信度 |
| context | JSONB | 触发上下文 |
| conversation_id | UUID FK→conversations | 关联会话 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### crisis_alerts — 危机预警表 [SAFETY-CRITICAL]
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 用户 |
| alert_level | ENUM(high,critical) | 预警等级 |
| trigger_type | VARCHAR(50) | keyword/emotion_threshold/combined |
| trigger_content | TEXT | 触发内容(脱敏) |
| notified_roles | JSONB | 已通知角色 |
| response_time_ms | INTEGER | 响应耗时(ms) |
| status | ENUM(active,acknowledged,resolved) | 状态 |
| resolved_by | UUID FK→users | 处理人 |
| resolved_at | TIMESTAMPTZ | 处理时间 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### health_records — 健康监测表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 用户 |
| record_type | VARCHAR(30) | screen_time/posture/exercise |
| value | FLOAT | 数值 |
| unit | VARCHAR(20) | 单位 |
| metadata | JSONB | 元数据 |
| alert_triggered | BOOLEAN | 是否触发提醒 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### personas — 学伴人设表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| name | VARCHAR(100) | 名称 |
| persona_type | VARCHAR(30) | scholar/pet/friend/mentor |
| description | TEXT | 描述 |
| avatar_config | JSONB | 形象配置 |
| personality | JSONB | 性格参数(>=20维) |
| voice_config | JSONB | 语音配置 |
| system_prompt | TEXT | System Prompt |
| is_preset | BOOLEAN | 是否预设 |
| created_by | UUID FK→users | 创建者 |
| version | INTEGER | 版本号 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### user_personas — 用户-学伴绑定表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 用户 |
| persona_id | UUID FK→personas | 人设 |
| is_active | BOOLEAN | 是否启用 |
| nickname | VARCHAR(100) | 自定义昵称 |
| customization | JSONB | 个性化参数 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### goals — 目标管理表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 用户 |
| parent_goal_id | UUID FK→goals | 父目标(层级) |
| title | VARCHAR(200) | 标题 |
| description | TEXT | 描述 |
| goal_type | VARCHAR(30) | academic/career/personal |
| deadline | DATE | 截止日 |
| progress | FLOAT | 进度 0-100 |
| status | ENUM(active,completed,paused) | 状态 |
| smart_criteria | JSONB | SMART 维度 |
| created_at | TIMESTAMPTZ | 创建时间 |

#### audit_logs — 审计日志表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID PK | 主键 |
| user_id | UUID FK→users | 操作人 |
| action | VARCHAR(100) | 操作 |
| resource_type | VARCHAR(50) | 资源类型 |
| resource_id | VARCHAR(255) | 资源 ID |
| details | JSONB | 详情 |
| ip_address | INET | IP 地址 |
| user_agent | TEXT | UA |
| created_at | TIMESTAMPTZ | 创建时间 |

### 关键索引

```sql
CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at);
CREATE INDEX idx_learning_records_user ON learning_records(user_id, subject, created_at DESC);
CREATE INDEX idx_emotion_records_user ON emotion_records(user_id, created_at DESC);
CREATE INDEX idx_crisis_alerts_status ON crisis_alerts(status, created_at DESC);
CREATE INDEX idx_health_records_user ON health_records(user_id, record_type, created_at DESC);
CREATE INDEX idx_conversations_user ON conversations(user_id, updated_at DESC);
CREATE INDEX idx_audit_logs_time ON audit_logs(created_at DESC);
```

---

## Milvus 向量集合

### knowledge_vectors — 知识库向量
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT64 PK (auto) | 主键 |
| source_type | VARCHAR(30) | textbook/exercise/article |
| subject | VARCHAR(30) | 学科 |
| topic | VARCHAR(200) | 知识点 |
| content_chunk | VARCHAR(4096) | 文本切片 |
| vector | FLOAT_VECTOR(768) | BGE-large-zh 向量 |

**索引**: HNSW (M=16, efConstruction=200)

### conversation_vectors — 会话向量
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT64 PK | 主键 |
| user_id | VARCHAR(36) | 用户 ID |
| conversation_id | VARCHAR(36) | 会话 ID |
| content | VARCHAR(2048) | 消息内容 |
| vector | FLOAT_VECTOR(768) | 语义向量 |

**索引**: HNSW

---

## Neo4j 知识图谱

### 节点类型
```
(:Subject {name, description})                   // 学科
(:Topic {name, difficulty, grade})                // 知识点
(:Exercise {content, answer, difficulty, type})   // 练习题
(:Concept {name, definition})                     // 概念
```

### 关系类型
```
(:Subject)-[:HAS_TOPIC]->(:Topic)
(:Topic)-[:PREREQUISITE]->(:Topic)               // 前置知识
(:Topic)-[:RELATED_TO]->(:Topic)                 // 关联知识
(:Topic)-[:HAS_EXERCISE]->(:Exercise)
(:Topic)-[:INVOLVES]->(:Concept)
(:Concept)-[:PART_OF]->(:Concept)
```
