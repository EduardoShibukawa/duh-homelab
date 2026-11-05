---
type: task
mode: padrao
goal: "syncCost grava o evento cost com ts = time_created da sessão (não a hora do sync) e atribui plan/task a partir do diretório da sessão (worktree <repo>-plan-NNNN, tasks/T<N>), corrigindo a quota do zen, o cap_ok do tick, o cost por dia/--since e o cost_by por PLAN/SPEC"
title: Correção do ts e do plan/task no sync do opencode.db
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-07-custo-opencode-db]
tier: free
pinga_task: T366
touch: [src/cost/opencode_db.ts, src/verbs/cost.ts, tests/cost_sync_ts.test.ts]
done_when: "bun test tests/cost_sync_ts.test.ts tests/cost_opencode_db.test.ts tests/quota.test.ts tests/quota_cap.test.ts tests/cost_cli_coverage.test.ts"
tests_frozen: [tests/cost_sync_ts.test.ts]
---
## Fazer
- Achado grave do judge 2026-11-03T05:35 (gate 11 no PLAN-0014, reprovou TASK-07 e o AC): `syncCost` (`src/cost/opencode_db.ts`) grava `ts = new Date().toISOString()` (hora do sync) na coluna `ts` e no envelope. Deve usar `session.created` (ISO do `time_created` lido do opencode.db). Reproduzido pelo judge: sessão de 2026-10-05 com US$40 vira evento de 2026-11-03 → `readQuotas` devolve zen `used_pct: 400` → `quotaCapOk` false → `src/tick.ts:595` para de despachar; distorce `ginga cost` por dia (`src/verbs/cost.ts`) e `--since`.
- Atribuição de plan/task (limitação do AC): exporte `planTaskForDirectory(root: string, directory: string): { plan: string | null; task: string | null }` em `src/cost/opencode_db.ts`. Dado o bundle `root` (`<ws>/.ginga`, mesmo `ctx.root` dos verbos):
  - qualquer componente do caminho `directory` com basename `^(.*)-plan-(\d{4})$` (ex.: `ginga-plan-0014`) → número do PLAN; resolva o nome completo em `join(root, "plans")` procurando o diretório `PLAN-<NNNN>-*` com `PLAN.md` (fallback: `PLAN-<NNNN>`);
  - componente `tasks/T(\d+)` no caminho → `task = "T<numero>"` (ex.: `tasks/T366` → `T366`);
  - sem esses componentes → `{ plan: null, task: null }`.
- `syncCost(db, sessions, resolve?)`: novo terceiro parâmetro opcional `resolve?: (directory: string) => { plan: string | null; task: string | null }`. A qualquer chamada, `ts` da coluna e `event.ts` = `session.created`; se `resolve` for passado, grave os colunas `plan`/`task` e os campos `plan`/`task` do envelope JSON com o resultado (nulo quando não houver). Sem `resolve`, comportamento atual de plan/task nulos. A assinatura antiga de 2 argumentos deve continuar funcionando (`tests/cost_opencode_db.test.ts` é frozen e chama com 2 args).
- `costSync` (`src/verbs/cost.ts`): passe `resolve = (dir) => planTaskForDirectory(ctx.root, dir)`.
## RED
- `tests/cost_sync_ts.test.ts` (novo, seu): falha antes da mudança e passa depois:
  1. sessão com `time_created` = 2026-10-05T12:00:00.000Z → após `syncCost`, a coluna `ts` e o `event.ts` do evento são exatamente essa ISO (não a data de hoje);
  2. `readQuotas({ home: <tmp vazio>, db })` com esse único evento de US$40 de outubro → quota `zen` do mês corrente tem `used_pct === 0` (hoje devolve 400 e `quotaCapOk` fica falso);
  3. `planTaskForDirectory(bundle, "/ws/ginga-plan-0014")` → `{ plan: "PLAN-0014-metricas-e-quota", task: null }` (bundle falso com `plans/PLAN-0014-metricas-e-quota/PLAN.md`); `"/ws/ginga-plan-0014/tasks/T366"` → `task: "T366"`; `"/ws/ginga"` → nulos. `syncCost` com `resolve` grava as colunas `plan`/`task`;
  4. `computeMetrics(db, { root: bundle })` inclui o custo no `cost_by.plan` do PLAN.
## Não fazer
- Não altere `tests/cost_opencode_db.test.ts` nem `tests/fixtures/opencode-db.sql` (frozen da TASK-07); o teste novo monta o próprio opencode.db temporário. Não mude `readOpencodeSessions`, `costSummary`, `zenQuota` ou `src/tick.ts` — a correção é só o `ts` gravado. Nunca escrever no opencode.db.
## Contexto
- Correção do achado grave do judge 2026-11-03T05:35 (gate exit 11, PLAN-0014): TASK-07/AC reprovados porque o custo importado entra com a data do sync e sem plan/task. Consulta de referência da TASK-07: `select date(time_created/1000,'unixepoch'), sum(cost) from session_v2 group by 1`.
