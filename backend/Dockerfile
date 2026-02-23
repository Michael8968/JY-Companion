# 用于运行迁移或 API（可被 docker-compose 覆盖 command）
FROM python:3.12-slim

WORKDIR /app

# 安装 uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# 复制依赖声明并安装依赖
COPY pyproject.toml .
RUN uv sync --no-dev --no-install-project

# 复制项目代码
COPY . .
RUN uv sync --no-dev

ENV PATH="/app/.venv/bin:$PATH"

# 默认可运行 uvicorn；迁移时由 compose 覆盖为 alembic upgrade head
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
