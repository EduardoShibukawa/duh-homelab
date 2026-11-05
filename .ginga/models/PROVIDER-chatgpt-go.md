---
type: provider
title: ChatGPT Go
runtimes: [codex]
family: openai
billing: subscription
quota: janela de 30 dias (plan_type go; 1% usado em 2026-10-26)
quota_check: "último rate_limits em ~/.codex/sessions/**/rollout-*.jsonl (primary.used_percent, window_minutes, resets_at); interativo: /status"
---
## Uso

Família diferente do Planner (Claude) e dos executores baratos, por isso é bom para o **Verifier Judge** e o **Spec Judge** (alternativa ao AGY). **Não é executor** por enquanto (ver [ROUTING](ROUTING.md#escalada)).

## A confirmar

- ~~Se o plano Go inclui o Codex CLI~~: inclui (os rollouts mostram `plan_type: go`).
