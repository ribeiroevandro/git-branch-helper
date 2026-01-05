#!/usr/bin/env bash

# Instalador Universal do Git Branch Helper
# Detecta o shell e instala a versão apropriada

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_error() { echo -e "${RED}$1${NC}"; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_info() { echo -e "${BLUE}$1${NC}"; }
print_warning() { echo -e "${YELLOW}$1${NC}"; }

# Lê input do usuário de forma robusta, mesmo quando o script é executado via pipe
# (ex.: curl ... | bash), onde o stdin não é um TTY.
prompt_read() {
    local prompt="$1"
    local reply=""

    if [ -t 0 ]; then
        # stdin interativo
        read -r -p "$prompt" reply || true
    elif [ -r /dev/tty ]; then
        # stdin veio de pipe; tenta ler do terminal
        read -r -p "$prompt" reply </dev/tty || true
    fi

    printf '%s' "$reply"
}

REPO_URL="https://raw.githubusercontent.com/ribeiroevandro/git-branch-helper/main"

echo ""
print_info "🐚 Git Branch Helper - Instalador Universal"
echo ""

# Detectar shell do usuário
detect_shell() {
    # Override explícito (útil quando executando via pipe: curl ... | bash)
    if [ -n "${GIT_BRANCH_HELPER_SHELL:-}" ]; then
        echo "$GIT_BRANCH_HELPER_SHELL"
        return 0
    fi

    # Preferir o shell do usuário (geralmente definido como login shell)
    if [ -n "${SHELL:-}" ]; then
        case "${SHELL##*/}" in
            fish|zsh|bash)
                echo "${SHELL##*/}"
                return 0
                ;;
        esac
    fi

    # Fallback: detectar pelo shell que está executando este script
    if [ -n "${FISH_VERSION:-}" ]; then
        echo "fish"
    elif [ -n "${ZSH_VERSION:-}" ]; then
        echo "zsh"
    elif [ -n "${BASH_VERSION:-}" ]; then
        echo "bash"
    else
        echo "sh"
    fi
}

SHELL_TYPE=$(detect_shell)
print_info "🔍 Shell detectado: $SHELL_TYPE"
echo ""

# Perguntar método de instalação
echo "Escolha o método de instalação:"
echo ""
echo "  1) Plugin do shell (recomendado para Fish/Zsh/Bash)"
echo "  2) Script standalone (funciona em qualquer shell)"
echo "  3) Ambos"
echo ""

# Permite modo não-interativo via env var
choice="${GIT_BRANCH_HELPER_INSTALL_CHOICE:-}"
if [ -z "$choice" ]; then
    choice="$(prompt_read "Digite sua escolha [1-3]: ")"
fi
if [ -z "$choice" ]; then
    choice="1"
    print_warning "⚠️  Nenhuma entrada interativa detectada. Usando opção padrão: 1"
fi

case $choice in
    1)
        install_plugin=true
        install_standalone=false
        ;;
    2)
        install_plugin=false
        install_standalone=true
        ;;
    3)
        install_plugin=true
        install_standalone=true
        ;;
    *)
        print_error "❌ Escolha inválida!"
        exit 1
        ;;
esac

# Instalar plugin do shell
if [ "$install_plugin" = true ]; then
    print_info "📦 Instalando plugin para $SHELL_TYPE..."
    
    case $SHELL_TYPE in
        fish)
            if command -v fisher >/dev/null 2>&1; then
                print_info "🎣 Usando Fisher..."
                fisher install ribeiroevandro/git-branch-helper
                print_success "✅ Plugin Fish instalado com Fisher!"
            else
                print_warning "⚠️  Fisher não encontrado. Instalação manual..."
                FISH_DIR="$HOME/.config/fish"
                mkdir -p "$FISH_DIR/functions"
                mkdir -p "$FISH_DIR/completions"
                mkdir -p "$FISH_DIR/conf.d"
                
                curl -sL "$REPO_URL/fish/functions/create_branch.fish" -o "$FISH_DIR/functions/create_branch.fish"
                curl -sL "$REPO_URL/fish/functions/git_branch_config.fish" -o "$FISH_DIR/functions/git_branch_config.fish"
                curl -sL "$REPO_URL/fish/completions/create_branch.fish" -o "$FISH_DIR/completions/create_branch.fish"
                curl -sL "$REPO_URL/fish/completions/git_branch_config.fish" -o "$FISH_DIR/completions/git_branch_config.fish"
                curl -sL "$REPO_URL/fish/conf.d/git-branch-helper.fish" -o "$FISH_DIR/conf.d/git-branch-helper.fish"
                
                print_success "✅ Plugin Fish instalado manualmente!"
                print_info "💡 Reinicie o Fish ou execute: source ~/.config/fish/config.fish"
            fi
            ;;
            
        zsh)
            ZSH_DIR="$HOME/.zsh/git-branch-helper"
            mkdir -p "$ZSH_DIR"
            
            curl -sL "$REPO_URL/zsh/create_branch.zsh" -o "$ZSH_DIR/create_branch.zsh"
            
            ZSHRC="$HOME/.zshrc"
            if ! grep -q "git-branch-helper" "$ZSHRC" 2>/dev/null; then
                echo "" >> "$ZSHRC"
                echo "# Git Branch Helper" >> "$ZSHRC"
                echo "source $ZSH_DIR/create_branch.zsh" >> "$ZSHRC"
            fi
            
            print_success "✅ Plugin Zsh instalado!"
            print_info "💡 Execute: source ~/.zshrc"
            ;;
            
        bash)
            BASH_DIR="$HOME/.bash/git-branch-helper"
            mkdir -p "$BASH_DIR"
            
            curl -sL "$REPO_URL/bash/create_branch.bash" -o "$BASH_DIR/create_branch.bash"
            
            BASHRC="$HOME/.bashrc"
            if ! grep -q "git-branch-helper" "$BASHRC" 2>/dev/null; then
                echo "" >> "$BASHRC"
                echo "# Git Branch Helper" >> "$BASHRC"
                echo "source $BASH_DIR/create_branch.bash" >> "$BASHRC"
            fi
            
            print_success "✅ Plugin Bash instalado!"
            print_info "💡 Execute: source ~/.bashrc"
            ;;
            
        *)
            print_warning "⚠️  Shell não suportado para plugin. Use a versão standalone."
            install_standalone=true
            ;;
    esac
fi

# Instalar versão standalone
if [ "$install_standalone" = true ]; then
    print_info "📦 Instalando versão standalone..."
    
    # Determinar diretório de instalação
    if [ -w "/usr/local/bin" ]; then
        BIN_DIR="/usr/local/bin"
    else
        BIN_DIR="$HOME/.local/bin"
        mkdir -p "$BIN_DIR"
        
        # Adicionar ao PATH se necessário
        case $SHELL_TYPE in
            fish)
                FISH_CONFIG="$HOME/.config/fish/config.fish"
                if ! grep -q "$BIN_DIR" "$FISH_CONFIG" 2>/dev/null; then
                    echo "" >> "$FISH_CONFIG"
                    echo "# Local bin" >> "$FISH_CONFIG"
                    echo "set -gx PATH \$PATH $BIN_DIR" >> "$FISH_CONFIG"
                fi
                ;;
            zsh)
                if ! grep -q "$BIN_DIR" "$HOME/.zshrc" 2>/dev/null; then
                    echo "" >> "$HOME/.zshrc"
                    echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$HOME/.zshrc"
                fi
                ;;
            bash)
                if ! grep -q "$BIN_DIR" "$HOME/.bashrc" 2>/dev/null; then
                    echo "" >> "$HOME/.bashrc"
                    echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$HOME/.bashrc"
                fi
                ;;
        esac
    fi
    
    curl -sL "$REPO_URL/bin/git-create-branch" -o "$BIN_DIR/git-create-branch"
    chmod +x "$BIN_DIR/git-create-branch"
    
    print_success "✅ Script standalone instalado em: $BIN_DIR/git-create-branch"
    print_info "💡 Use: git-create-branch ou git create-branch"
fi

echo ""
print_success "🎉 Instalação concluída!"
echo ""
print_info "📝 Uso:"
echo "  create_branch                    # Modo interativo"
echo "  create_branch feat nova feature  # Com argumentos"
echo "  create_branch -y fix bug         # Auto-confirmar"
echo "  git-create-branch --help         # Ajuda (standalone)"
echo ""
print_info "⚙️  Configuração (opcional):"
echo "  export GIT_BRANCH_USERNAME=\"seu-username\""
echo "  export GIT_BRANCH_ALLOWED_PREFIXES=\"\$HOME/workspace/gitlab:\$HOME/projects\""
echo ""
print_info "📚 Documentação completa:"
echo "  https://github.com/ribeiroevandro/git-branch-helper"
echo ""