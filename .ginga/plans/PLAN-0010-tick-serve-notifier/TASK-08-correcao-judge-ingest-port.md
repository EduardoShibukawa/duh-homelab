---
type: task
plan: PLAN-0010-tick-serve-notifier
title: "Correção dos achados do judge: ingest por root + fetch no port"
---

# TASK-08: correção dos achados do judge (rodada 2)

- `src/state/ingest.ts`: `ingestEvents` passa a aceitar `root`/`dbPath` e abrir o state.db pelo root configurado (não pelo cwd).
- `src/serve.ts`: `routePending` chama `ingestEvents(eventsPath, root)` antes de rotear.
- `src/notify/port.ts`: fallback Discord usa `fetch` com padrão global (já) — garantir robustez.
