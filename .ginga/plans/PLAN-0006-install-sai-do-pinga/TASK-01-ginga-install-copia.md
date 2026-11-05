---
type: task
mode: padrao
goal: "O ginga tem install/adopt/adapters copiados do pinga, com os testes copiados passando"
title: Copiar install/adopt/adapters para o ginga
plan: PLAN-0006-install-sai-do-pinga
repo: ginga
depends_on: []
tier: medium
pinga_task: T14
touch: [src/install/, src/cli.ts, tests/install/]
done_when: "bun test tests/install/"
tests_frozen: []
---
## Fazer
- Copiar `p-inga/src/{install,adopt,manifest,shadow}.ts` e `src/adapters/*.ts` para `src/install/`; ajustar imports relativos.
- Copiar `tests/{install,install_rebaseline,adopt,adapters,hermes_enable_config,hermes_local_source,tuios_targets,opencode_probe}.test.ts` e `tests/helpers/{home,stubs}.ts` para `tests/install/`.
- `ginga install` e `ginga adopt` com os mesmos flags do pinga.
## Não fazer
- Não mudar comportamento ainda (TASK-02). Não importar de `../p-inga`.
## Contexto
- `p-inga/src/cli.ts:801` (`install`) e `:858` (`adopt`).
