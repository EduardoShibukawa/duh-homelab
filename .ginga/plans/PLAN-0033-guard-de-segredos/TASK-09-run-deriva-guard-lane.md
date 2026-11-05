---
type: task
mode: padrao
goal: "o manda run deriva GINGA_GUARD_LANE=<PLAN>/<TASK> (herdando a do processo quando a lane já exportou) e preenche request.env, mantendo o guard ligado com falha fechada no run real"
title: manda run deriva a sessão do guard (achado do judge)
plan: PLAN-0033-guard-de-segredos
repo: manda
depends_on: [TASK-07-manda-runtimes]
pinga_task: T320
tier: medium
touch: [src/run.ts, src/runtime/env.ts, tests/run_guard_lane.test.ts]
done_when: "bun test tests/run_guard_lane.test.ts && bun test"
tests_frozen: [tests/run_guard_lane.test.ts]
---
## Achado do judge (manda.json 2026-11-01, verdict fail, TASK-07/AC grave)

`tests/runtime_guard.test.ts` passa, mas nada em `src/` exporta `GINGA_GUARD_LANE=<PLAN-TASK>` (`env.ts` só lê `base.GINGA_GUARD_LANE`) e `src/run.ts` (construção do `request`, ~456-530) não define `request.env`. Em produção `req.env` é `undefined`, então `guardOn()` é false no `manda run` real: `pi.ts`/`opencode.ts` nunca ativam o guard — sem `-e`, sem `OPENCODE_CONFIG_DIR`, sem `guard_missing`.

## Fazer
- Em `src/run.ts`, na construção do `RunRequest`: `request.env = runtimeEnv({ ...process.env, G: ctx.root, GINGA_GUARD_LANE: process.env.GINGA_GUARD_LANE ?? `${ctx.plan}/${shortTaskId(task.task)}`.toLowerCase() })`. A marca do processo (exportada por `lane.sh`/`dispatch-task.sh` via `guard_export`) vence; sem ela, deriva `<PLAN>/<TASK>` em minúsculas (ex.: `plan-0033/task-07`).
- `runtimeEnv` (env.ts) já carimba `GINGA_GUARD` (padrão `enforce`) e `GINGA_GUARD_LOG` quando há lane — confira que o caminho default usa `G` (ex.: `<root>/handoffs/guard.events.jsonl`); ajuste se necessário sem quebrar `tests/runtime_env.test.ts` nem `tests/runtime_guard.test.ts`.
- Falha fechada no run real: com guard ligado e `GUARD_DIR` (do env do processo, herdado) sem `contrib/guard/pi.ts`, o adapter pi/opencode já devolve `guard_missing` sem spawn — o teste RED do run prova isso de ponta a ponta com `resolveRuntime` injetado.

## RED (escrito pelo operador, congelado)

`tests/run_guard_lane.test.ts`, no estilo de `tests/run.test.ts` (workspace `mktemp` + git + `runPlan` com `resolveRuntime` injetado):
1. `request.env.GINGA_GUARD_LANE === "plan-0001/task-01"` (derivado), `guardOn(env)` true, `GINGA_GUARD=enforce` e `GINGA_GUARD_LOG` com `handoffs/guard.events.jsonl`;
2. `process.env.GINGA_GUARD_LANE` preset → o request herda o valor do processo, sem sobrescrever;
3. `process.env.GINGA_GUARD=off` → `guardOn(request.env)` false (guard inerte, sessão do dono);
4. adapter pi real (`createPiRuntime` com `spawnFn` falso) + `GUARD_DIR` vazio → `results[0].failure === "guard_missing"`, exit 1, spawn não chamado;
5. `GUARD_DIR` com `contrib/guard/pi.ts` → spawn chamado com `-e <GUARD_DIR>/contrib/guard/pi.ts` e env do spawn com `GINGA_GUARD_LANE` derivado.

## Não fazer
- Não enfraqueça o guard: sem `GINGA_GUARD_LANE` no processo, o run de PLAN continua com guard ligado (a derivação é o padrão, não o opt-in).
- Não toque em `tests/runtime_guard.test.ts` nem `tests/runtime_env.test.ts` (congelados de TASKs anteriores). Não mude `touch`/`done_when`/`goal`.
- Não importe código do ginga; o guard continua consumido por caminho (`GUARD_DIR`, padrão checkout main do ginga).

## Contexto
- Correção do verdict fail do judge no TASK-07; destrava o merge-gate do PLAN-0033 (além do exit 2 de main suja, que é pendência do dono — ver `decisoes.md`).
