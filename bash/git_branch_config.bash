#!/usr/bin/env bash

# Configuração do Git Branch Helper para Bash

git_branch_config() {
    local command="${1:-help}"
    
    case "$command" in
        add)
            # Adicionar diretório
            if [ -z "$2" ]; then
                echo "❌ Uso: git_branch_config add <diretório>"
                return 1
            fi
            
            local new_dir="$2"
            # Expandir ~
            new_dir="${new_dir/#\~/$HOME}"
            
            # Verificar se diretório existe
            if [ ! -d "$new_dir" ]; then
                echo "⚠️  Aviso: O diretório '$new_dir' não existe."
                read -rp "Deseja adicionar mesmo assim? [Y/n]: " confirm
                if [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
                    echo "❌ Operação cancelada."
                    return 0
                fi
            fi
            
            # Verificar se já existe
            if [[ ":$GIT_BRANCH_ALLOWED_PREFIXES:" == *":$new_dir:"* ]]; then
                echo "⚠️  O diretório '$new_dir' já está na lista."
                return 0
            fi
            
            # Adicionar à lista
            if [ -z "$GIT_BRANCH_ALLOWED_PREFIXES" ]; then
                export GIT_BRANCH_ALLOWED_PREFIXES="$new_dir"
            else
                export GIT_BRANCH_ALLOWED_PREFIXES="$GIT_BRANCH_ALLOWED_PREFIXES:$new_dir"
            fi
            
            # Salvar no .bashrc
            if ! grep -q "GIT_BRANCH_ALLOWED_PREFIXES" ~/.bashrc 2>/dev/null; then
                echo "" >> ~/.bashrc
                echo "# Git Branch Helper - Diretórios permitidos" >> ~/.bashrc
                echo "export GIT_BRANCH_ALLOWED_PREFIXES=\"$GIT_BRANCH_ALLOWED_PREFIXES\"" >> ~/.bashrc
            else
                # Atualizar linha existente
                sed -i.bak "s|export GIT_BRANCH_ALLOWED_PREFIXES=.*|export GIT_BRANCH_ALLOWED_PREFIXES=\"$GIT_BRANCH_ALLOWED_PREFIXES\"|" ~/.bashrc
            fi
            
            echo "✅ Diretório adicionado: $new_dir"
            echo "💡 Agora branches criadas neste diretório terão o prefixo '$GIT_BRANCH_USERNAME/'"
            echo "💡 Configuração salva em ~/.bashrc"
            ;;
            
        remove|rm)
            # Remover diretório
            if [ -z "$2" ]; then
                echo "❌ Uso: git_branch_config remove <diretório|índice>"
                return 1
            fi
            
            local target="$2"
            target="${target/#\~/$HOME}"
            
            # Se for número, pegar diretório pelo índice
            if [[ "$target" =~ ^[0-9]+$ ]]; then
                IFS=':' read -ra dirs <<< "$GIT_BRANCH_ALLOWED_PREFIXES"
                local index=$((target - 1))
                if [ $index -lt 0 ] || [ $index -ge ${#dirs[@]} ]; then
                    echo "❌ Índice inválido. Use 'git_branch_config list' para ver os índices."
                    return 1
                fi
                target="${dirs[$index]}"
            fi
            
            # Verificar se existe
            if [[ ":$GIT_BRANCH_ALLOWED_PREFIXES:" != *":$target:"* ]]; then
                echo "❌ O diretório '$target' não está na lista."
                return 1
            fi
            
            # Remover da lista
            local new_list=""
            IFS=':' read -ra dirs <<< "$GIT_BRANCH_ALLOWED_PREFIXES"
            for dir in "${dirs[@]}"; do
                if [ "$dir" != "$target" ]; then
                    if [ -z "$new_list" ]; then
                        new_list="$dir"
                    else
                        new_list="$new_list:$dir"
                    fi
                fi
            done
            
            export GIT_BRANCH_ALLOWED_PREFIXES="$new_list"
            
            # Atualizar .bashrc
            if grep -q "GIT_BRANCH_ALLOWED_PREFIXES" ~/.bashrc 2>/dev/null; then
                sed -i.bak "s|export GIT_BRANCH_ALLOWED_PREFIXES=.*|export GIT_BRANCH_ALLOWED_PREFIXES=\"$GIT_BRANCH_ALLOWED_PREFIXES\"|" ~/.bashrc
            fi
            
            echo "✅ Diretório removido: $target"
            ;;
            
        list|ls)
            # Listar diretórios
            echo "📁 Diretórios com prefixo '$GIT_BRANCH_USERNAME/':"
            echo ""
            
            if [ -z "$GIT_BRANCH_ALLOWED_PREFIXES" ]; then
                echo "  (nenhum diretório configurado)"
                echo ""
                echo "💡 Use 'git_branch_config add <diretório>' para adicionar"
            else
                local index=1
                IFS=':' read -ra dirs <<< "$GIT_BRANCH_ALLOWED_PREFIXES"
                for dir in "${dirs[@]}"; do
                    local display_dir="${dir/#$HOME/\~}"
                    if [ -d "$dir" ]; then
                        echo "  $index) $display_dir ✓"
                    else
                        echo "  $index) $display_dir ⚠️  (não existe)"
                    fi
                    ((index++))
                done
            fi
            echo ""
            ;;
            
        username|user)
            # Configurar username
            if [ -z "$2" ]; then
                echo "📝 Username atual: $GIT_BRANCH_USERNAME"
                echo ""
                echo "Para alterar:"
                echo "  git_branch_config username <novo-username>"
                return 0
            fi
            
            local new_username="$2"
            export GIT_BRANCH_USERNAME="$new_username"
            
            # Salvar no .bashrc
            if ! grep -q "GIT_BRANCH_USERNAME" ~/.bashrc 2>/dev/null; then
                echo "" >> ~/.bashrc
                echo "# Git Branch Helper - Username" >> ~/.bashrc
                echo "export GIT_BRANCH_USERNAME=\"$new_username\"" >> ~/.bashrc
            else
                sed -i.bak "s|export GIT_BRANCH_USERNAME=.*|export GIT_BRANCH_USERNAME=\"$new_username\"|" ~/.bashrc
            fi
            
            echo "✅ Username atualizado: $new_username"
            echo "💡 Configuração salva em ~/.bashrc"
            ;;
            
        reset)
            # Resetar configurações
            read -rp "⚠️  Isso irá resetar todas as configurações. Continuar? [y/N]: " confirm
            if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                echo "❌ Operação cancelada."
                return 0
            fi
            
            # Remover do .bashrc
            if [ -f ~/.bashrc ]; then
                sed -i.bak '/# Git Branch Helper/d; /GIT_BRANCH_USERNAME/d; /GIT_BRANCH_ALLOWED_PREFIXES/d' ~/.bashrc
            fi
            
            # Valores padrão
            export GIT_BRANCH_USERNAME="ribeiroevandro"
            export GIT_BRANCH_ALLOWED_PREFIXES="$HOME/workspace/gitlab:$HOME/workspace/github/buser"
            
            echo "✅ Configurações resetadas para os valores padrão"
            echo "   Username: $GIT_BRANCH_USERNAME"
            echo "   Diretórios padrão restaurados"
            echo "💡 Execute 'source ~/.bashrc' para recarregar"
            ;;
            
        show)
            # Mostrar configuração
            echo "⚙️  Configuração atual do Git Branch Helper:"
            echo ""
            echo "👤 Username: $GIT_BRANCH_USERNAME"
            echo ""
            echo "📁 Diretórios com prefixo:"
            if [ -z "$GIT_BRANCH_ALLOWED_PREFIXES" ]; then
                echo "   (nenhum)"
            else
                IFS=':' read -ra dirs <<< "$GIT_BRANCH_ALLOWED_PREFIXES"
                for dir in "${dirs[@]}"; do
                    local display_dir="${dir/#$HOME/\~}"
                    if [ -d "$dir" ]; then
                        echo "   ✓ $display_dir"
                    else
                        echo "   ⚠️  $display_dir (não existe)"
                    fi
                done
            fi
            echo ""
            ;;
            
        help|'')
            # Ajuda
            echo "🐚 Git Branch Helper - Configuração (Bash)"
            echo ""
            echo "Uso: git_branch_config <comando> [argumentos]"
            echo ""
            echo "Comandos:"
            echo "  add <dir>          Adicionar diretório aos prefixos"
            echo "  remove <dir|n>     Remover diretório (por caminho ou índice)"
            echo "  list               Listar diretórios configurados"
            echo "  username [nome]    Ver ou alterar username"
            echo "  show               Mostrar configuração atual"
            echo "  reset              Resetar para valores padrão"
            echo "  help               Mostrar esta ajuda"
            echo ""
            echo "Exemplos:"
            echo "  git_branch_config add ~/projetos/empresa"
            echo "  git_branch_config add /workspace/clientes"
            echo "  git_branch_config remove 1"
            echo "  git_branch_config username joaosilva"
            echo "  git_branch_config list"
            echo ""
            echo "💡 As configurações são salvas em ~/.bashrc"
            ;;
            
        *)
            echo "❌ Comando desconhecido: $command"
            echo "Use 'git_branch_config help' para ver os comandos disponíveis"
            return 1
            ;;
    esac
}

# Autocompletar para Bash
_git_branch_config_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "add remove rm list ls username user show reset help" -- "$cur"))
    elif [[ $COMP_CWORD -eq 2 ]]; then
        case "$prev" in
            add)
                COMPREPLY=($(compgen -d -- "$cur"))
                ;;
            remove|rm)
                # Sugerir índices
                if [ -n "$GIT_BRANCH_ALLOWED_PREFIXES" ]; then
                    IFS=':' read -ra dirs <<< "$GIT_BRANCH_ALLOWED_PREFIXES"
                    COMPREPLY=($(compgen -W "$(seq 1 ${#dirs[@]})" -- "$cur"))
                fi
                ;;
        esac
    fi
}

complete -F _git_branch_config_completions git_branch_config