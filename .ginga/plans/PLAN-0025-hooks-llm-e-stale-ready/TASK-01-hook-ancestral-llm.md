---
type: task
mode: padrao
goal: "o hook reference-transaction recusa update de refs/heads/main com ancestral agente LLM (claude -p, codex exec, opencode run, pi) mesmo com MERGE_GATE=1; ginga hooks install atualiza hook ginga-managed no lugar"
title: hook reference-transaction com guarda de ancestral LLM
plan: PLAN-0025-hooks-llm-e-stale-ready
repo: ginga
depends_on: []
tier: free
pinga_task: T101
touch: [tests/fixtures/hooks_llm/git/reference-transaction, src/hooks/index.ts, tests/hooks_llm_guard.test.ts, tasks/T101/PLAN.md]
done_when: "bun test tests/hooks_llm_guard.test.ts"
tests_frozen: [tests/hooks_llm_guard.test.ts]
---
## Fazer
- Criar `tests/fixtures/hooks_llm/git/reference-transaction` (sh POSIX, executável, primeira linhas `#!/bin/sh` e `# ginga-managed hook: reference-transaction`). Mantém o comportamento atual: lê stdin (`old new ref`), update de `refs/heads/main` sem `MERGE_GATE=1` → `BLOQUEADO ...` exit 1; encadeia `reference-transaction.ginga-prev` (via `$(dirname "$0")`) se executável.
- NOVO: se algum update é de `refs/heads/main` (mesmo com `MERGE_GATE=1`) e algum ancestral do processo é agente LLM → stderr `BLOQUEADO (ginga reference-transaction): ancestral é agente LLM`, exit 1. Updates de outras refs (ex. `refs/heads/plan/0025`) nunca são barrados por isso.
- Ancestral: subir de `$PPID` por `/proc/<pid>/status` (`PPid:`) até 1. Para cada pid, ler `/proc/<pid>/cmdline` (separado por NUL, ex. `tr '\0' '\n'`): `b0` = basename do argv[0]; se `b0` = `timeout`, pular as opções (`-*` ou números) e usar o comando seguinte como `b0` e o argumento seguinte como `a1`. Agente LLM se `b0:a1` casar `*opencode*:run`, `pi:*`, `claude:-p` ou `codex:exec` (mesmo `case` do `.ginga/bin/merge-gate.sh` linhas 9-12).
- Em `src/hooks/index.ts` `installHook`: se o hook alvo existente é diferente da fonte mas contém a linha `# ginga-managed hook:`, sobrescrever no lugar (conteúdo da fonte, 0755) SEM renomear para `.ginga-prev` (um `.ginga-prev` já existente fica intacto); retorna `installed`. O hook de terceiros segue encadeado como hoje.
## Não fazer
- Não tocar `tests/hooks_install.test.ts`, `tests/doctor*.test.ts`, `tests/fixtures/hooks/` (golden antigo), nem a saída de `hooks check`.
