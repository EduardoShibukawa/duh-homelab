---
type: task
mode: padrao
goal: "redPlan monta `taken` varrendo tasks/T*/ do worktree e incluindo pinga_task de TODAS as TASKs do bundle (não só do repo filtrado), evitando colisão de id (achado do judge em TASK-02)"
title: redPlan varre tasks/T* e inclui todos os pinga_task do bundle em taken
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-14-red-repo-filter]
tier: free
touch: [src/red.ts, tests/red_taken.test.ts, tasks/T166/PLAN.md]
done_when: "bun test tests/red_taken.test.ts"
tests_frozen: [tests/red_taken.test.ts]
pinga_task: T166
---

## Achado do judge (2026-10-30, grave; ref TASK-02)
- `redPlan` (src/red.ts:~100-125) monta `taken` só de `pinga queue --json` e das TASKs do próprio PLAN já filtradas por repo.
- Nenhum código varre `tasks/T*/` (46 pastas, até T165) nem inclui `pinga_task` de TASKs de outros repos no bundle.
- Se a fila listar só as tasks abertas, `redPlan` pode alocar um id que já existe como `tasks/T<N>/PLAN.md`, sobrescrevendo o arquivo.

## Fazer
- Varrer `tasks/T*/` no worktree (se existir) e adicionar os ids ao `taken`.
- Incluir `pinga_task` de TODAS as TASKs do bundle (não só do repo atual) em `taken`.

## Testes frozen em `tests/red_taken.test.ts`
1. **Scan tasks/T***: worktree com `tasks/T1/PLAN.md`; queue vazia; bundle com TASK sem pinga_task → id alocado NÃO é T1 (é T2).
2. **Bundle multi-repo**: bundle com TASK de ginga (pinga_task: T7) e TASK de manda (sem pinga_task); queue com T6 → id alocado para manda NÃO é T7 (é T8).

## Não fazer
- Não editar tests/red.test.ts, tests/red_repo.test.ts, tests/red_cli_repo.test.ts nem fixtures existentes.

## Follow-up do judge (2026-10-31)
- O judge reprovou TASK-02 e TASK-16: a worktree é criada DEPOIS do cálculo de `taken`,
  logo na primeira execução `tasks/T*/` não é varrido.
- [TASK-17](TASK-17-worktree-before-taken.md) (T167) resolve: move a criação da worktree
  antes de `taken`; teste frozen cobre first-execution. Commit `e6c3d16`; verify pass (1331).
