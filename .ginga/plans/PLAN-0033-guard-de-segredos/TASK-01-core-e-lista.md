---
type: task
mode: padrao
goal: "checkCall barra leitura de segredo (caminho, shell, formato de chave) e redact troca chave por [REDACTED:regra], tudo a partir de deny.json, sem I/O além de stat/realpath"
title: Casador e lista de bloqueio única
plan: PLAN-0033-guard-de-segredos
repo: ginga
pinga_task: T300
depends_on: []
tier: free
touch: [src/guard/core.ts, src/guard/deny.json, tests/guard_core.test.ts, tests/fixtures/guard/cases.json]
done_when: "bun test tests/guard_core.test.ts"
tests_frozen: [tests/guard_core.test.ts, tests/fixtures/guard/cases.json]
---
## Fazer
- `src/guard/deny.json` (dados, versão 1): `home_dirs`, `home_files`, `abs_globs`, `basename_any` (`.env*`/`.envrc`), `basename_outside_cwd` (`auth.json`, `credentials`, `*.pem`, `*.key`, `id_*`, `*.p12`), `basename_allow` (`.env.example|sample|template|dist`), `shell` (despejo de ambiente) e `content` (formatos de chave). Lista completa e justificativa: pesquisa §3.
- `src/guard/core.ts`: `checkCall({tool,input,cwd,home}, deny)` e `redact(text, deny, envValues)`. Dirigido pelas **chaves** do `input` (caminho: `path|filePath|file_path|file|files|paths|dir|directory|workdir|cwd`; comando: `command|cmd|script|code`; texto: `content|newString|oldString|text|patch|body`), não pelo nome da tool (o opencode 2.2.2 chama o shell de `shell`, o Pi de `bash`, o Hermes de `terminal`).
- Caminho: expandir `~`/`$HOME`/`${HOME}`, resolver contra `cwd`, testar o caminho e o `realpath` (symlink). Shell: expandir `$HOME`, regras de despejo de ambiente, e checar cada token que pareça caminho com a mesma função de caminho.
## Interface
- `type Verdict = {block:false} | {block:true, rule:string, reason:string}`. `reason` é texto fixo por regra e **nunca** inclui o trecho que casou.
- Protótipo validado: [ref/ginga/src/guard/core.ts](../ref/ginga/src/guard/core.ts) e `deny.json`.
## Não fazer
- Não ler o conteúdo de nenhum arquivo, não chamar rede, não depender de `process.env` (o ambiente entra por parâmetro).
- Não tocar tests_frozen. Os casos usam HOME e `.env` sintéticos em `mkdtemp`; chaves falsas são montadas em tempo de teste.
## Contexto
- `cases.json` é a tabela única que os testes dos três runtimes reaproveitam. Lista inspirada no `bashRefusal` do pi-harness (`claude-plugin/hooks/policy.ts`).
