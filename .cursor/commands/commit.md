## Objetivo

Este comando deve **analisar as alterações do Git** e **realizar commits** seguindo **boas práticas** e **respeitando estritamente** as convenções em `.cursor/rules/commit-message-conventions.mdc` (Conventional Commits).

## Regras obrigatórias (não negociar)

- **Formato da mensagem (primeira linha)**: `<type>[optional scope]: <description>`
- **Tipos válidos**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`
- **1 tarefa por commit**: não misturar mudanças de naturezas diferentes no mesmo commit.
- **Descrição**: curta, no imperativo e tempo presente (ex.: “add”, “fix”, “refactor”).
- **Breaking change**: se for breaking, usar `!` após `type`/`scope` (ex.: `feat(auth)!: ...`).

## Fluxo de execução

### 1) Inspecionar o estado atual

Execute e use a saída para decidir o plano:

- `git status --porcelain`
- `git diff` (não staged)
- `git diff --staged` (staged)

### 2) Identificar “unidades de mudança” (por intenção)

Agrupe as alterações em commits pequenos e coesos. Exemplos de separação recomendada:

- **Docs vs código**: `docs:` separado de `feat:`/`fix:`.
- **Refactor vs comportamento**: `refactor:` separado de `fix:`/`feat:`.
- **Formatação**: `style:` separado de qualquer mudança funcional.
- **CI/build**: `ci:`/`chore:` separados de mudanças de produto.

Se uma mesma alteração tiver mistura de intenções no mesmo arquivo, prefira **separar por arquivo** quando possível; se não for possível sem comandos interativos, faça o melhor agrupamento possível sem comprometer a regra “1 tarefa por commit”.

### 3) Preparar o stage (sem comandos interativos)

Se não houver nada staged, selecione o conjunto mínimo de arquivos por commit usando:

- `git add <arquivo1> <arquivo2> ...`

Evite `git add -p`/`git commit -p` (interativos).

### 4) Definir mensagem do commit (type, scope, descrição)

Para cada grupo:

- **type**: escolha um dos tipos válidos conforme a intenção principal.
- **scope (opcional)**: use quando ajudar a localizar a área afetada (ex.: `install`, `fish`, `bash`, `zsh`, `readme`, `cli`).
- **description**: curta e imperativa; sem ponto final; sem capitalização desnecessária.
- **breaking**: se a mudança quebrar compatibilidade (ex.: mudança de interface/uso), use `!`.

### 5) Commitar e validar

Para cada commit:

- Confirme o conteúdo: `git diff --staged`
- Crie o commit: `git commit -m "<type>(<scope>): <description>"`
  - Se não houver scope, use: `git commit -m "<type>: <description>"`
- Garanta que `git status --porcelain` reflita apenas o que falta para os próximos commits.

### 6) Resultado esperado

Ao final:

- Não deve haver mudanças staged indevidas.
- Os commits devem estar **granulares**, **coerentes** e com mensagens **100% compatíveis** com `.cursor/rules/commit-message-conventions.mdc`.

## Checklist rápido antes de finalizar

- A mensagem está no formato `<type>[optional scope]: <description>`?
- O `type` é um dos permitidos?
- Há apenas **uma intenção** no commit?
- A descrição está em modo imperativo e no presente?
- Se for breaking, usei `!`?

