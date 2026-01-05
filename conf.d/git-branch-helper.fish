# Configurações do Git Branch Helper para Fish Shell

# Username padrão (pode ser sobrescrito pelo usuário em config.fish)
if not set -q GIT_BRANCH_USERNAME
    set -gx GIT_BRANCH_USERNAME ribeiroevandro
end

# Diretórios onde o prefixo username será aplicado
# Formato: separados por espaço
if not set -q GIT_BRANCH_ALLOWED_PREFIXES
    set -gx GIT_BRANCH_ALLOWED_PREFIXES \
        "$HOME/workspace"
end

# Mensagem de boas-vindas (apenas na primeira vez)
if not set -q __git_branch_helper_loaded
    set -U __git_branch_helper_loaded 1
    echo "🐚 Git Branch Helper carregado! Use 'create_branch --help' ou 'create_branch' para começar."
end

