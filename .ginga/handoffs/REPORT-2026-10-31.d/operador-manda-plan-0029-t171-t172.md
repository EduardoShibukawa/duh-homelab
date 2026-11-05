# Handoff — Rodada 4 manda (2026-10-31)

## Items resolvidos (2)

### 1. PLAN-0029 TASK-07 (T171): `manda classifier blocked`
- **Receipt: pass** — prove-red pass (base 6193ddf, 8 assertion failures), verify pass (seq 1385, done_when exit 0)
- **bun test:** 10 pass, 0 fail
- **Código:** `src/blocked.ts` (classifyBlocked + BlockedClass/BlockedAction types), `src/failure_rules.json` (8 rules: scope_drift, id_collision, quota, gate_false_positive, contract_conflict, missing_dep, env_dependency, other)
- **Fix operador:** RED commit original (708e023) não tinha stub → prove-red falhava com "Cannot find module '../src/blocked'". Adicionado stub src/blocked.ts no RED commit, reescrevendo histórico. PLAN.md encurtado para 13 linhas + `tasks/T171/PLAN.md` incluído no touch.

### 2. PLAN-0029 TASK-04 (T172): `manda pickModel escada free→pago`
- **Receipt: pass** — prove-red pass (base 21e335b, 5 assertion failures), verify pass (seq 1387, done_when exit 0)
- **bun test:** 5 pass, 0 fail
- **Código:** `src/ladder.ts` (providerOf + pickModel com escada free→paid, pula breaker open, pula iceman* quando !mitRepo)
- **Fix operador:** RED commit original (d8478fb) não tinha stub → prove-red falhava com "Cannot find module '../src/ladder'". Adicionado stub src/ladder.ts no RED commit, reescrevendo histórico.

## Progresso PLAN-0029
- 6/10 (TASK-01✓ 02✓ 03✓ 04✓ 05✓ 07✓; faltam 06, 08, 09, 10)
- Worktree: manda-plan-0029 (branch plan/0029), HEAD 621cc4e

## Full suite
- `bun test`: 316 pass, 4 fail (preexistentes — CLI usage exit 2 em judge_blind.test.ts e pipeline.test.ts)
- `pinga ledger verify`: ok 1387

## Próximos (não iniciados — dependem de PLAN-0029 completo)
- PLAN-0033 TASK-07 (PRIORIDADE): precisa PLAN-0029 + PLAN-0032 + guard/pi.ts no ginga (guard/pi.ts AINDA ausente no ginga main)
- PLAN-0034 TASK-01: precisa PLAN-0029 + PLAN-0032 + PLAN-0033 TASK-07
- PLAN-0013 TASK-07: precisa PLAN-0013 mergeado no ginga (ainda não)
