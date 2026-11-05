# TASK-13 — PLAN-0023 follow-up 9

- **PLAN:** PLAN-0023-vigia-e-supervisor
- **Repo:** ginga
- **Pinga task:** T40

## Objetivo
Corrigir achado do judge do PLAN-0023 (rodada 22:31):
- `main_moved_outside_gate` não avalia sem SHA de main (resultado `unknown` + alerta `warn` "sem SHA de main no heartbeat"), em vez de cair no `progress`.

## done_when
`bun test tests/watch_followup9.test.ts`
