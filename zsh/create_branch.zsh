#!/usr/bin/env zsh

# Git Branch Helper para Zsh
# Função para criar branches Git com padrão personalizado

# Carregar função de configuração se existir
if [[ -f "$(dirname "${(%):-%x}")/git_branch_config.zsh" ]]; then
    source "$(dirname "${(%):-%x}")/git_branch_config.zsh"
fi

create_branch() {
    # Verificar se estamos em um repositório Git
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ Erro: Este diretório não é um repositório Git!"
        return 1
    fi

    # Variáveis de configuração
    local username="${GIT_BRANCH_USERNAME:-ribeiroevandro}"
    local allowed_prefixes="${GIT_BRANCH_ALLOWED_PREFIXES:-$HOME/workspace/gitlab:$HOME/workspace/github/buser}"
    
    # Processar argumentos
    local auto_confirm=0
    local positional_args=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--yes)
                auto_confirm=1
                shift
                ;;
            *)
                positional_args+=("$1")
                shift
                ;;
        esac
    done

    local branch_type="${positional_args[1]:-}"
    local branch_name="${positional_args[@]:2}"

    # Obter tipo de branch se não fornecido
    if [[ -z "$branch_type" ]]; then
        echo "🔀 Tipos de branch disponíveis:"
        echo "  1) feat    - Nova funcionalidade"
        echo "  2) fix     - Correção de bug"
        echo "  3) chore   - Tarefas de manutenção"
        echo "  4) docs    - Documentação"
        echo "  5) style   - Formatação/estilo"
        echo "  6) refactor - Refatoração"
        echo "  7) test    - Testes"
        read "branch_type?📝 Digite o número ou nome do tipo de branch: "
    fi

    # Mapear números para tipos
    case "$branch_type" in
        1) branch_type="feat" ;;
        2) branch_type="fix" ;;
        3) branch_type="chore" ;;
        4) branch_type="docs" ;;
        5) branch_type="style" ;;
        6) branch_type="refactor" ;;
        7) branch_type="test" ;;
    esac

    # Validar tipo
    if [[ -z "$branch_type" ]]; then
        echo "❌ Tipo de branch não pode estar vazio!"
        return 1
    fi

    # Obter nome da branch se não fornecido
    if [[ -z "$branch_name" ]]; then
        read "branch_name?📝 Digite o nome da branch (ex: migração de tela xpto): "
    fi

    if [[ -z "$branch_name" ]]; then
        echo "❌ Nome da branch não pode estar vazio!"
        return 1
    fi

    # Limpar e formatar strings
    local clean_type=$(echo "$branch_type" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
    
    local clean_name=$(echo "$branch_name" | tr '[:upper:]' '[:lower:]' | \
        sed 's/[áàâãä]/a/g; s/[éèêë]/e/g; s/[íìîï]/i/g; s/[óòôõö]/o/g; s/[úùûü]/u/g; s/ç/c/g; s/ñ/n/g' | \
        sed 's/[^a-z0-9 ]//g' | sed 's/ \+/-/g' | sed 's/^-\+//; s/-\+$//')

    # Criar nome da branch
    local branch_suffix="${clean_type}-${clean_name}"
    local full_branch_name="${clean_type}/${clean_name}"

    # Verificar se está em diretório autorizado
    local current_dir=$(pwd)
    local IFS=':'
    local prefixes=(${=allowed_prefixes})
    
    for prefix in "${prefixes[@]}"; do
        if [[ "$current_dir" == "$prefix"* ]]; then
            full_branch_name="${username}/${branch_suffix}"
            break
        fi
    done

    # Mostrar preview
    echo ""
    echo "🎯 Branch que será criada:"
    echo "   $full_branch_name"
    echo ""

    # Confirmar criação
    if [[ $auto_confirm -eq 0 ]]; then
        read "confirm?✅ Criar esta branch? [Y/n]: "
        if [[ "$confirm" == "n" ]] || [[ "$confirm" == "N" ]]; then
            echo "❌ Operação cancelada."
            return 0
        fi
    fi

    # Verificar se branch já existe
    if git show-ref --verify --quiet "refs/heads/$full_branch_name"; then
        echo "❌ A branch '$full_branch_name' já existe!"
        return 1
    fi

    # Criar e fazer checkout
    if git switch -c "$full_branch_name"; then
        echo ""
        echo "🎉 Branch '$full_branch_name' criada e ativada com sucesso!"
        echo "📂 Você está agora na nova branch."
        echo ""
        git status --short
    else
        echo "❌ Erro ao criar a branch!"
        return 1
    fi
}

# Autocompletar para Zsh
_create_branch() {
    local -a branch_types
    branch_types=(
        'feat:Nova funcionalidade'
        'fix:Correção de bug'
        'chore:Tarefas de manutenção'
        'docs:Documentação'
        'style:Formatação/estilo'
        'refactor:Refatoração'
        'test:Testes'
        '1:feat - Nova funcionalidade'
        '2:fix - Correção de bug'
        '3:chore - Tarefas de manutenção'
        '4:docs - Documentação'
        '5:style - Formatação/estilo'
        '6:refactor - Refatoração'
        '7:test - Testes'
    )
    
    _arguments \
        '(--yes -y)'{-y,--yes}'[Auto-confirmar criação da branch]' \
        '1:tipo de branch:_describe "tipos de branch" branch_types' \
        '*:nome da branch:'
}

compdef _create_branch create_branch