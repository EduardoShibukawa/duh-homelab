---
type: task
mode: padrao
goal: "O pinga remove install/adopt/adapters, os comandos apontam para ginga install e nada em src/bin/web cita pi-harness"
title: pinga remove install/adopt
plan: PLAN-0006-install-sai-do-pinga
repo: p-inga
pinga_task: T78
depends_on: [TASK-03-ginga-doctor]
tier: medium
touch: [src/install.ts, src/adopt.ts, src/manifest.ts, src/shadow.ts, src/adapters/, src/doctor.ts, src/cli.ts, tests/, README.md, AGENTS.md, scripts/install-skills.sh]
done_when: "bun test && ! rg -n 'pi-harness' src bin web"
tests_frozen: []
---
## Fazer
- Apagar os módulos e testes que foram para o ginga (TASK-01); `pinga install|adopt` → exit 2 com "movido para `ginga install`".
- `pinga doctor` perde a seção de adapters e mantém ledger/toolchain/gira.
- README/AGENTS: instruções de instalação passam a citar o ginga.
## Não fazer
- Não tocar em verify/ledger/judge/queue.
## Contexto
- `src/cli.ts:801-906`; testes listados na TASK-01; `manifest.ts`/`shadow.ts` só se nenhum outro módulo do pinga os usar (`rg`).
