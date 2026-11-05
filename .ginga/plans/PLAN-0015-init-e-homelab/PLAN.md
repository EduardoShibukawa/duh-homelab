---
type: plan
title: ginga init/onboarding sem gira + bin/homelab vira ginga (A5)
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: approved
approved: 2026-10-29
repos: [ginga, duh-homelab]
depends_on: [PLAN-0009-contexto-sem-gira, PLAN-0011-verbos-api-auth]
done_when: "cd ginga && bun test && bun test tests/e2e/onboarding_no_gira.test.ts && cd .. && ! grep -q '/home/shibuka' bin/homelab"
---
## Objetivo

Fechar a portabilidade: `ginga init` prepara um repo novo (`.ginga/` + `project.toml`) detectando o que existe na máquina, o onboarding funciona sem gira, e o `bin/homelab` (bash com caminhos absolutos) vira um atalho para o `ginga`.

## Abordagem

- `init` segue os 5 passos do protótipo `Onboarding.dc.html`: projeto detectado (stack → `[commands]`), provider de contexto (gira se houver binário e `.gira/`, senão `rg`), runtimes no PATH (pi, claude, opencode, codex, agy), canais do Hermes, revisão do `project.toml`. Idempotente: nunca sobrescreve.
- `init` entra no registro de verbos (CLI e API), fechando a lista do AC de verbos.
- Os subcomandos do `homelab` (`status`, `web`, `tui`, `hermes`, `hud`, `verify`, `maestro`, `gira`, `ctl`) viram verbos/atalhos do `ginga`, sem `DUH_ROOT` nem caminho do bun fixos (`GINGA_WORKSPACE` ou descoberta pelo `.ginga/` mais próximo).
- `bin/homelab` fica como shim com aviso de depreciação, para não quebrar hábitos e scripts (`bin/start-dashboard.sh` etc.).

## TASKs

1. [TASK-01](TASK-01-ginga-init.md): `ginga init`
2. [TASK-02](TASK-02-e2e-onboarding.md): e2e do onboarding sem gira
3. [TASK-03](TASK-03-ginga-cobre-homelab.md): o ginga cobre os subcomandos do homelab
4. [TASK-04](TASK-04-homelab-shim.md): `bin/homelab` vira shim do ginga
5. [TASK-05](TASK-05-doctor-versoes.md): `ginga doctor` confere versões de pinga/manda/gira

## ACs da SPEC cobertos

- `ginga init` prepara um repo novo e o fluxo do onboarding funciona sem gira.
- O `bin/homelab` vira `ginga` (A5; a parte de install/adopt fechou no PLAN-0006).
- Parte de "toda ação existe como verbo" (`init`).

## Riscos

- `bin/homelab` chama scripts com caminho absoluto (`bin/start-dashboard.sh`, `tuios-control-center.sh`, `homelab-workspace.sh`): o `ginga web` substitui o dashboard do `p-inga/web`, o que muda a porta (4242 → `[serve].port`).
- Instalação decidida (PLAN-0026 e `manda install`): link em `~/.local/bin`. O doctor confere esse link e as versões.
- `ginga web` depende da Roda Web (PLAN-0012), que não está no `depends_on`: até o 0012 fechar, o atalho `web` repassa para o dashboard atual (`bin/start-dashboard.sh`) com aviso, e o teste de paridade aceita isso.
