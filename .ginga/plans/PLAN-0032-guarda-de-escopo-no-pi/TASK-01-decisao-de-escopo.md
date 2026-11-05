---
type: task
mode: padrao
goal: "decideToolCall permite ou bloqueia edit/write conforme touch e tests_frozen, e recusa os padrões de bash de risco, com motivo legível"
title: decideToolCall
plan: PLAN-0032-guarda-de-escopo-no-pi
repo: manda
depends_on: []
tier: free
touch: [src/runtime/scope_guard.ts, tests/scope_guard.test.ts]
done_when: "bun test tests/scope_guard.test.ts"
pinga_task: T162
tests_frozen: [tests/scope_guard.test.ts]
---
## Fazer
- `edit`/`write` com `input.path` dentro de `touch` → `allow`; fora → `outside_touch`; dentro de `frozen` → `frozen` (mesmo que também esteja em `touch`).
- `bash` com `git add -A`, `git add .` na raiz, `--no-verify` ou `push --force`/`-f` → `bash_refused`. Outros comandos → `allow`.
- Outras tools (`read` etc.) → `allow`.
- `reason` diz o que fazer: "`<path>` está fora do touch desta TASK (`<touch>`). Se precisa dele, responda `BLOCKED: touch precisa incluir <path>`".
## Interface
- `decideToolCall`, `Scope`, `ToolCall`, `Decision` (PLAN.md). Teste: tabela de ≥ 15 chamadas.
## Não fazer
- Sem I/O de disco aqui (a resolução de caminho é a TASK-02). Sem rede.
## Contexto
- SPEC-0002 (`bashRefusal`); `p-inga/src/guards.ts` (mesma ideia, só que depois).
