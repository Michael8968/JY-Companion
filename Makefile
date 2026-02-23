.PHONY: help dev dev-down backend-dev backend-test backend-lint backend-format \
       frontend-dev frontend-test frontend-lint \
       docker-build db-migrate db-seed proto clean

# ===========================
# Help
# ===========================
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ===========================
# Development Environment
# ===========================
dev: ## Start all services (Docker Compose)
	docker compose -f infrastructure/docker/docker-compose.yml up -d

dev-down: ## Stop all services
	docker compose -f infrastructure/docker/docker-compose.yml down

dev-logs: ## Follow service logs
	docker compose -f infrastructure/docker/docker-compose.yml logs -f

# ===========================
# Backend (FastAPI)
# ===========================
backend-install: ## Install backend dependencies
	cd backend && uv sync

backend-dev: ## Run backend dev server
	cd backend && uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

backend-test: ## Run backend tests
	cd backend && uv run pytest tests/ -v --cov=app --cov-report=term-missing

backend-test-unit: ## Run backend unit tests only
	cd backend && uv run pytest tests/unit/ -v

backend-lint: ## Lint backend code
	cd backend && uv run ruff check app/ tests/

backend-format: ## Format backend code
	cd backend && uv run ruff format app/ tests/

backend-typecheck: ## Type check backend
	cd backend && uv run mypy app/

# ===========================
# Frontend (Flutter)
# ===========================
frontend-dev: ## Run Flutter app (debug)
	cd frontend && flutter run

frontend-test: ## Run Flutter tests
	cd frontend && flutter test --coverage

frontend-lint: ## Analyze Flutter code
	cd frontend && flutter analyze

frontend-format: ## Format Dart code
	cd frontend && dart format lib/ test/

frontend-build-apk: ## Build Android APK
	cd frontend && flutter build apk

frontend-build-ios: ## Build iOS (macOS only)
	cd frontend && flutter build ios --no-codesign

# ===========================
# Database
# ===========================
db-migrate: ## Run database migrations
	cd backend && uv run alembic upgrade head

db-migrate-new: ## Create new migration (usage: make db-migrate-new MSG="description")
	cd backend && uv run alembic revision --autogenerate -m "$(MSG)"

db-rollback: ## Rollback last migration
	cd backend && uv run alembic downgrade -1

db-seed: ## Seed database with initial data
	cd backend && uv run python -m scripts.seed_data

# ===========================
# AI Services
# ===========================
ai-install: ## Install AI service dependencies
	cd ai_services && uv sync

# ===========================
# Proto / Shared
# ===========================
proto: ## Generate gRPC code from proto files
	bash scripts/generate_proto.sh

# ===========================
# Docker Build
# ===========================
docker-build-backend: ## Build backend Docker image
	docker build -f infrastructure/docker/Dockerfile.backend -t jy-companion-backend .

docker-build-ai: ## Build AI services Docker image
	docker build -f infrastructure/docker/Dockerfile.ai-services -t jy-companion-ai .

# ===========================
# Cleanup
# ===========================
clean: ## Clean generated files
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .mypy_cache -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
