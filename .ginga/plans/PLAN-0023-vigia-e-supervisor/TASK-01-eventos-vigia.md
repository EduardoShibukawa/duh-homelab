---
type: task
mode: padrao
goal: "Schema v1 aceita os kinds do vigia — heartbeat{entity,pid,progress}, lane.round{lane,phase}, gate.result{plan,repo,code}, alvo.check{check,ok} — com fixtures dos 6 incidentes (no_progress, lane_dead, main_moved_outside_gate, judge_shopping, report_mismatch, goal_reached) que passam no validateEvent"
title: heartbeat/progress, lane.round, gate.result, alvo.check + fixtures dos 6 incidentes
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: []
tier: free
pinga_task: T28
touch: [src/events/validate.ts, tests/events_watch_kinds.test.ts, tests/fixtures/watch/, tasks/T28/PLAN.md]
done_when: "bun test tests/events_watch_kinds.test.ts"
tests_frozen: [tests/events_watch_kinds.test.ts, tests/fixtures/watch/]
---
## Fazer
- Em `src/events/validate.ts`, `KINDS` ganha (formato igual aos kinds de hoje; campos desconhecidos continuam ignorados):
  - `heartbeat`: required [entity, pid, progress]; strings [entity, runtime, last_event_at]; numbers [pid, progress, cpu_pct, attempt_n]; booleans [alive]. `progress` é contador de efeito real (arquivos alterados, commits, receipts, saída de ferramenta) — nunca "processo vivo" nem "log cresceu".
  - `lane.round`: required [lane, phase]; enums { phase: [start, end] }; strings [lane, reason].
  - `gate.result`: required [plan, repo, code]; strings [plan, repo]; numbers [code].
  - `alvo.check`: required [check, ok]; strings [check]; booleans [ok].
- Fixtures dos 6 incidentes em `tests/fixtures/watch/<regra>.jsonl` (letas JSONL, 1..6 eventos v1 por arquivo, com envelope completo v/ts/source/kind/id):
  - `no_progress.jsonl`: heartbeat com progress constante numa janela (executor vivo sem efeito novo).
  - `lane_dead.jsonl`: heartbeat da lane sem progresso novo e com lane.round sem end.
  - `main_moved_outside_gate.jsonl`: mudança em refs/heads/main sem gate.result correspondente.
  - `judge_shopping.jsonl`: 2 vereditos (receipt/judge ou events) para o mesmo HEAD.
  - `report_mismatch.jsonl`: afirmação de pass (receipt não done) — receipt com status fail/blocked ao lado do claim.
  - `goal_reached.jsonl`: gate.result pass de todos os PLANs + alvo.check ok.
- Teste `tests/events_watch_kinds.test.ts`: valida os 4 kinds (campo válido aceito, inválido rejeitado, campo desconhecido ignorado) e carrega cada fixture: todas as linhas passam no `validateEvent`.
## Não fazer
- Não tocar os kinds/behavior existentes (attempt, receipt, transition, blocker, answer, budget, quota, handoff, learning), tests_frozen `tests/events*.test.ts` anteriores nem `tests/events_validate_cost.test.ts`.
- Sem avaliador de regras nem `ginga watch` neste TASK (TASK-02).
## Contexto
- SPEC-0003 (catálogo de sinais) + PLAN-0023 §Desenho/TASKs; TASK-02 consome os fixtures com uma regra por incidente.
