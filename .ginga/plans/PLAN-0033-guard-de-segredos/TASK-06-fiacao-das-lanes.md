---
type: task
mode: padrao
goal: "lane.sh e dispatch-task.sh carregam guard-env.sh, recusam iniciar sem o guard (se ligado), exportam GINGA_GUARD_LANE e passam a extensão Pi (-e) e o config dir do opencode; GINGA_GUARD=off desliga tudo"
title: Fiação do guard nas lanes
plan: PLAN-0033-guard-de-segredos
repo: duh-homelab
depends_on: [TASK-03-extensao-pi, TASK-04-plugin-opencode]
tier: medium
touch: [.ginga/bin/guard-env.sh, .ginga/bin/lane.sh, .ginga/bin/dispatch-task.sh, .ginga/bin/tests/guard-env.test.sh]
done_when: "bash .ginga/bin/tests/guard-env.test.sh"
tests_frozen: [.ginga/bin/tests/guard-env.test.sh]
---
## Fazer
- `.ginga/bin/guard-env.sh` (sourced): `guard_on`, `guard_require`, `guard_export <sessão>`, `guard_pi_args` (imprime `-e <repo>/contrib/guard/pi.ts`), `guard_opencode_env` (imprime `OPENCODE_CONFIG_DIR=<repo>/contrib/guard/opencode-config`). Padrão **ligado**; só `GINGA_GUARD=off` desliga.
- `lane.sh`: `source guard-env.sh`; no início `guard_require || { say "guard ausente: lane não inicia"; exit 6; }`; antes de cada operador, `guard_export "$name"`; no ramo `pi:*` acrescentar `$(guard_pi_args)` e no ramo opencode `env $(guard_opencode_env)`. O ramo `claude/*` fica sem guard (hoje fora de uso, ver pesquisa §7).
- `dispatch-task.sh`: o mesmo no executor (`pi:*` e `opencode run`), `guard_export "$PID-$TID"` por tentativa. A marca é herdada pelo `dispatch-task.sh` quando o operador o chama, mas o executor precisa dos argumentos/env próprios.
## Interface
- Protótipo de `guard-env.sh`: [ref/bin/guard-env.sh](../ref/bin/guard-env.sh). O teste também confere com `grep` que os dois scripts usam as cinco funções e passam `bash -n`.
## Não fazer
- **Não alterar `handoffs/lane.env`** (o padrão ligado dispensa). Não mudar a lógica de rodadas, vigia, cota ou merge. Não tocar tests_frozen.
- Não apontar o `GUARD_DIR` para uma worktree de TASK: tem que ser o checkout da main do `ginga` (um executor não pode editar o guard que o vigia).
## Contexto
- Sem repo git na raiz: roda sem ledger do pinga; verificação = o teste + `bash -n` + judge. `lane.sh` está em uso pelas lanes: aplicar com as lanes paradas ou na virada de rodada (o vigia relança).
- Antes de mexer no ramo `pi:*`, conferir o PLAN-0032 TASK-04 (também passa `-e`); coexistem, cada um com o seu `-e`.
