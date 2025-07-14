#!/bin/bash
# Dev Container setup script for Podman environment
# This script ensures all tools are properly installed and configured

set -e

echo "🚀 Setting up Fila da Minha development environment..."

# Update system packages
echo "📦 Updating system packages..."
apk update && apk upgrade

# Install system dependencies
echo "🔧 Installing system dependencies..."
apk add --no-cache \
    git \
    curl \
    wget \
    bash \
    zsh \
    build-base \
    libffi-dev \
    openssl-dev

# Install UV (Python package manager)
echo "🐍 Installing UV..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source ~/.profile
fi

# Install Ruff (Python linter/formatter)
echo "🧹 Installing Ruff..."
if ! command -v ruff &> /dev/null; then
    curl -LsSf https://astral.sh/ruff/install.sh | sh
    source ~/.profile
fi

# Verify Python installation
echo "🔍 Verifying Python installation..."
python3 --version
which python3

# Install project dependencies
echo "📚 Installing project dependencies..."
if [ -f "pyproject.toml" ]; then
    uv sync
    echo "✅ Dependencies installed successfully"
else
    echo "⚠️  pyproject.toml not found, skipping dependency installation"
fi

# Set up git configuration (if not already set)
if [ -z "$(git config --global user.name)" ]; then
    echo "⚙️  Setting up git configuration..."
    git config --global user.name "Developer"
    git config --global user.email "dev@example.com"
    git config --global init.defaultBranch main
fi

# Create development directories
echo "📁 Creating development directories..."
mkdir -p ~/.local/bin
mkdir -p ~/.config

# Set proper permissions
chmod +x ~/.local/bin/* 2>/dev/null || true

echo "✅ Development environment setup complete!"
echo "🎉 You can now start developing with:"
echo "   - Python $(python3 --version | cut -d' ' -f2)"
echo "   - UV package manager"
echo "   - Ruff linter/formatter"
echo "   - FastAPI development server on ports 3000/8000"
