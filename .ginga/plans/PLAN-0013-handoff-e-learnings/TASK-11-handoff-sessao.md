---
type: task
mode: mvp
goal: "Sem <PLAN>, ginga handoff --trigger idle infere o PLAN ou cai em git + pendências, aceita --notes, grava as 7 seções, filtra segredos, fica em até 4k tokens e repete os bytes para a mesma entrada"
title: ginga handoff em modo sessão
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T150
depends_on: [TASK-10-handoff-politica]
tier: free
touch: [src/handoff.ts, src/handoff/redact.ts, src/verbs/handoff.ts, tests/handoff_session.test.ts, tests/fixtures/handoff-session/]
done_when: "bun test tests/handoff_session.test.ts"
tests_frozen: [tests/handoff_session.test.ts, tests/fixtures/handoff-session/]
---
## Fazer
- Flags do doc 11 §2: `--trigger idle|context|manual|boundary`, `--runtime`, `--from-session`, `--transcript`, `--notes <arquivo>|-`, `--json`. PLAN inferido pela branch `plan/NNNN` da worktree, pelo `state.db` ou pelo `log.md` mais recente; sem PLAN: `git status` + pendências do `index.md` + últimos eventos.
- 7 seções na ordem do doc 11 §2 (a 6, "Do chat", vem do `--notes`); truncar por prioridade de trás para frente até ~4k tokens (chars/4).
## Interface
- `redact(text: string): string` (chaves/tokens comuns e linhas de `.env` → `[REDACTED]`); `buildHandoff` ganha `trigger`, `runtime`, `from_session`, `transcript`, `parent_handoff`, `depth`, `notes` (frontmatter). Teste: fixture sem PLAN → seções 4/5 do git; notes com `sk-...` → `[REDACTED]`; mesma entrada → mesmos bytes; entrada grande → ≤ 16000 chars.
## Não fazer
- Não copiar o transcript para o handoff (só o caminho).
## Contexto
- Doc 11 §2 (proposta TASK-09 de lá).
