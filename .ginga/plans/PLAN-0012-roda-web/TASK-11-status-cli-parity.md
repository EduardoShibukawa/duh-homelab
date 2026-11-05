---
type: task
mode: padrao
goal: "ginga status --json pela CLI devolve o mesmo JSON do runVerb direto no processo (relógio determinístico e caminho de eventos resolvido igual nos dois lados, sem depender de $GINGA_EVENTS do ambiente)"
title: Paridade CLI × runVerb do verbo status
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-10-status-json]
tier: free
touch: [src/status.ts, src/verbs/read.ts, src/cli.ts, tests/status_cli_parity.test.ts]
done_when: "bun test tests/status_cli_parity.test.ts tests/status_json.test.ts tests/cli_verbs.test.ts"
tests_frozen: [tests/status_cli_parity.test.ts]
pinga_task: T324
---
## Fazer
- Corrigir a regresssão de suíte deixada pelo feat(T323): `tests/cli_verbs.test.ts` (frozen do PLAN-0011, não alterar) falha em "ginga status --json devolve o mesmo JSON que o run direto" — o subprocesso da CLI tem `$GINGA_EVENTS=<arquivo inexistente>` e reporta `broken_sources` com 1 item; o runVerb direto no processo de teste não tem a variável e reporta `[]`. Além disso `generated_at` usava relógio real (2 chamadas distintas).
- Contrato: o caminho de eventos resolve para `$GINGA_EVENTS` quando definida, senão para `events.jsonl` no diretório do state.db (`db.filename`); `buildStatus` usa essa resolução nos dois lados. O relógio padrão deve ser determinístico por db (ex.: `MAX(ts)` da tabela `events`, ou epoch na ausência) — quem passa `now` explícito (teste) usa o relógio dado.
- `tests/status_json.test.ts` (frozen do TASK-10) segue valendo: com `$GINGA_EVENTS` definida para arquivo inexistente → `broken_sources` com 1 item, sem abortar.
## Interface
- Teste frozen novo `tests/status_cli_parity.test.ts`: fixture com 1 PLAN draft + 1 evento no state.db; roda `bun bin/ginga.ts status --json --root <bundle>` num subprocesso com `GINGA_STATE_DB`/`GINGA_EVENTS` (events.jsonl inexistente ao lado do db) e compara com `runVerb("status", ctx)` direto (com `$GINGA_EVENTS` removida do ambiente do processo) — JSON idênticos.
## Não fazer
- Não alterar `tests/cli_verbs.test.ts` nem `tests/status_json.test.ts` (frozen alheios); não tocar em `src/state/db.ts`; sem LLM/rede; sem gravar nada.
## Contexto
- WIP não commitado em `src/status.ts`/`src/verbs/read.ts` na worktree (relógio determinístico + intents/specs no verbo status) faz parte desta entrega — commitar como feat(T324).PLAN-0011 TASK-02 (T127/T131): a CLI é gerada do registro e `--json` imprime exatamente o resultado do `run`.
