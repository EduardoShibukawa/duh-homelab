---
type: task
mode: mvp
goal: "Os frozen do doctor leem o shape novo {schema_version, records} e a semântica de --only das versões"
title: adaptação dos frozen do doctor ao shape novo
plan: PLAN-0015-init-e-homelab
repo: ginga
depends_on: [TASK-05-doctor-versoes]
tier: free
touch: [tests/doctor.test.ts, tests/doctor_hooks_drift.test.ts]
done_when: "bun test tests/doctor.test.ts tests/doctor_hooks_drift.test.ts"
tests_frozen: [tests/doctor.test.ts, tests/doctor_hooks_drift.test.ts]
pinga_task: T133
---
## Fazer
- `tests/doctor.test.ts` (frozen PLAN-0006; alterado por TASK nova — precedente T128): parse do
  `--json` via `records` do wrapper; teste `--only` afirma que com filtro os probes de versão
  não rodam (`check:"version"` vazio).
- `tests/doctor_hooks_drift.test.ts` (frozen PLAN-0024; mesma regra): parse do wrapper.
## Não fazer
- Não tocar em `src/` (contrato T132 já selado).
## Contexto
- Colateral da T132: `ginga doctor --json` embrulha agora em `{schema_version:1, records:[...]}`.
