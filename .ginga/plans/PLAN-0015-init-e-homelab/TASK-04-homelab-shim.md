---
type: task
mode: mvp
goal: "bin/homelab vira um shim que avisa da depreciação e repassa tudo para o ginga"
title: bin/homelab vira shim
plan: PLAN-0015-init-e-homelab
repo: duh-homelab
depends_on: [TASK-03-ginga-cobre-homelab]
tier: free
touch: [bin/homelab, bin/start-dashboard.sh, bin/stop-dashboard.sh, _archive/]
done_when: "! grep -q '/home/shibuka' bin/homelab && bin/homelab status >/dev/null 2>&1"
tests_frozen: []
---
## Fazer
- Copiar o `bin/homelab` atual para `_archive/` (com entrada no `MANIFEST.md`).
- Novo `bin/homelab`: aviso em stderr ("use `ginga`") + `exec ginga "$@"`; `start/stop-dashboard.sh` chamam `ginga web start|stop`.
## Não fazer
- Não apagar os scripts de tuios (`tuios-control-center.sh`, `homelab-workspace.sh`).
## Contexto
- `bin/homelab`, `_archive/MANIFEST.md`.
