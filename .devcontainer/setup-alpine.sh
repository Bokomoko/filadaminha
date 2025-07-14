#!/bin/bash
# Dev Container setup script for Alpine Linux
# Installation order: UV → Ruff → Python → Dependencies

set -e

echo "🚀 Setting up Fila da Minha development environment on Alpine..."

# Update system packages first
echo "📦 Updating system packages..."
apk update && apk upgrade

# Install basic system dependencies (without Python yet)
echo "� Installing basic system dependencies..."
apk add --no-cache \
    git \
    curl \
    wget \
    bash \
    zsh \
    build-base \
    libffi-dev \
    openssl-dev \
    linux-headers \
    gcc \
    musl-dev

# Install UV first (Python package manager)
echo "� Installing UV (Python package manager)..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source ~/.profile
    export PATH="$HOME/.cargo/bin:$PATH"
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
fi

# Install Ruff second (Python linter/formatter)
echo "🧹 Installing Ruff (linter/formatter)..."
if ! command -v ruff &> /dev/null; then
    curl -LsSf https://astral.sh/ruff/install.sh | sh
    source ~/.profile
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Now install Python 3.12 and related packages
echo "� Installing Python 3.12..."
apk add --no-cache \
    python3=~3.12 \
    python3-dev=~3.12 \
    py3-pip \
    py3-venv

# Create symlinks for python commands
echo "🔗 Creating Python symlinks..."
ln -sf /usr/bin/python3 /usr/local/bin/python
ln -sf /usr/bin/python3 /usr/local/bin/python3.12

# Verify installations
echo "🔍 Verifying installations..."
echo "UV version: $(uv --version)"
echo "Ruff version: $(ruff --version)"
echo "Python version: $(python3 --version)"

# Install project dependencies using UV
echo "📚 Installing project dependencies..."
if [ -f "pyproject.toml" ]; then
    # Create virtual environment with UV using the installed Python
    echo "🔧 Creating virtual environment with UV..."
    uv venv --python python3.12

    # Install dependencies
    echo "📥 Installing project dependencies with UV..."
    uv sync

    echo "✅ Dependencies installed successfully"
    echo "✅ Virtual environment created with UV"
else
    echo "⚠️  pyproject.toml not found, skipping dependency installation"
fi

# Configure environment paths
echo "🔧 Configuring environment paths..."
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
echo 'export PYTHONPATH="/workspaces/filadaminha/src"' >> ~/.bashrc

# Set proper permissions
chmod +x ~/.local/bin/* 2>/dev/null || true

# Final verification
echo "🔍 Final verification..."
echo "✅ UV: $(which uv) - $(uv --version)"
echo "✅ Ruff: $(which ruff) - $(ruff --version)"
echo "✅ Python: $(which python3) - $(python3 --version)"

echo ""
echo "✅ Alpine development environment setup complete!"
echo "🎉 Installation order completed: UV → Ruff → Python → Dependencies"
echo "📋 Available tools:"
echo "   - UV: $(uv --version)"
echo "   - Ruff: $(ruff --version)"
echo "   - Python: $(python3 --version | cut -d' ' -f2)"
echo "   - FastAPI development server on ports 3000/8000"
