---
type: task
mode: padrao
goal: "corrige o achado grave do judge (merge-gate exit 11, 23:20) no TASK-12: o sampler real roda o probe de verdade (probe_ok real, null quando não sondado) e na_fila volta a ser alcançável; watchAttempt não mata quando o probe diz ok; o stop do fluxo principal não aborta o waitForFree depois que a vigia assumiu a falha (onTakeOver); stream_bytes/since_last_event_s medem o log do stream da própria tentativa (logPath por tentativa), não o $GINGA_EVENTS compartilhado"
title: Corrigir a vigia ao vivo real (probe no sampler, probe ok não mata, stop após kill, stream da tentativa)
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: [TASK-12-ligar-vigia-ao-vivo-no-run]
tier: medium
touch: [src/run_state.ts, src/proc_sample.ts, src/attempt_watch.ts, src/run.ts, src/runtime/port.ts, src/runtime/opencode.ts, src/runtime/pi.ts, src/runtime/claude.ts, src/runtime/codex.ts, tests/attempt_watch_real.test.ts]
done_when: "bun test tests/attempt_watch_real.test.ts tests/attempt_watch.test.ts tests/attempt_watch_live.test.ts tests/attempt_watch_run.test.ts tests/run_state.test.ts"
tests_frozen: [tests/attempt_watch_real.test.ts]
pinga_task: T310
---
## Fazer
- `src/run_state.ts`: `RunObs.probe_ok` vira `boolean | null` (null = não sondado). `classifyRun` sem mudança de semântica (`=== true` / `=== false` já tratam null como "não sondado").
- `src/proc_sample.ts`: `ProcSampleTarget` ganha `model?`, `probe?: (m: string) => Promise<{ ok: boolean }>` e `cfg`. No sampler: `probe_ok` começa `null`; se há probe e (`stream_bytes === 0` OU (`since_last_event_s >= no_progress_min*60` && `cpu_pct < 1` && `!files_changed`)) → roda o probe e preenche `probe_ok` (probe lançando = false). Senão fica null.
- `src/attempt_watch.ts` (`watchAttempt`, assinatura obrigatória preservada, `onTakeOver?: () => void` opcional novo):
  - ramo `travado`: se o probe devolver ok → **não mata, não registra falha, não emite attempt** — dorme `ATTEMPT_POLL_MS` e continua amostrando (modelo saudável e lento não é morto);
  - se o probe falhar (ou `recusado`): a vigia **assume** a falha (`ownsOutcome = true`, chama `onTakeOver?.()`), e a partir daí `stop()` é ignorado (o `waitForFree` segue com backoff de verdade em vez de abortar no `stopWatch` do fluxo principal);
  - kill continua só no probe falha.
- Stream da própria tentativa: `RunRequest.logPath?` (port.ts), `SpawnFn` opts ganham `logPath?`, `defaultSpawn` faz tee de stdout/stderr para o arquivo (append, criando diretório); os 4 adapters (opencode, pi, claude, codex) repassam `logPath: req.logPath`.
- `src/run.ts`: cada tentativa ganha `request.logPath = <root>/runs/<plan>/<TASK>-attempt-<n>.log`; o sampler real (`realWatchHooks`, exportada para teste) recebe esse caminho como `streamPath` (e `model`/`probe`/`cfg` para o probe do sampler) — **não** usa mais `process.env.GINGA_EVENTS`; `stopWatch`/`stopResolve` só ligam quando a vigia não assumiu (`onTakeOver` não disparou).
## Teste (RED novo, tests/attempt_watch_real.test.ts)
- sampler: stream vazio → probe chamado, `probe_ok: true`, `classifyRun` = `na_fila`; stream crescendo → probe não chamado e `probe_ok: null`; silêncio longo + cpu baixo → probe chamado e `probe_ok: false` → `travado`;
- `watchAttempt`: travado com probe ok → sem kill, disjuntor fechado, outcome `done`; travado com probe falha + `stop` ligado no kill → `onTakeOver` chamado, `waitForFree` não aborta → `switched` com `next` (modelo com probe ok);
- `defaultSpawn` com `logPath` grava o stdout no arquivo; adapter opencode repassa `logPath` ao spawn;
- `realWatchHooks` com `streamPath` próprio: `stream_bytes` vem desse arquivo mesmo com `$GINGA_EVENTS` apontando para outro (maior);
- `runPlan` (fixture git como no live): `request.logPath` definido por tentativa e, com disjuntores abertos nos free, o `attempt` emitido pela vigia traz `next_model` (waitForFree não abortado pelo stop pós-kill).
## Não fazer
- Não mexer nos testes congelados antigos (`attempt_watch.test.ts`, `attempt_watch_run.test.ts`, `attempt_watch_live.test.ts`, `run_state.test.ts`); não mudar a assinatura obrigatória de `watchAttempt`; não usar `$GINGA_EVENTS` como stream da tentativa.
## Contexto
- Achado do judge em `judge/manda-20261031T224624.log` (TASK-12 grave): `proc_sample.ts:~118` probe_ok fixo false; `attempt_watch.ts:~150` mata mesmo com probe ok; `run.ts:~520` stopWatch aborta o waitForFree; `run.ts:250` stream de `$GINGA_EVENTS`.
