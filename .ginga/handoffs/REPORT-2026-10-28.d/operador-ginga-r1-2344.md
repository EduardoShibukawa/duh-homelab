# operador ginga — lane-ginga-20261028-2344-r1

Worktree `ginga-plan-0025` (branch `plan/0025`, base main 5a0a231). PLAN-0025-hooks-llm-e-stale-ready.

| TASK | pinga | receipt | RED (prove-red) | executor |
|---|---|---|---|---|
| TASK-01 hook ancestral LLM | T101 | pass (done) | pass, base 80de423 | opencode/qwen3.8-flash, 1 tentativa, US$0,035 |
| TASK-02 vigia stale_ready/ready_writer | T102 | pass (done) | pass, base 3990537 | qwen3.8-flash, 1 tentativa, US$0,022 (+ ajuste do operador em src/watch/index.ts e rules.ts, ver decisoes.md) |
| TASK-03 `ginga ready write` | T103 | pass (done) | pass, base d253a90 | qwen3.8-flash, 1 tentativa, US$0,00 |

- `bun test` na plan/0025: 296 pass, 0 fail.
- `ready/ginga.json` gravado em PLAN-0025 (branch plan/0025, by/at via `ginga ready write`).
- Hooks: fonte `.ginga/hooks/git/reference-transaction` atualizada; `ginga hooks install` nos 3 repos; `hooks check` exit 0; teste: commit na main com MERGE_GATE=1 sob `claude -p` → BLOQUEADO; commit em branch → permitido.
- Backlog: marcados follow-up 10 e PRIORIDADE hooks. Restam `ginga install` (link ~/.local/bin) e limpeza automática de worktrees.
