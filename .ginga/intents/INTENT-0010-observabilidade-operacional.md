---
type: intent
title: Observabilidade operacional, para o harness ver os próprios erros
source: cli
timestamp: 2026-10-28T08:10:00-03:00
status: open
---
## Pedido do dono

"A observabilidade vai ser ULTRA IMPORTANTE e devemos pensar nela, pois você está vendo os erros manualmente, mas no fluxo como isso funcionaria?"

## Evidência: o que o operador (Claude) detectou à mão nas ondas 1–3

| Detectado à mão | Sinal necessário | Regra | Ação |
|---|---|---|---|
| Cliente opencode travado com 0% de CPU (porta 49374), por 1h30 | `heartbeat` / `last_event_at` por attempt | sem evento há mais de N min com o processo vivo | matar, `infra_stuck`, retry; Discord se repetir |
| 6 tentativas com o mesmo `BLOCKED:` (teste contraditório) | `attempt.reason` + hash da mensagem | 2 falhas iguais seguidas | breaker → desbloqueio (INTENT-0008) |
| nemotron 0/42 | `attempt{model,pass}` | taxa por modelo abaixo de X em N tentativas | sai da escada, aviso |
| US$6,90 de Pi pago num dia, com teto de US$2 | `cost` por chamada | gasto por hora; 80% e 100% do teto global | alerta / corte |
| Judge trazendo itens novos a cada rodada | `judge.verdict{new,regression}` | rodada > 2 sem regressão | merge + follow-up |
| 429 de free esgotado | `attempt{failure:quota}` | 429 por modelo e por janela | pular de degrau, registrar a janela |
| Colisão de T<N>, falso positivo AC-SEC | `gate.fail{kind}` | classificação | desbloqueio automático |
| Teste que lê o `~/.hermes` real | `sandbox.violation` / diff dentro × fora | falha só dentro da sandbox | TASK de isolamento |

## Direção

1. **Emissão:** eventos v1 (`$GINGA_EVENTS`) ganham `heartbeat`, `cost`, `judge.verdict` e `sandbox.*`, com a correlação `trace_id` PLAN → TASK → attempt → chamada de ferramenta.
2. **Transporte:** spans OTLP + OpenInference → `ginga serve /v1/traces` (nosso, MIT) e, opcionalmente, Phoenix/Jaeger (`GINGA_OTLP_ENDPOINT`). Ver `design/ginga-revamp/09-observabilidade.md`.
3. **Detecção:** o vigia no `ginga tick` usa regras **determinísticas** (sem LLM), versionadas em arquivo e testáveis.
4. **Ação:** as regras alimentam a rota de falhas do manda (breaker, desbloqueio, degrau), o Discord (só o crítico) e a Roda (painéis).
5. **Situação × visão:** é regenerada no fim de cada onda a partir do estado (PLANs, receipts, merges), e não escrita à mão.

## Saída esperada

`SPEC-0003-observabilidade-operacional`, com emendas nos PLAN-0004 (schema), 0008 (rota de falhas), 0010 (tick/notifier), 0012 (Roda) e 0014 (métricas).
