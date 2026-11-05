---
type: task
mode: mvp
goal: "ginga doctor confere presença e faixa de versão de pinga, manda e gira pelo --version --json de cada um"
title: ginga doctor confere versões
plan: PLAN-0015-init-e-homelab
repo: ginga
pinga_task: T132
depends_on: [TASK-03-ginga-cobre-homelab]
tier: free
touch: [src/doctor.ts, tests/doctor_versions.test.ts]
done_when: "bun test tests/doctor_versions.test.ts"
tests_frozen: [tests/doctor_versions.test.ts]
---
## Fazer
- Faixas semver em `package.json` (`gingaCompat: {pinga, manda, gira}`); ausente/opcional (gira) → aviso, não erro.
- Saída `--json` com `schema_version`.
## Não fazer
- Não instalar nada.
## Contexto
- Doc 02 §1 ("Semver com ranges"); `src/doctor.ts` (PLAN-0006 TASK-03).
