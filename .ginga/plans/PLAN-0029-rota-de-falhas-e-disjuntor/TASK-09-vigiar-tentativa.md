---
type: task
mode: padrao
goal: "manda run observa a tentativa a cada 30 s, espera se devagar ou na fila, e se travada ou recusada mata, abre o disjuntor e segue com o próximo modelo da escada"
title: O manda run vigia a tentativa
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: [TASK-01-classificar-tentativa, TASK-05-env-runtime, TASK-06-free-retry, TASK-07-classificar-blocked, TASK-08-judge-cota]
tier: medium
touch: [src/run.ts, src/attempt_watch.ts, tests/attempt_watch.test.ts]
done_when: "bun test tests/attempt_watch.test.ts"
tests_frozen: [tests/attempt_watch.test.ts]
pinga_task: T307
---
## Fazer
- Amostra `RunObs` (bytes do stream, CPU do pid, mtime da worktree); `classifyRun`; `travado` → probe → kill pelo pid, `recordFailure`, `pickModel`; `recusado` → `recordFailure`, `pickModel`; sucesso → `recordSuccess`. Sem modelo → `waitForFree`. Cada troca emite `attempt` com `failure`.
## Interface
- `export async function watchAttempt(o: { sample: () => Promise<RunObs>; kill: () => void; probe: (m: string) => Promise<{ ok: boolean }>; db: Database; model: string; cfg: { patience_min: number; no_progress_min: number }; sleep: (ms: number) => Promise<void> }): Promise<{ outcome: "done" | "switched" | "waiting"; next?: string }>`. Teste: sequência de amostras falsas para cada estado → ação esperada; disjuntor gravado no db.
## Não fazer
- Sem relógio real (sleep injetado).
## Contexto
- `src/run.ts`, `src/pipeline.ts` (`hasRealProgress`, `killByPid`).
