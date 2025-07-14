#!/bin/bash
# Script para simular criação do dev container

set -e

echo "🧪 Simulando criação do Dev Container..."
echo "======================================="

# Configurações do devcontainer
CONTAINER_NAME="filadaminha-dev-test"
IMAGE="mcr.microsoft.com/devcontainers/base:alpine-3.20"
WORKSPACE_DIR="/home/bokomoko/src/projects/filadaminha"

echo "📋 Configurações:"
echo "  - Nome: $CONTAINER_NAME"
echo "  - Imagem: $IMAGE"
echo "  - Workspace: $WORKSPACE_DIR"

# Limpar container anterior se existir
echo "🧹 Limpando containers anteriores..."
podman rm -f $CONTAINER_NAME 2>/dev/null || true

# Criar container com as mesmas configurações do devcontainer
echo "🚀 Criando container de desenvolvimento..."
podman run -d \
  --name $CONTAINER_NAME \
  --userns=keep-id \
  --security-opt label=disable \
  -p 3000:3000 \
  -p 8000:8000 \
  -v $WORKSPACE_DIR:/workspaces/filadaminha \
  -w /workspaces/filadaminha \
  -e UV_LINK_MODE=copy \
  -e UV_COMPILE_BYTECODE=1 \
  -e UV_PYTHON=python3.12 \
  -e SECRET_KEY=dev-secret-key-change-in-production \
  -e HOST=0.0.0.0 \
  -e PORT=3000 \
  $IMAGE \
  sleep infinity

echo "✅ Container criado: $CONTAINER_NAME"

# Executar o script de setup
echo "⚙️ Executando script de setup..."
podman exec $CONTAINER_NAME /bin/bash -c "cd /workspaces/filadaminha && ./.devcontainer/setup-alpine.sh"

echo "🔍 Verificando instalações..."
podman exec $CONTAINER_NAME /bin/bash -c "cd /workspaces/filadaminha && ./.devcontainer/test-setup.sh"

echo "✅ Teste do Dev Container concluído!"
echo "🧹 Para limpar: podman rm -f $CONTAINER_NAME"
