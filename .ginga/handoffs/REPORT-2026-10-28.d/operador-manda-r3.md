# Report — lane manda, rodada 3 (2026-10-29, operador opencode/qwen3.8-flash)

Escopo: só o repo `manda`, achados do judge do PLAN-0009 (gate exit 12, "sem receipt done: T151").

## Fatos

- **TASK-05 (T151)** — encerrada.
  - Queue (`pinga queue --json --root manda-plan-0009`): T151 `state: done`, receipt `pass` seq **672**.
  - Commits em `plan/0009`: `a742d72` test(T151): RED (pré-existente, minha rodada herdou); `6c81bb2` feat(T151): provider rg+git (rg.ts 244 linhas + port.ts dispatch rg).
  - `bun test tests/context_rg.test.ts tests/context_port.test.ts` = **21 pass / 0 fail**.
  - Origem: a tentativa despachada pela r2 às 08:40 ficou órfã (bash pai morto com a pane da r2), completou no worktree às 08:48 (done_when exit 0); o verify (seq 672) e o commit feat foram selados pela lane claude `lane-manda-20261029-0850-r1`, não por mim.
  - Backlog: marcado `[x]`.
- **TASK-07 (AC-03)** — encerrada pela lane paralela, confirmada por mim às 09:0x.
  - A lane r1@0850 (claude) materializou a passada RED: commit `442f8cc` test(T152,T153): RED com `tests/e2e/no_gira.test.ts`, `tests/e2e/stubs/pi`, `tests/runtime_pi_text.test.ts`, `tasks/T152/PLAN.md`, `tasks/T153/PLAN.md`.
  - TASK nova `TASK-09-pi-resulttext.md` (T152): adapter pi devolve texto da última mensagem do assistente em `resultText` (pré-requisito do e2e); `da0694d` feat(T152); `5c8225e` test(T153) ajusta o stub pi (contador por linha de comando).
  - Queue: **T152 done/pass seq 682, T153 done/pass seq 683** (`pinga queue --json --root manda-plan-0009`).
  - `bun test tests/e2e/no_gira.test.ts` = **3 pass / 0 fail**; worktree limpo.
  - Backlog: marcado `[x]` (pela lane r1@0850). r3 confirmou, sem dispatch duplicado (dois `dispatch-task.sh` no mesmo worktree se destroem via snapshot/restore).
- **Suite completa**: 232 pass / 4 fail registrada pela lane r1@0850 — as 4 falhas são o guarda T101 (judge/pipeline/lane esperam exit 2, recebem 30 dentro da árvore do agente; já conhecido, verificado detached pela r2 às 08:35).
- **ready**: `.ginga/plans/PLAN-0009-contexto-sem-gira/ready/manda.json` = `{"branch":"plan/0009"}` — todas as TASKs do item (T150, T151, T152, T153) em `done/pass` na fila. Pronto para judge + gate da lane.
- Main do repo `manda` sem mudanças (não tocada).
