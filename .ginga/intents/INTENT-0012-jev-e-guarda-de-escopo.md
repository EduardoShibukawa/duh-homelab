---
type: intent
title: Onde usar o Jev hoje, e a guarda de escopo que a avaliação revelou
source: cli
timestamp: 2026-10-29T23:30:00-03:00
status: open
---
## Pedido do dono

Depois da avaliação do `jev-gateway` (descartado como componente): "pense onde poderíamos usar o Jev atualmente" e "vamos criar um plano para tudo que você achar que vai ser bom".

## Evidência

[research/jev-gateway-2026-10-29.md](../knowledge/research/jev-gateway-2026-10-29.md): o gargalo das lanes não é escolher tool. Em ~171 linhas de falha dos `log.md`: `command_failed` 56, `scope_drift` 24, `tests_frozen_changed` 5, `BLOCKED:` de contrato ~10; erro de tool 2 em ~390 logs. O Jev serve como **classificador pontual** (poucas chamadas, texto curto, rótulo nos logs), não como roteador de tool por passo. A guarda de escopo é determinística e não usa Jev.

## Direção

1. **Medir antes de ligar:** experimento de acurácia do Jev em quatro classificações (motivo de `BLOCKED:`, log de cota × trabalho real, novo × regressão no judge, tier), com meta ≥ 90% (ROUTING; `determinismo-e-placement.md` §4).
2. **Integrar só o que passar,** em modo sombra primeiro, com regra determinística como piso e fail-open.
3. **Guarda de escopo no Pi** (`tool_call`): bloquear `edit`/`write` fora do `touch` e em `tests_frozen` antes de a escrita acontecer.

## Fora

Gateway `jev-gateway`; Jev escolhendo tool por passo; triagem de tier e qualidade de TASK em produção (só medidos, ver SPEC-0004).
