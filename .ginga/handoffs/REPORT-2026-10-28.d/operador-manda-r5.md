# operador manda rodada 5 (2026-10-29) — fatos

Item resolvido: **PLAN-0023 TASK-05 (manda)** — verbos `kill_and_retry` e `rotate_model` + emissão de heartbeat/progress no `manda pipeline`. Já implementado por T20 (receipt pass); apenas bookkeeping.

## TASK, receipts, testes

| TASK | commit | receipt | bun test |
|---|---|---|---|
| T20 (manda) | 5c96a42 fix(T20): manda pipeline/lane + verbos kill_and_retry/rotate_model; corrige roteamento judge --base/--head | pass (seq 475) | tests/pipeline.test.ts + tests/judge_blind.test.ts: 16 pass / 0 fail |
| T21 (manda) | 026671e test(T21): RED ... + 1163a90 fix(T21): remove shim src/judge-run.ts | pass (seq 481) | tests/judge_module.test.ts: 1 pass; suite inteira: 160 pass / 0 fail |
| (worktree inteira) | — | 21 done / 0 open | bun test (manda plan/0022): 160 pass / 0 fail |

- `pinga queue --json --root manda-plan-0022`: 20 done, 0 open, 0 blocked, 0 invalid.
- `pinga ledger verify`: ok (seq 478).
- Merge: plan/0022 → main em 62e1789 (gate 0, judge pass no HEAD 5c96a42).

## Achados do judge

- Único achado recente para manda: gate 11 em 21:07 (HEAD 9a9c23f) — `src/cli.ts:60-61` contava valores de `--base/--head` como posicionais, podendo rotear `manda judge <PLAN> --base <ref> --head <ref>` para `judge_run.ts` quebrando `judge.ts`. Corrigido em 5c96a42 (valueOpts + contagem de posicionais). Judge re-run em 5c96a42: pass.

## Backlog

- `- [x]` PLAN-0023 TASK-05 em `.ginga/prompts/backlog-manda.md`.

## Pendências

- Nenhuma para manda. Próximo passo: judge + merge-gate do pipeline (já mergeado). Limpeza `judge-run.ts` × `judge_run.ts` fica para round futuro (nota de decisão registrada).