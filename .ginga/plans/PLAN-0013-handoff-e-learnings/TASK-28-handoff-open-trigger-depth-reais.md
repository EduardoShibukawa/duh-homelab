---
type: task
mode: padrao
goal: "O evento handoff emitido pelo --open sai com trigger e depth REAIS (das opts), nunca 'cache'/0 fixos (ressalva do judge 2026-11-01: src/handoff/open.ts:83 e open_claude.ts)"
title: Follow-up do judge — trigger/depth reais no evento do --open
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T319
depends_on: [TASK-25-handoff-hook-raiz-model-trigger]
tier: free
touch: [src/handoff/open.ts, src/handoff/open_claude.ts, src/verbs/handoff.ts, tests/handoff_open_trigger.test.ts]
done_when: "bun test tests/handoff_open_trigger.test.ts"
tests_frozen: [tests/handoff_open_trigger.test.ts]
---
## Fazer
- `OpenSessionOpts` (src/handoff/open.ts) ganha `trigger?: string` e `depth?: number`.
- `openSession` emite kind=handoff com `data.trigger = o.trigger ?? "manual"` e `data.depth = o.depth ?? 0` — nos dois caminhos (claude em open_claude.ts e demais runtimes em open.ts). Nunca "cache"/0 fixos.
- O verbo `handoff --open` (src/verbs/handoff.ts) passa `trigger: trigger ?? "manual"` e `depth: args.depth !== undefined ? Number(args.depth) : undefined` para o openSession. Sem `--open`, o verbo continua emitindo o próprio evento (nada muda).
- Evento emitido deve passar em `validateEvent` (trigger "manual" já é aceito pelo enum desde a TASK-25; depth segue como campo numérico extra).
## Interface
- `openSession(runtime, o)` com `o = { handoffPath, userPrompt, model, cwd, spawn, trigger?, depth?, now? }`.
- RED (tests/handoff_open_trigger.test.ts, T319): openSession sem trigger → evento com trigger "manual"; com `depth: 2` → `depth: 2`; claude com `trigger: "idle", depth: 3` → evento com esses valores. Hoje saem "cache"/0 fixos → RED.
## Não fazer
- Não mudar o comportamento sem `--open`; não tocar nos demais testes frozen (tests/handoff_open.test.ts etc.).
- Sem scripts de depuração fora do `touch` (use /tmp).
## Contexto
- Judge 2026-11-01 02:05 (gate 0, mergeado 813274d), ressalva: "o evento do --open sai com trigger 'cache' e depth 0 fixos (src/handoff/open.ts:83), ajuste que a TASK-25 já adiou". Worktree `ginga-plan-0013` (branch plan/0013, main mergeada).
