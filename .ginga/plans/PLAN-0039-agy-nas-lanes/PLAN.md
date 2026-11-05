---
type: plan
title: Gemini (agy) nas lanes como operador, executor e judge
intent: INTENT-0014-agy-nas-lanes
kind: change
status: approved
repos: [duh-homelab]
depends_on: []
done_when: "bash .ginga/bin/tests/agy-lanes.test.sh"
---
## Objetivo

O dono (2026-11-05): "estamos com o free configurado, mas podemos usar o gemini também, voltei a ter quota". Probe de 2026-11-05: `gemini-3.8-flash-low` e `gemini-4-argon-low` respondem (o argon estava esgotado em 30/10). Ligar o `agy` nas lanes como no esboço do INTENT-0014, sem mexer no `lane.env` (a escada free continua; o Gemini entra por `agy:<modelo>` quando o dono ou o Planner colocar na lista).

Restrição de dado a terceiro já coberta: o dono aprovou código a providers que treinam (2026-10-29); segredos continuam protegidos pelo guard do PLAN-0033. Sem gasto pago.

## TASKs

1. [TASK-01](TASK-01-lane-e-dispatch.md): ramo `agy:*` no `lane.sh` e no `dispatch-task.sh`, com pulo por quota esgotada
2. [TASK-02](TASK-02-judge-agy.md): `judge-run.sh` com Gemini em modo plan como judge de outra família

## Riscos

- Os três scripts estão em uso pelas lanes: trocar por `mv` atômico, só na virada de rodada ou com as lanes paradas.
- Quota é por modelo e sem leitura programática: o pulo é por texto no log (`Individual quota reached`).
- Conflito de arquivo com PLAN-0038 TASK-01 (`dispatch-task.sh`): aplicar na ordem 0038-T01, depois 0039-T01.
