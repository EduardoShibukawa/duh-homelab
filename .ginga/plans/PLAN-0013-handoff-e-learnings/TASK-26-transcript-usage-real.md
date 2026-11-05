---
type: task
mode: mvp
goal: "transcriptUsage lê o usage no formato real do transcript do Claude (message.usage), mantendo compat com usage na raiz dos fixtures antigos — corrige o grave do judge 2026-11-01 (AC handoff automático / TASK-12): no uso real contextTokens fica -1, lastApiTs null e nenhum gatilho dispara"
title: transcript real (message.usage) no hook de handoff
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T316
depends_on: [TASK-12-handoff-hook, TASK-19-handoff-hook-cli-correcao]
tier: free
touch: [src/handoff/transcript_usage.ts, tests/handoff_transcript_real.test.ts]
done_when: "bun test tests/handoff_transcript_real.test.ts tests/handoff_hook.test.ts"
tests_frozen: [tests/handoff_transcript_real.test.ts]
---
## Fazer
- Em `src/handoff/transcript_usage.ts`, ler `const u = event.message?.usage ?? event.usage` (formato real do Claude: `message.usage`; raiz fica como fallback dos fixtures antigos). Último `assistant` com usage vence; `lastApiTs` continua vindo do `timestamp` da raiz da linha.
- Não mudar a assinatura nem o contrato (`{ contextTokens, lastApiTs }`); não tocar nos fixtures antigos de `tests/fixtures/transcripts/` (frozen da TASK-12) — o teste novo usa transcripts inline no formato real.
## Interface
- Teste congelado `tests/handoff_transcript_real.test.ts` (já escrito, RED): message.usage → soma input+cache_read+cache_creation e lastApiTs; sem usage → -1/null; usage na raiz (formato antigo) continua aceito.
- `tests/handoff_hook.test.ts` (frozen da TASK-12) segue verde sem Änderung.
## Não fazer
- Não alterar `decideHandoff` nem o resto do hook; não editar os fixtures frozen; sem scripts de depuração fora do touch (use /tmp).
## Contexto
- Judge 2026-11-01T00:19 (grave, gate exit 11): `src/handoff/transcript_usage.ts:21` lê `event.usage` na raiz; transcript real do Claude Code desta máquina tem `message.usage` → hook não dispara idle/context no uso real.
