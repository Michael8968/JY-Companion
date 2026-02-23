import asyncio
import sys
from logging.config import fileConfig

from alembic import context
from sqlalchemy import create_engine, pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import create_async_engine

from app.core.database import Base
from app.config.settings import get_settings

# Import all models so they are registered with Base.metadata
from app.models.user import User, UserProfile  # noqa: F401
from app.models.conversation import Conversation, Message  # noqa: F401
from app.models.learning import LearningRecord, ErrorRecord  # noqa: F401
from app.models.classroom import ClassroomSession, ClassroomDoubt, StudyPlan, UserLearningProfile  # noqa: F401
from app.models.emotion import EmotionRecord, CrisisAlert, GratitudeEntry  # noqa: F401
from app.models.health import ScreenTimeRecord, HealthReminder, ExercisePlan  # noqa: F401
from app.models.career import Goal, LearningPath, ProgressReport  # noqa: F401
from app.models.persona import Persona, UserPersonaBinding, PersonaMemoryEntry  # noqa: F401

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

settings = get_settings()
config.set_main_option("sqlalchemy.url", settings.database_url)


def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection: Connection) -> None:
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()


def _sync_url() -> str:
    """同步驱动 URL（psycopg2），用于 Windows 上避免 asyncpg 与 Docker 端口兼容问题。"""
    import os
    # 从纯 ASCII 环境变量构建，避免 Windows 下 .env 编码导致的 UnicodeDecodeError
    host = os.environ.get("DB_HOST", "127.0.0.1")
    port = os.environ.get("DB_PORT", "5433")
    name = os.environ.get("DB_NAME", "jy_companion")
    user = os.environ.get("DB_USER", "postgres")
    password = os.environ.get("DB_PASSWORD", "postgres")
    return f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{name}"


def run_migrations_online_sync() -> None:
    """使用同步引擎运行迁移（Windows 上更稳定）。"""
    import os
    os.environ.setdefault("PGCLIENTENCODING", "UTF8")
    connectable = create_engine(
        _sync_url(),
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        do_run_migrations(connection)
    connectable.dispose()


async def run_async_migrations() -> None:
    connectable = create_async_engine(
        settings.database_url,
        poolclass=pool.NullPool,
        connect_args={"timeout": 10},
    )
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await connectable.dispose()


def run_migrations_online() -> None:
    if sys.platform == "win32":
        run_migrations_online_sync()
    else:
        asyncio.run(run_async_migrations())


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
