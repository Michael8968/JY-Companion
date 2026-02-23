## ADDED Requirements

### Requirement: 用户注册与登录

支持学生、教师、家长、管理员四种角色的注册与登录，采用 OAuth2 + JWT Token 认证机制。

#### Scenario: 学生使用学号注册

- **WHEN** 学生输入学号、姓名、班级并设置密码提交注册
- **THEN** 系统验证学号在教务系统中存在且未被注册
- **AND** 创建学生账户，角色设为 `student`，返回 JWT access_token 和 refresh_token

#### Scenario: 用户登录获取 Token

- **WHEN** 用户提交正确的用户名和密码到 `POST /api/v1/auth/login`
- **THEN** 系统返回 JWT access_token（有效期 30 分钟）和 refresh_token（有效期 7 天）
- **AND** 记录 last_login_at 时间戳

#### Scenario: Token 自动刷新

- **WHEN** access_token 过期但 refresh_token 仍有效
- **THEN** 客户端自动调用 `POST /api/v1/auth/refresh` 获取新 access_token
- **AND** 用户无感知地继续操作

### Requirement: SSO 统一身份认证集成

支持与学校现有统一身份认证系统对接。

#### Scenario: SSO 登录跳转

- **WHEN** 用户选择"学校账号登录"
- **THEN** 系统重定向到学校 SSO 认证页面
- **AND** 认证成功后回调 `POST /api/v1/auth/sso/callback`，创建或关联本地账户

### Requirement: RBAC 权限控制

基于角色的访问控制，四种角色拥有不同权限。

#### Scenario: 学生访问受限 API

- **WHEN** 学生角色用户请求管理后台 API `GET /api/v1/admin/dashboard`
- **THEN** 系统返回 403 Forbidden
- **AND** 记录访问审计日志

#### Scenario: 教师访问课堂管理

- **WHEN** 教师角色用户请求 `POST /api/v1/classroom/sessions`
- **THEN** 系统允许访问并处理请求

#### Scenario: API 限流策略

- **WHEN** 普通用户在 1 分钟内发送超过 100 次请求
- **THEN** 系统返回 429 Too Many Requests
- **AND** 教师账号限制为 500 次/分钟，管理员不限制
