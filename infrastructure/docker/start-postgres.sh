#!/usr/bin/env bash
# 启动 PostgreSQL 容器（端口 5433，避免与本机 5432 冲突）

set -e
cd "$(dirname "$0")"

docker compose up -d postgres
echo "PostgreSQL 已启动，数据库 jy_companion 已创建。"
echo "连接: postgresql+asyncpg://postgres:postgres@localhost:5433/jy_companion"
echo "backend/.env 已配置为上述地址。"
