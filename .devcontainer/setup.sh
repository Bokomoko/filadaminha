#!/bin/bash
# Dev Container setup script for Alpine Linux
# Installation order: UV → Ruff → Python → Dependencies

set -e

echo "🚀 Setting up Fila da Minha development environment on Alpine..."

# Update system packages first (requires root)
echo "📦 Updating system packages..."
apk update && apk upgrade

# Install basic system dependencies (without Python yet) (requires root)
echo "🔧 Installing basic system dependencies..."
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
    musl-dev \
    sudo

# Ensure vscode user exists and has sudo privileges
if ! id "vscode" &>/dev/null; then
    echo "👤 Creating vscode user..."
    adduser -D -s /bin/bash vscode
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
else
    echo "👤 User vscode already exists"
fi

# Now install Python 3.12 and related packages (requires root)
echo "🐍 Installing Python 3.12..."
apk add --no-cache \
    python3=~3.12 \
    python3-dev=~3.12 \
    py3-pip \
    py3-venv

# Create symlinks for python commands (requires root)
echo "🔗 Creating Python symlinks..."
ln -sf /usr/bin/python3 /usr/local/bin/python
ln -sf /usr/bin/python3 /usr/local/bin/python3.12

# From here on, run as the vscode user for user-level installations
USER_HOME="/home/vscode"
SUDO_USER_CMD="sudo -u vscode"

# Install UV first (Python package manager) as user
echo "📦 Installing UV (Python package manager)..."
if ! $SUDO_USER_CMD bash -c 'command -v uv' &> /dev/null; then
    $SUDO_USER_CMD bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
    $SUDO_USER_CMD bash -c 'source ~/.profile && export PATH="$HOME/.cargo/bin:$PATH"'
    $SUDO_USER_CMD bash -c 'echo "export PATH=\"\$HOME/.cargo/bin:\$PATH\"" >> ~/.bashrc'
fi

# Install Ruff second (Python linter/formatter) as user
echo "🧹 Installing Ruff (linter/formatter)..."
if ! $SUDO_USER_CMD bash -c 'command -v ruff' &> /dev/null; then
    $SUDO_USER_CMD bash -c 'curl -LsSf https://astral.sh/ruff/install.sh | sh'
    $SUDO_USER_CMD bash -c 'source ~/.profile && export PATH="$HOME/.cargo/bin:$PATH"'
fi
# Verify installations as user
echo "🔍 Verifying installations..."
$SUDO_USER_CMD bash -c 'export PATH="$HOME/.cargo/bin:$PATH" && echo "UV version: $(uv --version)"'
$SUDO_USER_CMD bash -c 'export PATH="$HOME/.cargo/bin:$PATH" && echo "Ruff version: $(ruff --version)"'
echo "Python version: $(python3 --version)"

# Navigate to workspace and install project dependencies using UV as user
echo "📚 Installing project dependencies..."
cd /workspaces/filadaminha
if [ -f "pyproject.toml" ]; then
    # Create virtual environment with UV using the installed Python as user
    echo "🔧 Creating virtual environment with UV..."
    $SUDO_USER_CMD bash -c 'cd /workspaces/filadaminha && export PATH="$HOME/.cargo/bin:$PATH" && uv venv --python python3.12'

    # Install dependencies as user
    echo "📥 Installing project dependencies with UV..."
    $SUDO_USER_CMD bash -c 'cd /workspaces/filadaminha && export PATH="$HOME/.cargo/bin:$PATH" && uv sync'

    echo "✅ Dependencies installed successfully"
    echo "✅ Virtual environment created with UV"
else
    echo "⚠️  pyproject.toml not found, skipping dependency installation"
fi

# Configure Git user settings - copy from host if available
echo "🔧 Configuring Git user settings..."
if [ -f "/tmp/.gitconfig" ]; then
    echo "📋 Copying Git configuration from host..."
    $SUDO_USER_CMD bash -c 'cp /tmp/.gitconfig ~/.gitconfig'
    $SUDO_USER_CMD bash -c 'echo "✅ Git configuration copied from host"'
else
    echo "🔍 Attempting to detect Git configuration from host environment..."
    # Try to get configuration from environment or use defaults
    GIT_USER_NAME="${GIT_AUTHOR_NAME:-João Eurico}"
    GIT_USER_EMAIL="${GIT_AUTHOR_EMAIL:-joao.eurico@live.com}"

    echo "👤 Setting Git user to: $GIT_USER_NAME <$GIT_USER_EMAIL>"
    $SUDO_USER_CMD bash -c "git config --global user.name '$GIT_USER_NAME'"
    $SUDO_USER_CMD bash -c "git config --global user.email '$GIT_USER_EMAIL'"
fi

# Copy SSH keys if available
if [ -d "/tmp/.ssh" ]; then
    echo "🔑 Copying SSH keys from host..."
    $SUDO_USER_CMD bash -c 'cp -r /tmp/.ssh ~/.ssh'
    $SUDO_USER_CMD bash -c 'chmod 700 ~/.ssh'
    $SUDO_USER_CMD bash -c 'chmod 600 ~/.ssh/*'
    $SUDO_USER_CMD bash -c 'echo "✅ SSH keys copied from host"'
fi

# Set common Git defaults
$SUDO_USER_CMD bash -c 'git config --global init.defaultBranch main'
$SUDO_USER_CMD bash -c 'git config --global pull.rebase false'
$SUDO_USER_CMD bash -c 'git config --global core.autocrlf input'
$SUDO_USER_CMD bash -c 'git config --global core.editor "code --wait"'

# Configure environment paths for vscode user
echo "🔧 Configuring environment paths..."
$SUDO_USER_CMD bash -c 'echo "export PATH=\"\$HOME/.cargo/bin:\$PATH\"" >> ~/.bashrc'
$SUDO_USER_CMD bash -c 'echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc'
$SUDO_USER_CMD bash -c 'echo "export PYTHONPATH=\"/workspaces/filadaminha/src\"" >> ~/.bashrc'

# Set proper permissions
$SUDO_USER_CMD bash -c 'chmod +x ~/.local/bin/* 2>/dev/null || true'

# Final verification
echo "🔍 Final verification..."
$SUDO_USER_CMD bash -c 'export PATH="$HOME/.cargo/bin:$PATH" && echo "✅ UV: $(which uv) - $(uv --version)"'
$SUDO_USER_CMD bash -c 'export PATH="$HOME/.cargo/bin:$PATH" && echo "✅ Ruff: $(which ruff) - $(ruff --version)"'
echo "✅ Python: $(which python3) - $(python3 --version)"
$SUDO_USER_CMD bash -c 'echo "✅ Git User: $(git config --global user.name) <$(git config --global user.email)>"'

echo ""
echo "✅ Alpine development environment setup complete!"
echo "🎉 Installation order completed: UV → Ruff → Python → Dependencies"
echo "📋 Available tools:"
$SUDO_USER_CMD bash -c 'export PATH="$HOME/.cargo/bin:$PATH" && echo "   - UV: $(uv --version)"'
$SUDO_USER_CMD bash -c 'export PATH="$HOME/.cargo/bin:$PATH" && echo "   - Ruff: $(ruff --version)"'
echo "   - Python: $(python3 --version | cut -d' ' -f2)"
$SUDO_USER_CMD bash -c 'echo "   - Git: $(git --version | cut -d\" \" -f3) (User: $(git config --global user.name))"'
echo "   - FastAPI development server on ports 3000/8000"
