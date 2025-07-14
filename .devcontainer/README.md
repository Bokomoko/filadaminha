# Dev Container Configuration for Podman

Este diretório contém a configuração do Dev Container otimizada para usar **Podman** em vez do Docker tradicional.

## 🐳 Configuração Podman

### Características Principais

- **Rootless containers**: Execução sem privilégios administrativos
- **User namespace mapping**: Mantém ownership dos arquivos
- **Security optimized**: Configurações de segurança aprimoradas
- **Fully qualified image names**: Compatibilidade total com registries

### Imagem Base

```
mcr.microsoft.com/devcontainers/base:alpine-3.20
```

## 🚀 Como Usar

### Pré-requisitos

1. **Podman** instalado no sistema
2. **VS Code** com extensão Dev Containers
3. **Podman extension** para VS Code (opcional)

### Configuração do Podman

O Dev Container está configurado com:

- `--userns=keep-id`: Mantém o ID do usuário
- `--security-opt label=disable`: Desabilita SELinux para desenvolvimento
- Storage driver otimizado para performance

### Iniciando o Ambiente

1. Abra o projeto no VS Code
2. Execute: `Ctrl+Shift+P` → `Dev Containers: Reopen in Container`
3. Aguarde a configuração automática

## 🛠 Ferramentas Incluídas

### Python Environment

- **Python 3.12+** com ferramentas de desenvolvimento
- **UV** - Gerenciador de dependências moderno e rápido
- **Ruff** - Linter e formatter extremamente rápido
- **Pytest** - Framework de testes

### Extensões VS Code

#### Desenvolvimento Python
- Python, Pylance, Debugpy
- Ruff integration
- Python Environment Manager
- Pytest Runner

#### API Development
- OpenAPI support
- REST Client
- Thunder Client

#### Git & GitHub
- GitHub Pull Requests
- Git History
- Git Graph

#### Code Quality
- Error Lens
- Todo Tree
- Indent Rainbow

### Portas Expostas

- **3000**: FastAPI Server (principal)
- **8000**: FastAPI Alternative Port

## 📁 Arquivos de Configuração

```
.devcontainer/
├── devcontainer.json    # Configuração principal
├── setup.sh            # Script de inicialização
├── podman.conf         # Configuração específica do Podman
└── README.md           # Esta documentação
```

## 🔧 Troubleshooting

### Problemas Comuns

#### Permissões de Arquivo
```bash
# Se houver problemas de permissão:
podman unshare chown -R $(id -u):$(id -g) .
```

#### Container não inicia
```bash
# Verificar logs do Podman:
podman logs <container_id>

# Rebuildar container:
# Ctrl+Shift+P → Dev Containers: Rebuild Container
```

#### Extensões não carregam
```bash
# Reinstalar extensões:
# Ctrl+Shift+P → Developer: Reload Window
```

### Performance

Para melhor performance:
- Use SSD para o workspace
- Configure Podman com storage overlay
- Aumente a memória disponível se necessário

## 🌟 Vantagens do Podman

1. **Segurança**: Execução rootless por padrão
2. **Compatibilidade**: API compatível com Docker
3. **Performance**: Menor overhead de runtime
4. **Integração**: Melhor integração com systemd
5. **Daemonless**: Não requer daemon em execução

## 📝 Customização

Para personalizar o ambiente:

1. Edite `devcontainer.json` para adicionar features
2. Modifique `setup.sh` para instalar ferramentas adicionais
3. Ajuste `podman.conf` para configurações específicas
4. Adicione extensões na seção `customizations.vscode.extensions`

## 🔄 Atualizações

Para atualizar a imagem base:

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:alpine-3.21"
}
```

## 📚 Recursos Adicionais

- [Podman Documentation](https://docs.podman.io/)
- [Dev Containers Specification](https://containers.dev/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/remote/containers)
