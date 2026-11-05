# Handoff — operador manda rodada 3 (2026-10-30T22:18–22:21)

## ITEM: Achados do judge no PLAN-0028 (manda)

### TASK: T164 — red_plan multi-repo filter + frozen path real + status: blocked

- **Conceito**: `src/red.ts:96` iterava todas as TASKs do bundle sem filtrar por `repo`; em PLAN multi-repo processava TASKs do ginga e abortava por `tests_frozen` ausente em `frozen/manda`. O erro de `frozen/<repo>` ausente lançava caminho fixo `tests/frozen.test.ts` em vez do caminho real. O bloqueio por `test_passed_on_base` gravava `blocked: true` no frontmatter em vez de `status: "blocked"`.
- **Fix aplicado (commit `0d7ec52` em `plan/0028`)**:
  - `bundle.tasks.filter((t) => t.repo === repo)` após `loadBundle`.
  - Removido o check de existência de `frozenSrc`; a validação individual de `tests_frozen` lança `srcPath` (caminho real `frozen/<repo>/<tf>`) em vez de `tf`.
  - `status: "blocked"` + `reason: "test_passed_on_base"` no lugar de `blocked: true`.
- **bun test**: `tests/red_repo.test.ts tests/red_cli_repo.test.ts tests/red.test.ts tests/red_cli.test.ts` → **9 pass / 0 fail**.
- **pinga verify T164**: **pass** (receipt seq 1304).

### TASK: T165 — CLI manda red multi-repo

- **Conceito**: a CLI `manda red` herda a falta de filtro por repo de `redPlan`; PLAN multi-repo falha com arquivo ausente de TASK de outro repo.
- **Fix**: herdado de T164 (a CLI já passa `repo` a `redPlan`; sem mudança em `src/cli.ts`).
- **bun test**: `tests/red_cli_repo.test.ts` → **1 pass / 0 fail**.
- **pinga verify T165**: **pass** (receipt seq 1305).

## Estado global

- `pinga ledger verify`: **ok 1306**.
- `ready/manda.json`: `{"branch":"plan/0028"}` (já atualizado).
- Todas as 6 TASKs do PLAN-0028 no manda com `pass`: T154, T155, T156, T157, T164, T165.

## Decisões do operador

| Data | Decisão | Regra ou visão |
|---|---|---|
| 2026-10-30T22:18 | Remover o check de existência de `frozenSrc` e lançar `srcPath` (caminho real) na validação individual de `tests_frozen`, em vez do caminho fixo `tests/frozen.test.ts` | TASK-14 spec: "Remover o check de existência de frozenSrc; a validação individual de cada tests_frozen (já existente) lança srcPath (caminho real) em vez de tf." + "Não editar tests/red.test.ts" (compatibilidade com teste pré-existente que espera `/tests\/frozen\.test\.ts/`) |
