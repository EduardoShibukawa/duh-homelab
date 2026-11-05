# Handoff — 2026-10-30T01:30Z (rodada 2, lane manda)

## Achados do judge (o gate barrou)
Todos já resolvidos no ciclo anterior — veja backlog `[x]`. Nenhum pendente.

## Backlog (manda)

### PLAN-0029-rota-de-falhas-e-disjuntor (worktree `manda-plan-0029`, branch `plan/0029`)

**Concluído nesta rodada (2 itens):**

| TASK | pinga_task | receipt | model | attempts | bun test | observação |
|---|---|---|---|---|---|---|
| TASK-01 (classifyRun) | T167 | pass | opencode-go/iceman-contributor-free | 1 | pass (0) | src/run_state.ts criado na worktree |
| TASK-02 (probe) | T168 | pass | opencode-go/iceman-contributor-free | 1 | pass (0) | src/probe.ts criado na worktree |

- RED: ambos `pinga prove-red` = RED (import/error de módulo inexistente, exit 1).
- Commits na worktree `plan/0029`: `test(T167,T168): RED` (ec8d7fc), `feat(T167)` (a1fe390), `feat(T168)` (700fa1e).
- `pinga verify` em ambas: **pass**, exit 0.
- Base de worktree: `4a3b694` (main já contém PLAN-0032 mergeado).
- Próximos: TASK-03 (T169, breaker), TASK-05 (T170, env runtime), TASK-07 (T171, classifyBlocked) — lote independente. Depois TASK-04 (breaker dep), TASK-06/TASK-08/TASK-10, e por fim TASK-09 (vigia).
- `ready/manda.json` **não** gravado: faltam 8 TASKs.

### Itens condicionais (não iniciados)
- PLAN-0013 TASK-07: aguarda `ginga lessons find` mergeado (`git -C ginga log main | grep PLAN-0013` → 0).
- PLAN-0033 TASK-07: aguarda `git -C manda log main | grep PLAN-0029` (ainda não mergeado) + `git -C ginga cat-file main:contrib/guard/pi.ts` (não existe).
- PLAN-0034 TASK-01: aguarda PLAN-0029 + PLAN-0032 + PLAN-0033 TASK-07 no manda main.
