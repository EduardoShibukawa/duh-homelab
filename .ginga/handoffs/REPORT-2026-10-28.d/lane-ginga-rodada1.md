# Lane ginga, rodada 1 — operador

## Item 1 — PLAN-0010-tick-serve-notifier (branch plan/0010)

- judge findings: fetch no serve, ingest antes de rotear, thread_id — resolvidos em código (src/serve.ts routePending passa fetch; chama ingestEvents; resolveStateDbPath(root); src/notify/port.ts retorna thread_id).
- merge main: fast-forward 2a27383 → 657c4af (HEAD == main).
- TASKs PLAN-0010: T19, T20, T21, T22, T23, T24, T26 — receipt pass (seqs 469, 475, 481, 483, 448, 457, 478).
- bun test: tests/serve.test.ts + notify_port + notify_thread_id + event_router + state_db = 41 pass / 0 fail.
- ready: .ginga/plans/PLAN-0010-tick-serve-notifier/ready/ginga.json = {"branch":"plan/0010"}.

## Item 2 — PLAN-0020-cost-usd-validation (branch plan/0020)

- já mergeado na main; T24 receipt pass (seq 457).
- bun test: tests/events_validate_cost.test.ts = 2 pass / 0 fail.
- ready: .ginga/plans/PLAN-0020-cost-usd-validation/ready/ginga.json existente.

## Backlog

- [x] PLAN-0010 (ginga): ready/ginga.json gravado.
- [x] PLAN-0020 (ginga): verificado, ready existente.
