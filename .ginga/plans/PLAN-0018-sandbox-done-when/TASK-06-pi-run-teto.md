---
type: task
mode: mvp
goal: "pi-run.sh <teto_usd> <pi args...> roda o Pi pago com teto rígido de custo e grava o gasto em paid-spend.tsv"
title: Teto rígido de custo para o Pi pago
plan: PLAN-0018-sandbox-done-when
repo: duh-homelab
depends_on: []
tier: free
touch: [.ginga/bin/pi-run.sh, .ginga/plans/PLAN-0018-sandbox-done-when/tests/pi-run.test.sh]
done_when: "test -x .ginga/bin/pi-run.sh && bash .ginga/plans/PLAN-0018-sandbox-done-when/tests/pi-run.test.sh"
tests_frozen: [.ginga/plans/PLAN-0018-sandbox-done-when/tests/pi-run.test.sh]
---
## Fazer
- `.ginga/bin/pi-run.sh <teto_usd> <pi args...>`: roda `pi --mode json <args...>`, soma `message.usage.cost.total` do stream (dedupe por `responseId`, como o manda) e mata o processo quando a soma passa do teto (exit 124).
- Grava `data\tPLAN\tTASK\tmodelo\tcusto` em `.ginga/plans/paid-spend.tsv`; PLAN/TASK vêm de `PI_PLAN`/`PI_TASK` (padrão `ops`).
## Não fazer
- Sem provider/modelo padrão implícito (nunca `opencode-go`); provider/modelo vêm dos args.
## Contexto
- INTENT-0008 (teto rígido para runtime pago); `manda/src/runtime/pi.ts` `parsePiRunnerOutput` (dedupe por responseId).
