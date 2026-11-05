# operador manda rodada 7 (2026-10-29) — fatos

Item resolvido: bug do revert automático em `src/merge.ts` (sem MERGE_GATE=1) bloqueado pelo hook reference-transaction.

## TASK, receipts, testes

| TASK | commit | receipt | bun test |
|---|---|---|---|
| T100 (manda) | 485b3cc fix(T100): revert do merge-gate usa MERGE_GATE=1 e retorna 16 (CRÍTICO) se falhar | pass (seq 494) | tests/merge_revert_hook.test.ts: 1 pass / 0 fail; suite inteira: 161 pass / 0 fail |

- `pinga queue --json --root manda-plan-0022`: T100 done.
- `pinga ledger verify`: ok (seq 494).
- `.ginga/plans/PLAN-0022-merge-gate-no-pacote/ready/manda.json`: `{"branch":"plan/0022"}` (reescrito).
- Backlog marcado [x].

## Mudança

- `src/merge.ts`: revert via `Bun.spawnSync` com `env: {...process.env, MERGE_GATE: "1"}`; falha no revert retorna exit 16 (CRÍTICO) em vez de 14.
- Novo teste `tests/merge_revert_hook.test.ts` com fixture repo contendo hook reference-transaction.
