---
type: plan
title: ginga tick/serve com lease + porta de notificação (Hermes)
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: done
repos: [ginga, p-inga]
depends_on: [PLAN-0005-pinga-task-e-plan, PLAN-0007-manda-nucleo]
done_when: "cd ginga && bun test && bun test tests/tick_parallel.test.ts"
---
## Objetivo

O async começa no PLAN aprovado: `ginga tick` despacha TASKs desbloqueadas para o `manda` sem nunca despachar a mesma duas vezes, `ginga serve` e os timers chamam o mesmo tick, e os eventos viram notificação pela porta (Hermes → webhook do Discord → stdout).

## Abordagem

- `state.db` (bun:sqlite) em `.ginga/state/state.db`: execução, lease, offset de eventos, custo, thread por PLAN. O contrato continua nos arquivos (doc 04 §5).
- Status de "feito" vem dos receipts: o tick lê `pinga queue --json` (PLAN-0005 TASK-06), não o ledger direto.
- Claim com `BEGIN IMMEDIATE` + `UPDATE ... WHERE lease_until < now`: idempotente entre processos. Base: `p-inga/src/queue.ts` (`claim` l. 382, `release` l. 417).
- Notificação (DECISION-0002): Hermes é o adapter padrão (`hermes send -t <plataforma:chat[:thread]>`, sem LLM); fallbacks webhook do Discord (porte de `p-inga/src/discord.ts`) e stdout. Regras de 05 §6, configuráveis em `[notify]`.
- `serve` neste PLAN só escuta em `127.0.0.1` (auth no PLAN-0011).
- **Execução:** TASKs como `tasks/T<N>/PLAN.md` ou do bundle com `--root` (PLAN-0005 fechado).

## TASKs

1. [TASK-01](TASK-01-state-db.md): `state.db` + ingestão de eventos por offset
2. [TASK-02](TASK-02-tick-lease.md): `ginga tick` com claim/lease
3. [TASK-03](TASK-03-serve-timers.md): `ginga serve` + systemd timer + cron do Hermes
4. [TASK-04](TASK-04-notifier-port.md): porta de notificação (hermes, discord, stdout)
5. [TASK-05](TASK-05-event-router.md): event router com as regras de 05 §6
6. [TASK-06](TASK-06-pinga-sem-discord.md): o pinga deixa de notificar direto (A4)

## ACs da SPEC cobertos

- `ginga tick` idempotente com claim e lease; `serve`, systemd timer e cron do Hermes chamam o mesmo tick.
- Porta de notificação Hermes com fallback para webhook do Discord e stdout (a resposta na thread fecha no PLAN-0011).
- Cada ferramenta emite em `$GINGA_EVENTS` e funciona sem ele (ginga consome e roteia).

## Riscos

- `p-inga/src/discord.ts:58` tem um canal padrão fixo (`<DISCORD_HOME_CHANNEL_ID>`) e lê `~/.hermes/profiles/pinga/.env`: o porte não leva nenhum dos dois.
- "Quota disponível" no tick depende do PLAN-0014 (leitura de quota); aqui é um stub que só olha `quota_exhausted` recente nos eventos.
- Ticks concorrentes em máquinas diferentes não são cobertos (DECISION-0002: um host por workspace).
