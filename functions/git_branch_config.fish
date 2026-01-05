function git_branch_config -d "Configurar Git Branch Helper"
    set -l command $argv[1]
    
    switch $command
        case add
            # Adicionar diretório aos prefixos permitidos
            if test (count $argv) -lt 2
                echo "❌ Uso: git_branch_config add <diretório>"
                return 1
            end
            
            set -l new_dir $argv[2]
            
            # Expandir ~ para $HOME
            set new_dir (string replace -r '^~' $HOME $new_dir)
            
            # Verificar se diretório existe
            if not test -d $new_dir
                echo "⚠️  Aviso: O diretório '$new_dir' não existe."
                read -P "Deseja adicionar mesmo assim? [Y/n]: " confirm
                if test "$confirm" = n -o "$confirm" = N
                    echo "❌ Operação cancelada."
                    return 0
                end
            end
            
            # Verificar se já existe
            if contains $new_dir $GIT_BRANCH_ALLOWED_PREFIXES
                echo "⚠️  O diretório '$new_dir' já está na lista."
                return 0
            end
            
            # Adicionar à lista universal (persiste entre sessões)
            set -U GIT_BRANCH_ALLOWED_PREFIXES $GIT_BRANCH_ALLOWED_PREFIXES $new_dir
            echo "✅ Diretório adicionado: $new_dir"
            echo "💡 Agora branches criadas neste diretório terão o prefixo '$GIT_BRANCH_USERNAME/'"
            
        case remove rm
            # Remover diretório dos prefixos
            if test (count $argv) -lt 2
                echo "❌ Uso: git_branch_config remove <diretório|índice>"
                return 1
            end
            
            set -l target $argv[2]
            
            # Expandir ~ para $HOME
            set target (string replace -r '^~' $HOME $target)
            
            # Verificar se é um número (índice)
            if string match -qr '^\d+$' $target
                set -l index $target
                if test $index -lt 1 -o $index -gt (count $GIT_BRANCH_ALLOWED_PREFIXES)
                    echo "❌ Índice inválido. Use 'git_branch_config list' para ver os índices."
                    return 1
                end
                set target $GIT_BRANCH_ALLOWED_PREFIXES[$index]
            end
            
            # Verificar se existe na lista
            if not contains $target $GIT_BRANCH_ALLOWED_PREFIXES
                echo "❌ O diretório '$target' não está na lista."
                return 1
            end
            
            # Remover da lista
            set -l new_list
            for dir in $GIT_BRANCH_ALLOWED_PREFIXES
                if test "$dir" != "$target"
                    set new_list $new_list $dir
                end
            end
            
            set -U GIT_BRANCH_ALLOWED_PREFIXES $new_list
            echo "✅ Diretório removido: $target"
            
        case list ls
            # Listar diretórios configurados
            echo "📁 Diretórios com prefixo '$GIT_BRANCH_USERNAME/':"
            echo ""
            
            if test (count $GIT_BRANCH_ALLOWED_PREFIXES) -eq 0
                echo "  (nenhum diretório configurado)"
                echo ""
                echo "💡 Use 'git_branch_config add <diretório>' para adicionar"
            else
                set -l index 1
                for dir in $GIT_BRANCH_ALLOWED_PREFIXES
                    set -l display_dir (string replace $HOME '~' $dir)
                    if test -d $dir
                        echo "  $index) $display_dir ✓"
                    else
                        echo "  $index) $display_dir ⚠️  (não existe)"
                    end
                    set index (math $index + 1)
                end
            end
            echo ""
            
        case username user
            # Configurar username
            if test (count $argv) -lt 2
                echo "📝 Username atual: $GIT_BRANCH_USERNAME"
                echo ""
                echo "Para alterar:"
                echo "  git_branch_config username <novo-username>"
                return 0
            end
            
            set -l new_username $argv[2]
            set -U GIT_BRANCH_USERNAME $new_username
            echo "✅ Username atualizado: $new_username"
            echo "💡 Agora suas branches terão o prefixo '$new_username/' nos diretórios configurados"
            
        case reset
            # Resetar para valores padrão
            read -P "⚠️  Isso irá resetar todas as configurações. Continuar? [y/N]: " confirm
            if test "$confirm" != y -a "$confirm" != Y
                echo "❌ Operação cancelada."
                return 0
            end
            
            set -e GIT_BRANCH_USERNAME
            set -e GIT_BRANCH_ALLOWED_PREFIXES
            
            # Recarregar valores padrão
            source ~/.config/fish/conf.d/git-branch-helper.fish
            
            echo "✅ Configurações resetadas para os valores padrão"
            echo "   Username: $GIT_BRANCH_USERNAME"
            echo "   Diretórios: "
            for dir in $GIT_BRANCH_ALLOWED_PREFIXES
                echo "     - "(string replace $HOME '~' $dir)
            end
            
        case show
            # Mostrar configuração atual
            echo "⚙️  Configuração atual do Git Branch Helper:"
            echo ""
            echo "👤 Username: $GIT_BRANCH_USERNAME"
            echo ""
            echo "📁 Diretórios com prefixo:"
            if test (count $GIT_BRANCH_ALLOWED_PREFIXES) -eq 0
                echo "   (nenhum)"
            else
                for dir in $GIT_BRANCH_ALLOWED_PREFIXES
                    set -l display_dir (string replace $HOME '~' $dir)
                    if test -d $dir
                        echo "   ✓ $display_dir"
                    else
                        echo "   ⚠️  $display_dir (não existe)"
                    end
                end
            end
            echo ""
            
        case help ''
            # Mostrar ajuda
            echo "🐚 Git Branch Helper - Configuração"
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
            echo "💡 Dica: Use tab para autocompletar comandos"
            
        case '*'
            echo "❌ Comando desconhecido: $command"
            echo "Use 'git_branch_config help' para ver os comandos disponíveis"
            return 1
    end
end


