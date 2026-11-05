---
type: task
mode: padrao
goal: "ginga doctor inclui o registro ginga/hooks_drift: com hooks.toml na raiz do cwd, drift (hook ausente, não arquivo ou diferente da fonte) vira status broken/law2 fail com detail listando repo e hook e exit 1; sem hooks.toml, registre unverified/law2 blocked sem alterar o exit por hooks"
title: follow-up judge: doctor acusa drift dos hooks
plan: PLAN-0024-doctor-hooks-drift
repo: ginga
depends_on: []
tier: free
pinga_task: T27
touch: [src/hooks/index.ts, src/doctor.ts, tests/doctor_hooks_drift.test.ts, tasks/T27/PLAN.md]
done_when: "bun test tests/doctor_hooks_drift.test.ts"
tests_frozen: [tests/doctor_hooks_drift.test.ts]
---
## Fazer
- Em `src/hooks/index.ts`: extrair a detecção de drift de `hooksCheckCmd` para uma função pura exportada `hooksDrift(root): Array<{repo, hook, reason}>` (os mesmos motivos de hoje: "não é um repo git", "fonte ausente em .ginga/hooks/git", "hook ausente", "diferente da fonte"); `hooksCheckCmd` passa a usá-la.
- Em `src/doctor.ts`: depois do loop de adapters, um registro extra com as MESMAS 9 chaves (`harness: "ginga"`, `check: "hooks_drift"`) sobre a raiz do cwd (doctor não tem --root):
  - `.ginga/hooks.toml` ausente no cwd → status `unverified`, law2 `blocked`, detail `hooks.toml ausente` (não altera o exit por hooks).
  - Com config: `hooksDrift(cwd)` vazio → status `ok`, law2 `pass`, detail `sem drift`; com drift → status `broken`, law2 `fail`, detail `N drift(s)` seguido de `repo hook reason` (um por entrada), e o doctor sai 1 como o plugin quebrado.
- Caixa preta como tests/doctor.test.ts (bingo fake `claude` ausente/PATH vazio; plugin+plugin_validate podem ficar `unverified`).
## Não fazer
- Não tocar tests_frozen `tests/doctor.test.ts`, `tests/hooks_install.test.ts`, `tests/fixtures/hooks/`; não mudar formatação/semântica dos registros existentes nem a saída de `hooks check`.
## Contexto
- Achado do judge de 21:15 (REPORT-2026-10-28): `src/doctor.ts:38-103` não verifica nem acusa drift dos hooks, como pede TASK-04 do PLAN-0022.
