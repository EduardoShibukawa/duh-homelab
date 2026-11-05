# Operador - PLAN-0028 ciclo autônomo sem operador

## Ações realizadas
- Corrigido `src/cli.ts` replan: guarda `checkPaidCall` antes da execução do planner (extração de modelo, `since` inicial, `claudeCosts` vazio) para cobrir teto de custo nos papéis.
- `manda red` CLI agora imprime JSON com resultado de `redPlan`.
- `src/red.ts`:
  - `taken` agora inclui `pinga_task` já alocados nos `TASK-*.md` do plano (evita colisão).
  - `prove-red` só marca `test_passed_on_base` quando stdout contém a string; código de saída não-nulo gera erro explícito.

## Testes
- `bun test tests/red.test.ts` → 3 pass / 0 fail
- `bun test tests/red_cli.test.ts` → 2 pass / 0 fail

## Commits
- `manda-plan-0028` `plan/0028` commit `099d16e` (fix red taken ids, prove-red handling, cli replan cost guard and red json output)

## Pendências
- Verificação formal `pinga verify` ainda reporta scope_drift para T156/T159 devido a alterações fora do touch em commits anteriores (TASK-162). Requer ajuste de ledger pelo gate.
- Judge ainda cita `run.ts/judge.ts` sem `claudeCosts` e `since` agorista; parcialmente mitigado na CLI, mas executor/judge mantém fallback sem custos.

## Decisões registradas
- Nenhuma decisão de replan/troca de modelo tomada; apenas correções de código dentro das TASKs existentes.
