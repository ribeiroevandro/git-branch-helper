#!/usr/bin/env bash

# Script de Setup Rápido do Git Branch Helper
# Cria toda a estrutura do projeto

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

echo ""
print_info "🚀 Git Branch Helper - Setup do Projeto"
echo ""

# Verificar se já existe
if [ -d "git-branch-helper" ]; then
    print_error "❌ O diretório 'git-branch-helper' já existe!"
    read -p "Deseja sobrescrever? [y/N]: " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_warning "⚠️  Setup cancelado."
        exit 0
    fi
    rm -rf git-branch-helper
fi

# Criar estrutura
print_info "📁 Criando estrutura de diretórios..."

mkdir -p git-branch-helper/{fish/{functions,completions,conf.d},bash,zsh,bin,docs,scripts}

cd git-branch-helper

# Criar arquivos principais
print_info "📝 Criando arquivos base..."

touch fish/functions/create_branch.fish
touch fish/completions/create_branch.fish
touch fish/conf.d/git-branch-helper.fish
touch fish/README.md

touch bash/create_branch.bash
touch bash/README.md

touch zsh/create_branch.zsh
touch zsh/README.md

touch bin/git-create-branch
chmod +x bin/git-create-branch

touch docs/{CONFIGURATION,EXAMPLES,TROUBLESHOOTING}.md

touch README.md
touch CHANGELOG.md
touch CONTRIBUTING.md
touch LICENSE
touch install.sh
chmod +x install.sh
touch fisher_file
touch .gitignore

# Criar .gitignore
print_info "🚫 Criando .gitignore..."
cat > .gitignore << 'EOF'
# Fish Shell
*.swp
*~

# IDEs
.idea/
.vscode/
*.iml

# OS
.DS_Store
Thumbs.db

# Test files
test/
*.test.fish
*.test.bash
*.test.zsh

# Build
dist/
build/

# Logs
*.log

# Temporary
tmp/
temp/
EOF

# Criar LICENSE básica
print_info "⚖️  Criando LICENSE..."
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2026 Evandro Ribeiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Criar fisher_file
print_info "🎣 Criando fisher_file..."
cat > fisher_file << 'EOF'
fish/functions/create_branch.fish
fish/completions/create_branch.fish
fish/conf.d/git-branch-helper.fish
EOF

# Criar README básico
print_info "📖 Criando README básico..."
cat > README.md << 'EOF'
# 🐚 Git Branch Helper

> Plugin universal para criar branches Git com padrão personalizado

**Status:** 🚧 Em construção

## 📦 Instalação

Em breve...

## 🚀 Uso

```bash
create_branch feat nova feature
```

## 📝 TODO

- [ ] Implementar versão Fish
- [ ] Implementar versão Bash
- [ ] Implementar versão Zsh
- [ ] Implementar versão POSIX
- [ ] Criar instalador universal
- [ ] Escrever documentação completa
- [ ] Adicionar testes
- [ ] Publicar no GitHub

## 👤 Autor

Evandro Ribeiro

## 📄 Licença

MIT
EOF

# Inicializar Git
print_info "🔧 Inicializando repositório Git..."
git init
git add .
git commit -m "chore: initial project structure

- Created directory structure for multi-shell support
- Added Fish, Bash, Zsh, and POSIX versions
- Created documentation structure
- Added LICENSE, .gitignore, and fisher_file" || print_warning "⚠️  Git já inicializado ou erro no commit"

# Criar script helper para desenvolvimento
print_info "🔨 Criando scripts auxiliares..."
cat > scripts/test-all.sh << 'EOF'
#!/usr/bin/env bash
# Script para testar em todos os shells

set -e

echo "🧪 Testando Fish Shell..."
fish -c "set -p fish_function_path $PWD/fish/functions; create_branch feat test-fish"

echo "🧪 Testando Bash..."
bash -c "source $PWD/bash/create_branch.bash && create_branch feat test-bash"

echo "🧪 Testando Zsh..."
zsh -c "source $PWD/zsh/create_branch.zsh && create_branch feat test-zsh"

echo "🧪 Testando Standalone..."
$PWD/bin/git-create-branch feat test-standalone

echo "✅ Todos os testes passaram!"
EOF
chmod +x scripts/test-all.sh

# Sumário
echo ""
print_success "✅ Estrutura do projeto criada com sucesso!"
echo ""
print_info "📊 Sumário:"
echo "   - Diretórios criados: fish/, bash/, zsh/, bin/, docs/"
echo "   - Arquivos base criados"
echo "   - Git inicializado"
echo "   - Scripts auxiliares adicionados"
echo ""
print_info "📋 Próximos passos:"
echo ""
echo "1. Copie o conteúdo dos scripts para os arquivos correspondentes"
echo "2. Edite README.md com informações completas"
echo "3. Adicione código nos arquivos .fish, .bash, .zsh"
echo "4. Teste cada implementação"
echo "5. Configure o remote do GitHub:"
echo "   $ git remote add origin git@github.com:seu-usuario/git-branch-helper.git"
echo "6. Faça o primeiro push:"
echo "   $ git push -u origin main"
echo ""
print_success "🎉 Projeto pronto para desenvolvimento!"
echo ""
print_info "💡 Dica: Use o script scripts/test-all.sh para testar todas as versões"
echo ""