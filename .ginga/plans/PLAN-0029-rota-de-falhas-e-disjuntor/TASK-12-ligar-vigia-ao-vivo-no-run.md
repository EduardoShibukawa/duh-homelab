---
type: task
mode: padrao
goal: "corrige o achado do judge (merge-gate exit 11, 20:20): src/run.ts passa a chamar watchAttempt ENQUANTO a tentativa roda (amostra /proc/<pid>, mudancas da worktree e probe; travado mata pelo pid via killByPid) e o laco de attemptSpecs consulta breakerOf no state.db, pulando modelo com disjuntor aberto"
title: Liga a vigia ao vivo no manda run
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: [TASK-09-vigiar-tentativa, TASK-11-integrar-vigia-run]
tier: medium
touch: [src/run.ts, src/attempt_watch.ts, src/runtime/port.ts, src/runtime/claude.ts, src/runtime/codex.ts, src/runtime/opencode.ts, src/runtime/pi.ts, src/proc_sample.ts, tests/attempt_watch_live.test.ts]
done_when: "bun test tests/attempt_watch_live.test.ts tests/attempt_watch.test.ts tests/attempt_watch_run.test.ts"
tests_frozen: [tests/attempt_watch_live.test.ts]
pinga_task: T309
---
## Fazer
- `RunRequest` ganha `onPid?: (pid: number) => void`; `SpawnFn` opts ganham `onPid?` e o `defaultSpawn` chama `opts.onPid?.(child.pid)`; os 4 adapters (opencode, pi, claude, codex) repassam `onPid: req.onPid` no spawnFn.
- `RunOptions` ganha `watch?: WatchHooks` (injecao de teste). O default real monta o sampler em `src/proc_sample.ts`: cpu do `/proc/<pid>/stat` (delta utime+stime), `files_changed` via `git status` na worktree, `stream_bytes` pelo tamanho do log/eventos, `probe` via `src/probe.ts` com runner sobre `defaultSpawn`, `kill` = `killByPid` (`src/pipeline.ts`), `cfg` lido de `[routing]` do project.toml (`patience_min`/`no_progress_min`, default 30/15).
- No laco `for (const spec of attemptSpecs)`: com `stateDb` e `fullModel`, se `breakerOf(stateDb, fullModel, new Date()).state === "open"` pula o spec (emite `attempt` com `breaker: "open"`, sem chamar o adapter) — meio-aberto pode tentar.
- Durante `adapter.run(request)`: corre `watchAttempt` em paralelo (sample/kill/probe/sleep do hook, `db: stateDb`, `model: fullModel`, `stop` opcional novo no options de `watchAttempt` — compativel com o teste congelado da T307). Corrida: se o run settle primeiro, liga `stop` e segue o fluxo atual (recordSuccess/planNextAfterFailure + evento `attempt` unico); se o watcher vencer com `switched`/`waiting`, mata pelo pid (o watcher ja chamou kill), espera o run settle como falha e continua o laco sem evento duplicado.
## Teste (RED novo, tests/attempt_watch_live.test.ts)
- disjuntor aberto para `opencode/f1` no state.db → a chamada do adapter vai direto para `f2`;
- amostra `travado` → `kill` chamado com o pid exposto por `onPid` (4321), modelos chamados `["f1","f2"]`, `model_breaker` registra `opencode/f1`.
## Não fazer
- Não mudar `tests/attempt_watch.test.ts` nem `tests/attempt_watch_run.test.ts` (congelados); não trocar a assinatura obrigatoria de `watchAttempt`.
## Contexto
- Achado do judge em `judge/manda-20261031T201921.log` (TASK-09/TASK-11 grave): `grep watchAttempt src/run.ts` nao acha chamador; o laco nao consulta `breakerOf`.
