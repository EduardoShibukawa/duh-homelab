# TASK-12 — PLAN-0023 follow-up 8

- **PLAN:** PLAN-0023-vigia-e-supervisor
- **Repo:** ginga
- **Pinga task:** T39

## Objetivo
Corrigir achados do judge do PLAN-0023 (rodada 22:25):
- `main_moved_outside_gate` compara SHA de `refs/heads/main` entre ticks (não progresso);
- `no_progress` aciona `kill_and_retry` e `rotate_model`;
- `goal_reached` pareia `start`/`end` por ordem temporal.

## done_when
`bun test tests/watch_followup8.test.ts`
