# Handoff — operador manda rodada (2026-10-31T05:06–05:22)

## ITEM: Achados do judge — PLAN-0029 (manda)

### TASK: T169 — disjuntor por modelo (`src/breaker.ts`)

- **Conceito**: `breakerOf`/`recordFailure`/`recordSuccess` usam `bun:sqlite` num `.ginga/state/state.db`. Falha: level+1 (máx. 3), `until = now + [10,30,120][level-1]` min. `until` vencido → `half_open`. `recordSuccess` zera.
- **Situação**: receipts pass já selados no ledger (seq 1336 prove-red, 1345 verify, base 4a3b694), mas o código foi perdido do worktree `manda-plan-0029` (nenhum commit T169 presente; HEAD era 700fa1e/T168).
- **Reprodução**:
  - Escreve `tests/breaker.test.ts` (12 casos: escalada 10/30/120, capped, modelos independentes, half_open no vencimento, recordSuccess, consistência entre 2 Database no mesmo arquivo).
  - Stub `src/breaker.ts` (throw "not implemented") → RED por asserção.
  - Commit `test(T169): RED` (919415d). `pinga prove-red --base HEAD`: pass (RED, exit 1).
  - Implementa `src/breaker.ts` (com `bun:sqlite`, `ensureTable`, UPSERT ON CONFLICT).
  - Commit `feat(T169)` (8016ade). `pinga verify`: pass (seq 1357, done_when exit 0, 0s).
- **bun test tests/breaker.test.ts**: **12 pass / 0 fail**.
- **pinga verify T169**: **pass** (seq 1357).

### TASK: T170 — env padrão dos runtimes (`src/runtime/env.ts`, `src/runtime/index.ts`)

- **Conceito**: `runtimeEnv(base)` adiciona `PYTHONDONTWRITEBYTECODE=1`; `SPAWN_STDIN="ignore"`. Wrapper `withDefaults` em `index.ts` injeta ambos em todos os spawns (pi, opencode, claude, codex, agy).
- **Situação**: receipts pass no ledger (seq 1337, 1346), código perdido. Reproduzido.
- **Reprodução**:
  - Escreve `tests/runtime_env.test.ts` (9 casos: runtimeEnv preserva/filtra undefined/env vazio; SPAWN_STDIN; resolveRuntime para cada runtime recebe env com PYTHONDONTWRITEBYTECODE e stdin="ignore").
  - Stub `src/runtime/env.ts` (runtimeEnv não adiciona a variável) + `src/runtime/index.ts` (aceita opts.spawn mas não aplica wrapper).
  - Commit `test(T170): RED` (80a8bff). `pinga prove-red --base HEAD`: pass (RED, exit 1).
  - Implementa `env.ts` (runtimeEnv adiciona variável) + `index.ts` (`withDefaults` wrapper).
  - Commit `feat(T170)` (ae34e00). `pinga verify`: pass (seq 1361, done_when exit 0, 0s).
- **bun test tests/runtime_env.test.ts**: **9 pass / 0 fail**.
- **pinga verify T170**: **pass** (seq 1361).

## Estado global

- `pinga ledger verify`: **ok 1355**.
- `bun test` (suite completa): **301 pass, 4 fail** — os 4 fail são preexistentes (CLI usage exit 2 em `judge_blind.test.ts` e `pipeline.test.ts`), não causados por estas TASKs.
- `bun test` (tasks T169+T170 focados): **21 pass / 0 fail**.
- PLAN-0029 progresso: TASK-01 (T167) ✓, TASK-02 (T168) ✓, TASK-03 (T169) ✓, TASK-05 (T170) ✓. Faltam: TASK-04, 06, 07, 08, 09, 10.
- `ready/manda.json` para PLAN-0029: **não gravado** (nem todas as TASKs têm pass; faltam 6).
- Decisão registrada em `REPORT-2026-10-28.d/decisoes.md`: reutilização de T169/T170 em vez de IDs novos.

## Próximos itens (rodada seguinte)

- PLAN-0029 TASK-07 (T171): classificador de `BLOCKED:` (`src/blocked.ts`).
- PLAN-0029 TASK-04 (T172): escada por custo (`src/ladder.ts`).
- Ordem do PLAN: (03, 05, 07) → 04 → (06, 08, 10) → 09. Próximos na sequência: TASK-07, TASK-04.
