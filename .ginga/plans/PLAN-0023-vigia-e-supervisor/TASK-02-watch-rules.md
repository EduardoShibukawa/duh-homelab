---
type: task
mode: padrao
goal: "ginga watch avalia as regras de .ginga/watch/rules.toml (uma por incidente: no_progress, lane_dead, main_moved_outside_gate, judge_shopping, report_mismatch, goal_reached) contra os eventos da janela e emite alert; um teste por regra contra a fixture de TASK-01"
title: ginga watch (avaliador de rules.toml)
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-01-eventos-vigia]
tier: medium
pinga_task: T29
touch: [src/watch/, src/cli.ts, src/events/validate.ts, tests/watch_rules.test.ts, tests/fixtures/watch/, tasks/T29/PLAN.md]
done_when: "bun test tests/watch_rules.test.ts"
tests_frozen: [tests/watch_rules.test.ts, tests/fixtures/watch/]
---
## Fazer
- kind novo `alert` no schema v1 (SPEC-0003): required [rule_id, severity, entity, summary]; strings [rule_id, entity, summary, dedupe_key]; enums { severity: [info, warn, high, critical] }; data.actions: lista de strings (o verbo da action da regra).
- `src/watch/`: parse de `.ginga/watch/rules.toml` (version = 1, [[rule]] id, signal, condition, window_minutes, threshold, action, severity, discord, dedupe_minutes, fixture) — parse próprio, sem dependência nova (padrão do hooks).
- `ginga watch --root <dir> [--events PATH]`: lê a janela de eventos (estado do state.db do PLAN-0010 ou o arquivo de $GINGA_EVENTS), avalia as 6 regras com as condições do PLAN-0023 §Regras novas e emite `alert` (com dedupe por (rule_id, entity)) e sai 0 (alertas não são erro); `--json` imprime os alertas avaliados.
- Teste por regra contra a fixture de TASK-01 (`tests/watch_rules.test.ts`): fixture do incidente dispara a regra; fixture vazia/janela limpa não dispara.
## Não fazer
- Não implementar as ações (verbos do manda/notifier são TASK-05/outros PLANs); sem headless loops sem timer; sem rede.
## Contexto
- SPEC-0003 §Regras do vigia; PLAN-0023: detectar e agir é determinístico, sem LLM.
