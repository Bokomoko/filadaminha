#!/bin/bash
# Development scripts for UV and Ruff integration

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${BLUE}Fila da Minha - Development Helper${NC}"
    echo ""
    echo "Usage: ./dev.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  install       Install/sync dependencies with UV"
    echo "  run           Run FastAPI development server"
    echo "  test          Run tests with pytest"
    echo "  lint          Run Ruff linter"
    echo "  format        Format code with Ruff"
    echo "  check         Run linting and formatting checks"
    echo "  clean         Clean cache and temporary files"
    echo "  shell         Activate UV virtual environment"
    echo ""
}

install_deps() {
    echo -e "${BLUE}📦 Installing dependencies with UV...${NC}"
    uv sync
    echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
}

run_server() {
    echo -e "${BLUE}🚀 Starting FastAPI development server...${NC}"
    uv run uvicorn src.queueserver.server:app --host 0.0.0.0 --port 3000 --reload
}

run_tests() {
    echo -e "${BLUE}🧪 Running tests with pytest...${NC}"
    uv run pytest src/queueserver/tests/ -v
}

run_lint() {
    echo -e "${BLUE}🔍 Running Ruff linter...${NC}"
    uv run ruff check src/
}

run_format() {
    echo -e "${BLUE}🧹 Formatting code with Ruff...${NC}"
    uv run ruff format src/
    uv run ruff check --fix src/
    echo -e "${GREEN}✅ Code formatted successfully${NC}"
}

run_check() {
    echo -e "${BLUE}⚡ Running code quality checks...${NC}"
    echo -e "${YELLOW}Checking code style...${NC}"
    uv run ruff check src/
    echo -e "${YELLOW}Checking formatting...${NC}"
    uv run ruff format --check src/
    echo -e "${GREEN}✅ All checks passed${NC}"
}

clean_cache() {
    echo -e "${BLUE}🧹 Cleaning cache and temporary files...${NC}"
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
    find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
    echo -e "${GREEN}✅ Cache cleaned${NC}"
}

activate_shell() {
    echo -e "${BLUE}🐚 Activating UV virtual environment...${NC}"
    echo -e "${YELLOW}Run: source .venv/bin/activate${NC}"
    uv shell
}

case "${1:-help}" in
    install)
        install_deps
        ;;
    run)
        run_server
        ;;
    test)
        run_tests
        ;;
    lint)
        run_lint
        ;;
    format)
        run_format
        ;;
    check)
        run_check
        ;;
    clean)
        clean_cache
        ;;
    shell)
        activate_shell
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
