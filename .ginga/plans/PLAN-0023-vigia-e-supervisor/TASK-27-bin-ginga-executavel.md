---
type: task
mode: padrao
goal: "bin/ginga.ts versionado com modo 755; o alvo do link criado por ginga install executa"
title: lacuna do corte (e) — bin/ginga.ts sem bit de execução
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-26-supervisor-pending-default]
tier: free
pinga_task: T118
touch: [bin/ginga.ts, tests/bin_executable.test.ts, tasks/T118/PLAN.md]
done_when: "bun test tests/bin_executable.test.ts tests/install/install_bin_link.test.ts"
tests_frozen: [tests/bin_executable.test.ts]
---
## Fazer
- `git update-index --chmod=+x bin/ginga.ts` + `chmod +x bin/ginga.ts`. Sem mudança de conteúdo.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs.
