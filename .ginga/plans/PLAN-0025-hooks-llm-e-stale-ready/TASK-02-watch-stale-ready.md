---
type: task
mode: padrao
goal: "o vigia move ready/<repo>.json cuja branch não tem commits além da main para ready/done (alerta info stale_ready) e alerta warn ready_writer para ready sem by/at válidos"
title: vigia stale_ready + ready_writer (follow-up 10 do PLAN-0023)
plan: PLAN-0025-hooks-llm-e-stale-ready
repo: ginga
depends_on: []
tier: free
pinga_task: T102
touch: [src/watch/ready.ts, src/watch/index.ts, src/watch/rules.ts, tests/watch_stale_ready.test.ts, tasks/T102/PLAN.md]
done_when: "bun test tests/watch_stale_ready.test.ts"
tests_frozen: [tests/watch_stale_ready.test.ts]
---
## Fazer
- Novo `src/watch/ready.ts` exportando `sweepReady(root: string): Alert[]` (tipo `Alert` de `./evaluate.ts`). Varre `<root>/.ginga/plans/*/ready/*.json` (só arquivos na pasta `ready/`, nunca em `ready/done/`). Repo = nome do arquivo sem `.json`; repo git em `<root>/<repo>`; plano = nome da pasta do PLAN; entidade `<plano>/<repo>`; ignore JSON inválido ou repo inexistente.
- `stale_ready`: se `git -C <root>/<repo> rev-list --count main..<branch>` for 0 (ou a branch não existir), mover o arquivo para `ready/done/<repo>-<YYYYMMDDHHMMSS>.json` (criar `done/`) e devolver alerta `{rule_id:"stale_ready", severity:"info", entity, summary, dedupe_key:"stale_ready:<entity>", actions:["move_to_done"]}`.
- `ready_writer`: se a branch tem commits além da main mas o JSON não tem `by` como objeto com `pid` numérico e `cmd` string não vazia, e `at` string de data válida → alerta `{rule_id:"ready_writer", severity:"warn", ...}` (dedupe_key `ready_writer:<entity>`); o arquivo fica onde está.
- `src/watch/rules.ts` `defaultRules()`: acrescentar `stale_ready` (severity info, action move_to_done) e `ready_writer` (severity warn, action alert), sem mexer nas existentes.
- `src/watch/index.ts` `watchCmd`: depois de `evaluateWatch`, acrescentar `sweepReady(base)` aos alertas quando as regras efetivas contêm o id correspondente (ou são as padrão); os alertas entram no mesmo caminho de emissão/fila/saída `--json`. Idempotente entre ticks.
## Não fazer
- Não alterar `evaluateWatch` nem os tests_frozen dos follow-ups anteriores (`tests/watch_*.test.ts` existentes).
