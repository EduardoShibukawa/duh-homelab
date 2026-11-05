---
type: plan
title: Métricas, custo medido, quota automática e A/B nativo vs handoff
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: approved
repos: [ginga]
depends_on: [PLAN-0012-roda-web, PLAN-0013-handoff-e-learnings]
done_when: "cd ginga && bun test"
---
## Objetivo

O dashboard de Métricas mostra FTPR, custo por TASK verificada, falhas por motivo, quota por provider, erros repetidos e as métricas do vigia (contagem por regra, MTTR, custo por alerta); o custo vem do **banco do opencode**, não do `paid-spend.tsv`; a quota do Codex e do Claude é lida sozinha; e o A/B compactação nativa vs handoff do ginga tem estrutura para rodar.

## Decisões (emendas de 2026-10-29)

- **Custo medido pelo `opencode.db`** (`~/.local/share/opencode/opencode.db`, tabela `session_v2`: `cost`, `tokens_*`; modelo no `data` do `session_message`). O `paid-spend.tsv` subnotifica (US$ 0,54 registrados vs US$ 3,55 reais em 27/10) e deixa de ser fonte. A TASK-07 importa o custo como eventos `cost` (`cost_source: reported`) e todas as métricas usam esses eventos.
- **Emendas da SPEC-0003** (TASK-08): contagem de `alert` por regra, MTTR por regra, custo por alerta; FTPR **exclui** `quota_exhausted` e `infra` (que entram só na taxa de falha).
- **Sem `bench/` na raiz:** o A/B (TASK-06) fica no ginga (`src/bench/`, banco próprio `.ginga/state/bench.db`) com a ontologia `experiment → arm → run → event`. Quando a lacuna 9 (porta de bench) ganhar PLAN, ele move. Sem dependência do pi-harness: o `codex_quota.ts` e o `bench/store.ts` de lá são só referência de leitura e serão arquivados pelo PLAN-0017.
- `ginga quota` entra no registro de verbos e alimenta o stub de quota do `tick` (PLAN-0010).

## TASKs

1. [TASK-01](TASK-01-metricas.md): `ginga metrics --json`
2. [TASK-02](TASK-02-quota-codex.md): quota do Codex (rollout JSONL)
3. [TASK-03](TASK-03-quota-claude.md): quota do Claude (statusline) + `ginga quota`
4. [TASK-04](TASK-04-erros-repetidos.md): métrica de erros repetidos
5. [TASK-05](TASK-05-web-metricas.md): telas Métricas e Quota na Roda Web
6. [TASK-06](TASK-06-ab-handoff.md): experimento A/B no bench do ginga
7. [TASK-07](TASK-07-custo-opencode-db.md): custo lido do `opencode.db`
8. [TASK-08](TASK-08-metricas-vigia.md): métricas por regra, MTTR e custo por alerta
9. [TASK-09](TASK-09-cli-verbs-cost.md): cobertura CLI dos verbos `cost sync` e `cost`
10. [TASK-10](TASK-10-cli-verbs-quota.md): cobertura CLI do verbo `quota`
11. [TASK-11](TASK-11-cli-verbs-metrics.md): registro do verbo `metrics` + cobertura CLI (TASK-01 não podia tocar `src/verbs/registry.ts`; precedente TASK-09/TASK-10)
12. [TASK-12](TASK-12-metrics-dashboard-payload.md): payload do dashboard (`executions`, `failure_rate`, custo por SPEC/PLAN/TASK e métricas do vigia)
13. [TASK-13](TASK-13-web-metricas-ligadas.md): telas ligadas na casca real
14. [TASK-14](TASK-14-readme-statusline.md): README statusline
15. [TASK-15](TASK-15-tick-quota-stub.md): cap_ok real no tick
16. [TASK-16](TASK-16-web-metricas-dashboard.md): dashboard completo em web/metrics.js
17. [TASK-17](TASK-17-sync-cost-ts-plan.md): syncCost ts=session.created + plan/task
18. [TASK-18](TASK-18-quota-resets-epoch.md): resets_at em epoch numérico aceito (codex + claude)

## Ordem

(07, 02, 06) → 09 → 01 → 03 → 10 → (04, 08) → 12 → 05.

## Interfaces (definidas no plano; mudar = replan)

```ts
// src/cost/opencode_db.ts (TASK-07)
export type OcSession = { id: string; model: string; cost_usd: number; tokens_in: number; tokens_out: number; created: string; directory: string };
export function readOpencodeSessions(dbPath: string, o: { since?: string; ids?: string[] }): OcSession[]; // somente leitura (?mode=ro)
export function syncCost(db: Database, sessions: OcSession[]): { emitted: number }; // eventos `cost`, idempotente por session id
// src/metrics.ts (TASK-01)
export type Metrics = { executions: number; failure_rate: number; ftpr: Record<string, number>; cost_per_verified_task_usd: number; failures_by_reason: Record<string, number>; escalations: number; spent_usd: number; repeated_errors: number; cost_by: { spec: Record<string, number>; plan: Record<string, number>; task: Record<string, number> } };
export function computeMetrics(db: Database, o?: { since?: string; root?: string }): Metrics;
// src/metrics_alerts.ts (TASK-08)
export type RuleMetrics = { rule_id: string; count: number; open: number; mttr_min: number | null; cost_usd: number };
export function alertMetrics(db: Database, o?: { since?: string }): RuleMetrics[];
// src/quota/index.ts (TASK-03)
export type Quota = { provider: string; window: string; used_pct: number | null; resets_at: string | null; source: "codex-rollout" | "claude-statusline" | "opencode-db" | "manual" | "unavailable" | "stale" };
export function readQuotas(o: { home: string; db: Database }): Quota[];
```

## ACs da SPEC cobertos

- O dashboard de Métricas mostra FTPR, custo por TASK verificada, falhas por motivo e quota por provider.
- A tela de quota lê o Codex e o Claude automaticamente; AGY e OpenCode Go aparecem como "manual".
- O A/B nativo vs handoff tem a ontologia de bench, e "erros repetidos" aparece no dashboard.
- SPEC-0003: contagem por regra, MTTR, custo por alerta; FTPR sem `quota`/`infra`.

## Riscos

- O schema do `opencode.db` não é documentado e muda entre versões: o leitor confere as colunas e, faltando alguma, devolve `source: unavailable` em vez de quebrar.
- Os formatos de rollout do Codex e da statusline do Claude também não são documentados: os parsers toleram campos ausentes e marcam `source: stale`.
- Instalar a statusline mexe em `~/.claude/settings.json`: a TASK-03 só entrega o script e a instrução; ativar é ação do dono.
- O A/B precisa de execuções reais para ter números; a TASK-06 entrega a estrutura e a importação, não o resultado.
