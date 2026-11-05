---
type: task
mode: padrao
goal: "lane.sh e dispatch-task.sh aceitam modelos `agy:<modelo>` (operador e executor), com a mesma vigia de progresso, e pulam o modelo quando o log traz `Individual quota reached`, gravando o reset em handoffs/.agy-quota"
title: agy no operador e no executor
plan: PLAN-0039-agy-nas-lanes
repo: duh-homelab
depends_on: []
tier: medium
touch: [.ginga/bin/agy-run.sh, .ginga/bin/lane.sh, .ginga/bin/dispatch-task.sh, .ginga/bin/tests/agy-lanes.test.sh]
done_when: "bash .ginga/bin/tests/agy-lanes.test.sh"
tests_frozen: [.ginga/bin/tests/agy-lanes.test.sh]
---
## Fazer
- Novo `agy-run.sh` (sourced): `agy_cmd <modelo> <prompt-file>` imprime/executa `agy -p "$(cat prompt)" --model <modelo> --print-timeout 7200s < /dev/null`; `agy_quota_hit <log>` retorna 0 se o log tem `Individual quota reached`; `agy_mark_quota <modelo>` grava `<modelo> <epoch+22h>` em `handoffs/.agy-quota`; `agy_blocked <modelo>` retorna 0 se há marca ainda válida.
- `lane.sh`: no `case` do operador, ramo `agy:*)` ao lado de `pi:*` (mesmo `guard_export`, mesma vigia, mesmo `.op.lock`); modelo bloqueado por `agy_blocked` é pulado como se fosse quota esgotada (próximo degrau).
- `dispatch-task.sh`: ramo `agy:*` no executor, com os mesmos `restore`/`verify`; quota esgotada = `blocked(quota)` sem contar tentativa.
- Aplicação: `.new` + teste + `bash -n` + `mv` atômico, backup `*.bak-AAAA-MM-DD-agy`.
## Interface
- `agy-lanes.test.sh`, com um `agy` falso no `PATH`: (a) ok → `agy_cmd` chama o falso com `--model` e o prompt; (b) log com `Individual quota reached` → `agy_quota_hit` 0 e `agy_mark_quota` grava marca; `agy_blocked` 0 para o modelo marcado e 1 para outro; (c) marca expirada → `agy_blocked` 1; (d) `grep` confirma ramo `agy:` em `lane.sh` e `dispatch-task.sh`; `bash -n` passa em todos.
## Não fazer
- Não alterar `handoffs/lane.env`, nem a lógica de rodadas, merge ou judge. Não usar `--mode auto` (não existe nesta conta).
## Contexto
- INTENT-0014 (evidência de 30/10: operador de teste em 19 s); `lane.sh` linhas do `case ${OPM[$mi]}`; `guard-env.sh` (guard de segredos).
