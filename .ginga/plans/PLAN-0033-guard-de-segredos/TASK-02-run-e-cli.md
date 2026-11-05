---
type: task
mode: padrao
goal: "guardCall/guardResult aplicam escopo (GINGA_GUARD_LANE), modos enforce|shadow|off, evento JSONL sem o segredo e falha fechada; cli.ts expõe check e redact"
title: Escopo, modos, eventos e CLI
plan: PLAN-0033-guard-de-segredos
repo: ginga
pinga_task: T301
depends_on: [TASK-01-core-e-lista]
tier: free
touch: [src/guard/run.ts, src/guard/cli.ts, tests/guard_run.test.ts]
done_when: "bun test tests/guard_run.test.ts"
tests_frozen: [tests/guard_run.test.ts]
---
## Fazer
- `mode(env)`: `off` sem `GINGA_GUARD_LANE`; senão `GINGA_GUARD` (`enforce` padrão | `shadow` | `off`).
- `guardCall(tool, input, {env,cwd,home,deny})`: `off` libera; `enforce` devolve o veredito do core; `shadow` registra e libera; **exceção interna** vira `{block:true, rule:"guard_error"}` em `enforce` e libera em `shadow`.
- `guardResult(text, opts)`: `redact` com os formatos de chave e os **valores** das variáveis de ambiente cujo nome casa `KEY|TOKEN|SECRET|PASSWORD|CREDENTIAL` (≥ 12 caracteres); exceção em `enforce` devolve `[REDACTED:guard_error]`.
- Evento JSONL em `GINGA_GUARD_LOG` (se definido): `{ts, lane, event: guard.block|guard.redact|guard.error, tool, rule, mode, call: sha256[:12] do input}`. Nunca o trecho que casou. Falha ao gravar o log é ignorada.
- `src/guard/cli.ts`: `check` (stdin JSON `{tool,input,cwd?,home?}`; exit 0 libera, 2 bloqueia com `{block,rule,reason}` no stdout, 1 erro interno) e `redact` (stdin → stdout). Outros verbos: exit 64.
## Interface
- Protótipo validado: [ref/ginga/src/guard/run.ts](../ref/ginga/src/guard/run.ts) e `cli.ts` (sem o verbo `sweep`, que é da TASK-08).
## Não fazer
- Não tocar tests_frozen. Não gravar o evento com `input` bruto. Não ler `GINGA_GUARD_LANE` fora de `mode()`.
## Contexto
- Falha fechada é decisão do Planner (PLAN-0033 "Decisões"); o oposto do PLAN-0032.
