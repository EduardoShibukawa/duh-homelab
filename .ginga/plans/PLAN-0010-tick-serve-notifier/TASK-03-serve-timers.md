---
type: task
mode: padrao
goal: "ginga serve roda o tick por timer e por evento; systemd timer e cron do Hermes chamam o mesmo ginga tick"
title: ginga serve + timers
plan: PLAN-0010-tick-serve-notifier
repo: ginga
depends_on: [TASK-02-tick-lease]
tier: medium
pinga_task: T21
touch: [src/serve.ts, src/cli.ts, contrib/systemd/ginga-tick.service, contrib/systemd/ginga-tick.timer, contrib/systemd/ginga-serve.service, docs/hermes-cron.md, tests/serve.test.ts]
done_when: "bun test tests/serve.test.ts && grep -q 'ginga tick' contrib/systemd/ginga-tick.service docs/hermes-cron.md"
tests_frozen: [tests/serve.test.ts]
---
## Fazer
- `serve`: intervalo de `[serve].tick_seconds` + `fs.watch` no `$GINGA_EVENTS` (debounce), sempre a mesma função de `src/tick.ts`.
- Escuta só em `127.0.0.1` (porta `[serve].port`, padrão 4243); `--host` diferente → exit 2 até o PLAN-0011.
- Units `--user` e o passo a passo do cron do Hermes chamando `ginga tick`.
## Não fazer
- Sem API de verbos (PLAN-0011).
## Contexto
- `p-inga/web/server.ts` (Bun.serve), `pi-harness/src/async/wake_coalescer.ts` (debounce).
