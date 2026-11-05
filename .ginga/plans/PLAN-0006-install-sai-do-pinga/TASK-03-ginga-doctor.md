---
type: task
mode: mvp
goal: "ginga doctor reporta o estado dos adapters de host como o pinga doctor faz hoje"
title: ginga doctor com a parte de harness
plan: PLAN-0006-install-sai-do-pinga
repo: ginga
depends_on: [TASK-02-plugin-parametrizado]
tier: free
pinga_task: T16
touch: [src/doctor.ts, src/cli.ts, tests/doctor.test.ts]
done_when: "bun test tests/doctor.test.ts"
tests_frozen: [tests/doctor.test.ts]
---
## Fazer
- Portar de `p-inga/src/doctor.ts` só o que usa `ADAPTER_ORDER`, `Adapter`, `Probe`, `pickSource` (seção por harness, `--only`, `--json`).
## Não fazer
- Checagens de ledger, toolchain e gira ficam no `pinga doctor`.
## Contexto
- `p-inga/src/doctor.ts` (l. 10, 114-130 `sourceOf`/`ADAPTERS`), `p-inga/tests/doctor.test.ts`.
