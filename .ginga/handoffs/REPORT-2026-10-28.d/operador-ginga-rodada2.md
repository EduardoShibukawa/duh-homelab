# REPORT — operador ginga, rodada 2 (2026-10-28)

Fatos verificáveis (fonte: `pinga queue --json`, `pinga ledger verify`, `bun test`).

## PLAN-0010-tick-serve-notifier (worktree `ginga-plan-0010`, branch `plan/0010`, head 265d199)

- T19: receipt `pass` (claim baseline + `pinga verify`, sum. "T19 pass: done_when exit 0")
- T20: receipt `pass` (seq 435)
- T21: receipt `pass` (seq 441)
- T22: receipt `pass` (seq 442)
- T23: receipt `pass` (seq 444) — ginga `src/notify/port.ts` devolve thread_id; `routePending` ingere `$GINGA_EVENTS` antes do router e abre o db pelo root (`resolveStateDbPath`)
- fila ginga-plan-0010: done 22 / blocked 0 / open 0
- `bun test` ginga-plan-0010 (6 testes do PLAN): 47 pass / 0 fail
- TASK-06 (achado TASK-06/AC-03 do judge), **repo p-inga**, worktree `p-inga-plan-0010`, branch `plan/0010`:
  - T23 (p-inga): RED commits e6707c7 + c729274 (`pinga prove-red` pass 2×); implementação commit 392abf9
  - receipt T23 (p-inga) seq 448: `pass`
  - `bun test` p-inga-plan-0010: 458 pass / 0 fail
- PLAN-0006 T16 (ginga main): verify externo tinha selado `scope_drift` (seq 449); re-verify no checkout da main com claim baseline → `pass`; fila ginga main: blocked 0
- `ready/ginga.json` regravado: `{"branch":"plan/0010"}`
- `pinga repo TASK` refs atualizadas: `TASK-06-pinga-sem-discord.md` → `pinga_task: T23`
- `pinga ledger verify`: `ok 457`

## PLAN-0020-cost-usd-validation (worktree `ginga-plan-0020`, branch `plan/0020` da main 0563295)

- Worktree criada da `main`; TASK-01-cost-usd.md criada; T24 do ginga materializado em `tasks/T24/PLAN.md`
- RED: commit 0be20f4 (`test(T24): RED`), `pinga prove-red` → `pass` (done_when exit 1 no base)
- Despacho `dispatch-task.sh`: `TASK-01-cost-usd` status `pass`, modelo `opencode/glm-5.3-flash-free`, tentativa 1, paid_cost 0
- Fix committado no `plan/0020` (1 linha: `cost_usd` nos `numbers` do kind attempt)
- receipt T24 `pass` (seq 452); fila ginga-plan-0020: blocked 0 / open 0
- `bun test` ginga-plan-0020: 164 pass / 0 fail
- `ready/ginga.json`: `{"branch":"plan/0020"}`

## Pendências para a próxima rodada

- PLAN-0022 TASK-04 (`ginga hooks install|check`, `reference-transaction`) — condicionada ao PLAN-0020 (agora fechado do lado ginga).
