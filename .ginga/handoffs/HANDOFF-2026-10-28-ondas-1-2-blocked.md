---
type: handoff
plan: [PLAN-0004, PLAN-0018]
timestamp: 2026-10-28T03:20:00-03:00
---
## Estado

| PLAN | Status | Onde |
|---|---|---|
| 0004 eventos + lint | **blocked** (rodada 5 de fix esgotada) | `ginga-plan-0004` + `pi-harness-plan-0004` (branch `plan/0004`), nada mergeado |
| 0018 sandbox done_when | **blocked** (2 rodadas de fix esgotadas) | `p-inga-plan-0018` (branch `plan/0018`), nada mergeado |

- **Ledger:** `pinga ledger verify` → ok 346. **Custo pago:** ~US$0,54 (só Zen free nas TASKs desta onda; nada pago novo).

## 0004 — por que bloqueou

Judge Codex rodada 5: TASK-12 (T10) **ok** (nome de TASK sem frontmatter corrigido), mas 2 achados NOVOS (simples):
1. `src/events/validate.ts:32-39` limita `transition.data.by` a `owner/system`, mas `docs/events-v1.md:26` admite `<papel>` (qualquer papel).
2. pi-harness `src/harness/events.ts` `appendEvent` emite sem limite de 4 KiB (`docs/events-v1.md:9` exige < 4 KiB).

## 0018 — por que bloqueou

TASK-04 (T72) e TASK-05 (T73) passaram (glm-5.3-flash-free, 1 tentativa cada). Judge Codex rodada 3 ainda acha 2 gaps (simples):
1. `src/verify.ts` holdout com exit 97 cai em `overfit_holdout`/`fail`, não `blocked/infra`.
2. `src/prove.ts` sela `not run` (não `blocked`) no exit 97.

Já corrigidos: verify/plan_verify/supersede done_when exit 97 → `blocked/infra`; holdout via `doneWhenArgv`; `wrapperProblem()` fail-closed nos 4 comandos; precedência do infra sobre o holdout no prove.

## Próximos passos (aguardando dono)

1. **0004:** decidir se os 2 achados viram TASK-13/TASK-14 (fix) ou novo INTENT. Worktrees preservadas com todo o código (nada commitado no ginga; pi-harness tem `src/harness/events.ts` modificado + tasks/T57,T58 + testes untracked).
2. **0018:** autorizar rodada 3 de fix (TASK-06: verify holdout exit 97 → blocked/infra + prove exit 97 → blocked) ou aceitar `not run`/`fail` como está.

## Aprendizados (aplicar)

- **Judge Codex acha achados novos a cada rodada** (não só o que a TASK de fix tocou). Rodada 5 do 0004 e rodada 3 do 0018 trouxeram defeitos fora do escopo da fix anterior.
- **Prompt do judge precisa ser inequívoco**: a nota "rodada 5" ambígua do handoff anterior fez o Codex reprovar a TASK-12 por engano (interpretou o contrário). Re-rodar com nota clara resolveu (TASK-12 virou ok).
- **Sidecars `tasks/T<N>/PLAN.md`** são artefatos do operador, não "fora do touch" — o judge os marcou como tal; esclarecer no prompt.
- **`pinga_task` único por repo**: T72/T73 livres no p-inga (T71 done).
