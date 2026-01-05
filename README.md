# 🐚 Git Branch Helper

> Plugin universal para criar branches Git com padrão personalizado e nomenclatura consistente.

**Compatível com:** Fish Shell • Zsh • Bash • POSIX Shell

[![Fish Shell](https://img.shields.io/badge/fish-v3.0+-blue.svg)](https://fishshell.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/github/v/tag/ribeiroevandro/git-branch-helper)](https://github.com/ribeiroevandro/git-branch-helper/tags)

---

## ✨ Features

- ✅ **Multi-shell**: Funciona em Fish, Zsh, Bash e qualquer shell POSIX
- 🎯 **Nomenclatura consistente**: Padrões configuráveis
- 🌍 **Acentos automáticos**: Remove automaticamente
- 🚀 **Modo interativo ou CLI**: Flexibilidade total
- ⚡ **Auto-confirmação**: Flag `-y` para scripts
- 🔍 **Validações inteligentes**: Verifica Git e branches existentes
- 📦 **Fácil instalação**: Instalador automático

---

## 🚀 Instalação Rápida

### Instalador Universal (Recomendado)

```bash
curl -sL https://raw.githubusercontent.com/ribeiroevandro/git-branch-helper/main/install.sh | bash
```

Se você quiser rodar **sem interação**, pode definir a opção via variável de ambiente:

```bash
GIT_BRANCH_HELPER_INSTALL_CHOICE=1 curl -sL https://raw.githubusercontent.com/ribeiroevandro/git-branch-helper/main/install.sh | bash
```

Se você estiver executando via `| bash` e quiser forçar o shell do plugin (ex.: Fish), use:

```bash
GIT_BRANCH_HELPER_SHELL=fish GIT_BRANCH_HELPER_INSTALL_CHOICE=1 \
  curl -sL https://raw.githubusercontent.com/ribeiroevandro/git-branch-helper/main/install.sh | bash
```

### Fish Shell (com Fisher)

```fish
fisher install ribeiroevandro/git-branch-helper
```

### Zsh

```zsh
# Download e source
curl -sL https://raw.githubusercontent.com/ribeiroevandro/git-branch-helper/main/zsh/create_branch.zsh \
  -o ~/.zsh/git-branch-helper.zsh

echo "source ~/.zsh/git-branch-helper.zsh" >> ~/.zshrc
```

### Bash

```bash
# Download e source
curl -sL https://raw.githubusercontent.com/ribeiroevandro/git-branch-helper/main/bash/create_branch.bash \
  -o ~/.bash/git-branch-helper.bash

echo "source ~/.bash/git-branch-helper.bash" >> ~/.bashrc
```

### Script Standalone (Universal)

```bash
# Instalar globalmente (requer sudo)
sudo curl -sL https://raw.githubusercontent.com/ribeiroevandro/git-branch-helper/main/bin/git-create-branch \
  -o /usr/local/bin/git-create-branch
sudo chmod +x /usr/local/bin/git-create-branch

# Ou instalar localmente
mkdir -p ~/.local/bin
curl -sL https://raw.githubusercontent.com/ribeiroevandro/git-branch-helper/main/bin/git-create-branch \
  -o ~/.local/bin/git-create-branch
chmod +x ~/.local/bin/git-create-branch
```

---

## 📖 Uso

### Modo Interativo

```bash
create_branch
# ou
git-create-branch
```

### Com Argumentos

```bash
create_branch feat nova funcionalidade de login
create_branch fix corrigir bug no checkout
create_branch 1 implementar api de pagamento  # Usando números
```

### Auto-confirmação

```bash
create_branch -y feat implementar oauth
git-create-branch --yes fix resolver conflito
```

---

## 📋 Tipos de Branch

| Tipo     | Número | Descrição                |
|----------|--------|--------------------------|
| feat     | 1      | Nova funcionalidade      |
| fix      | 2      | Correção de bug          |
| chore    | 3      | Tarefas de manutenção    |
| docs     | 4      | Documentação             |
| style    | 5      | Formatação/estilo        |
| refactor | 6      | Refatoração              |
| test     | 7      | Testes                   |

---

## ⚙️ Configuração

### Configuração Rápida (Recomendado)

Use a função `git_branch_config` para gerenciar suas configurações de forma fácil:

```bash
# Configurar seu username
git_branch_config username seu-username

# Adicionar diretórios onde branches terão o prefixo username/
git_branch_config add ~/workspace/gitlab
git_branch_config add ~/projetos/empresa

# Listar diretórios configurados
git_branch_config list

# Ver configuração completa
git_branch_config show

# Ver todos os comandos
git_branch_config help
```

### Configuração Manual (Alternativa)

**Fish Shell:**
```fish
# ~/.config/fish/config.fish
set -gx GIT_BRANCH_USERNAME "seu-username"
set -gx GIT_BRANCH_ALLOWED_PREFIXES "$HOME/workspace/gitlab" "$HOME/workspace/github/company"
```

**Bash/Zsh:**
```bash
# ~/.bashrc ou ~/.zshrc
export GIT_BRANCH_USERNAME="seu-username"
export GIT_BRANCH_ALLOWED_PREFIXES="$HOME/workspace/gitlab:$HOME/workspace/github/company"
```

📖 **[Guia completo de configuração](docs/CONFIGURATION.md)**

---

## 💡 Exemplos

### Criação Básica

```bash
$ create_branch feat autenticação oauth
🎯 Branch que será criada:
   feat/autenticacao-oauth
✅ Criar esta branch? [Y/n]:
```

### Com Acentos (Removidos Automaticamente)

```bash
$ create_branch fix correção de migração
🎯 Branch que será criada:
   fix/correcao-de-migracao
```

### Em Diretório Autorizado (Adiciona Username)

```bash
$ cd ~/workspace/gitlab/meu-projeto
$ create_branch feat nova api
🎯 Branch que será criada:
   ribeiroevandro/feat-nova-api
```

### Usando Números

```bash
$ create_branch 2 resolver bug crítico
🎯 Branch que será criada:
   fix/resolver-bug-critico
```

---

## 📂 Estrutura do Projeto

```
git-branch-helper/
├── fish/                    # Plugin Fish Shell
│   ├── functions/
│   ├── completions/
│   └── conf.d/
├── bash/                    # Plugin Bash
│   └── create_branch.bash
├── zsh/                     # Plugin Zsh
│   └── create_branch.zsh
├── bin/                     # Script standalone
│   └── git-create-branch
├── install.sh              # Instalador universal
├── README.md
└── LICENSE
```

---

## 🔧 Desenvolvimento

### Clonar Repositório

```bash
git clone https://github.com/ribeiroevandro/git-branch-helper.git
cd git-branch-helper
```

### Testar Localmente

**Fish:**
```fish
set -p fish_function_path $PWD/fish/functions
create_branch
```

**Bash/Zsh:**
```bash
source bash/create_branch.bash  # ou zsh/create_branch.zsh
create_branch
```

**Standalone:**
```bash
./bin/git-create-branch --help
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch (`create_branch feat sua-feature`)
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

---

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

## 👤 Autor

**Evandro Ribeiro**

- GitHub: [@ribeiroevandro](https://github.com/ribeiroevandro)

---

## ⭐ Mostre seu apoio

Se este projeto te ajudou, dê uma ⭐️!

---

## 📝 Changelog

### v1.0.0 (2026-01-04)
- ✨ Suporte multi-shell (Fish, Zsh, Bash, POSIX)
- 🎯 Nomenclatura padronizada e configurável
- 🌍 Remoção automática de acentos
- ⚡ Modo interativo e CLI
- 📦 Instalador universal