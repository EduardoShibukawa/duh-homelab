---
type: task
mode: mvp
goal: "ginga handoff hook lê o JSON do runtime no stdin, roda decideHandoff, grava o handoff em prepare/redirect e responde no formato do Claude e do Codex, medindo o contexto pelo usage do transcript"
title: ginga handoff hook --runtime
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T151
depends_on: [TASK-11-handoff-sessao]
tier: free
touch: [src/handoff/hook.ts, src/handoff/transcript_usage.ts, src/verbs/handoff.ts, tests/handoff_hook.test.ts, tests/fixtures/transcripts/]
done_when: "bun test tests/handoff_hook.test.ts"
tests_frozen: [tests/handoff_hook.test.ts, tests/fixtures/transcripts/]
---
## Fazer
- stdin `{session_id, transcript_path, cwd, prompt?, hook_event_name}`; `UserPromptSubmit` → evento `prompt`, `Stop` → `turn_end`. Prompt começando com `!!` ignora o gatilho. Estado (um redirect por sessão, `depth`, último handoff) em `.ginga/state/handoff-<session>.json`.
- `redirect` → `{decision: "block", reason: "sessão nova <id>: claude attach <id>"}` (a abertura é da TASK-13; aqui o `reason` usa o id devolvido por ela ou o caminho do handoff); `prepare` → grava o handoff e sai sem bloquear.
## Interface
- `transcriptUsage(path: string): { contextTokens: number; lastApiTs: Date | null }` (soma `input + cache_read + cache_creation` do último `usage`; ausente → `-1`); `runHook(runtime: string, stdin: string, deps: { now: Date; open?: (...) => Promise<{ sessionRef: string }> }): Promise<{ decision?: "block"; reason?: string }>`. Teste: transcripts redigidos (frio e ocioso; 120k; `!!`; não interativo) → saída exata.
## Não fazer
- Nenhuma lógica de decisão fora do `decideHandoff`.
## Contexto
- Doc 11 §3 (proposta TASK-10 de lá).
