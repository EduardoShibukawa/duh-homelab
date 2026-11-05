---
type: plan
title: Ciclo autônomo sem operador (lacuna 1)
intent: INTENT-0001-ginga-revamp
kind: change
status: approved
repos: [ginga, manda]
depends_on: [PLAN-0010-tick-serve-notifier, PLAN-0023-vigia-e-supervisor]
done_when: "cd ginga && bun test && cd ../manda && bun test"
---
## Objetivo

Depois que o dono aprova um PLAN, **nenhum LLM vigia nada**: o código leva o PLAN de `approved` até `merged` (ou `blocked`). Só três papéis LLM existem, todos **chamados por código**: *Planner* (PLAN, TASKs, interfaces e `tests_frozen` no planejamento inicial; replan com mais contexto), *Executor* (resultado aceito ou rejeitado por `verify` + judge + gate) e *Judge* (outra família). O operador LLM some: tick, ids, worktrees, RED, verify, gate, disjuntor e notificação são código.

Motivo: o operador custou ~12x o executor por TASK verificada (US$ 0,65 vs 0,05) e ~65% do gasto do framework em 29/10 ([eficiência do framework](../../knowledge/research/eficiencia-framework-2026-10-29.md)).

## Abordagem

- **Testes no planejamento.** O Planner escreve os `tests_frozen` junto do PLAN, em `plans/PLAN-NNNN/frozen/<repo>/<caminho>`. A "passada RED" vira código (`manda red`): copia os testes para a worktree, materializa `tasks/T<N>/PLAN.md`, `pinga prove-red`, commit `test(T<N>): RED`. Interface que precisa mudar depois do plano = sinal de replan, nunca ajuste do executor.
- **Fase do PLAN no `state.db`** (`plan_phase`): `approved → red → tasks → judge → merge → done`, com `replan` e `blocked` como desvios. O `ginga tick` lê a fase e chama o próximo comando (`[commands]` do `project.toml`, plugável): `manda red`, `manda run`, `manda judge`, o merge gate.
- **Replan por código:** 3 falhas na mesma TASK, disjuntor aberto em todos os modelos do tier (PLAN-0029) ou achado `high` do judge → o código monta o contexto (TASK, receipts, `reason_code`, achados do judge, diff) e chama o **mesmo Planner**. O PLAN reescrito passa no `ginga lint` ou vira `blocked` + Inbox.
- **Teto de custo cobre todos os papéis** (Planner, Executor, Judge), medido pelo `opencode.db` (`ginga cost --json`, PLAN-0014 TASK-07) e pelo `total_cost_usd` do `claude -p`; checado **antes** de cada chamada paga.
- O supervisor troca o operador pelo `ginga tick --loop` (fecha o PLAN-0022 TASK-03 e o PLAN-0023 TASK-06).

## TASKs

1. [TASK-01](TASK-01-fase-do-plan.md): fase do PLAN no `state.db` (ginga)
2. [TASK-02](TASK-02-alocar-pinga-task.md): alocação determinística do `pinga_task` (manda)
3. [TASK-03](TASK-03-manda-red.md): `manda red <PLAN>` (manda)
4. [TASK-04](TASK-04-tick-avanca-fases.md): o `ginga tick` avança as fases (ginga)
5. [TASK-05](TASK-05-replan-por-codigo.md): `manda replan` com o contexto da falha (manda)
6. [TASK-06](TASK-06-teto-todos-papeis.md): teto de custo de todos os papéis pelo DB (manda)
7. [TASK-07](TASK-07-supervisor-sem-operador.md): o supervisor roda o tick, não o operador (ginga)
8. [TASK-08](TASK-08-e2e-sem-humano.md): e2e de PLAN aprovado até merge sem LLM (ginga)

Ordem: (01, 02, 06) → 03 → 05 → 04 → 07 → 08. Depende do PLAN-0014 TASK-07 (`ginga cost`) para a TASK-06; sem ele, a TASK-06 lê o `opencode.db` direto pela mesma consulta.

## Interfaces (definidas no plano; mudar = replan)

```ts
// ginga src/plan_phase.ts (TASK-01)
export type Phase = "approved" | "red" | "tasks" | "judge" | "merge" | "done" | "replan" | "blocked";
export function getPhase(db: Database, plan: string): { phase: Phase; since: string; replans: number } | null;
export function setPhase(db: Database, plan: string, phase: Phase, reason: string): void; // emite `transition`
// ginga src/tick_plan.ts (TASK-04)
export type Action = { cmd: "red" | "run" | "judge" | "merge" | "replan" | "notify" | "none"; plan: string; task?: string; reason: string };
export function nextAction(s: { phase: Phase; tasks: { id: string; status: "open"|"pass"|"fail"|"blocked"; attempts: number; deps_done: boolean }[]; judge?: "pass"|"fail"|"high"; cap_ok: boolean }): Action; // pura
// manda src/alloc.ts (TASK-02)
export function allocTaskIds(taken: string[], count: number): string[]; // "T<max+1>"...
// manda src/red.ts (TASK-03)
export function redPlan(o: { root: string; plan: string; repo: string; pinga: Runner; git: Runner }): { tasks: { task: string; pinga_task: string; red: boolean }[] };
// manda src/replan.ts (TASK-05)
export function buildReplanContext(o: { root: string; plan: string; task: string; receipts: unknown[]; judge?: string; diff: string }): string; // markdown, determinístico
// manda src/cost_cap.ts (TASK-06)
export function capCheck(o: { spent_usd: number; next_estimate_usd: number; cap_usd: number }): { allow: boolean; reason: string };
export function spentUsd(o: { since: string; opencodeDb: string; claudeCosts: number[] }): number;
```

## Riscos

- O Planner chamado por código gasta quota do Claude: o replan é limitado a 2 por PLAN (`replans`); o 3º vira `blocked` + Inbox.
- Mudar o supervisor desliga o operador de vez: a TASK-07 mantém `[supervisor] mode = "tick" | "operador"` até o e2e (TASK-08) passar com fixture real.
- Lacuna 2 (PLAN-0029) entrega o disjuntor; até lá o `manda run` usa a escada atual.

## Follow-ups (judge findings)

- [TASK-14](TASK-14-red-repo-filter.md): `redPlan` filtra `bundle.tasks` por repo, lança caminho real de frozen, grava `status: blocked`.
- [TASK-15](TASK-15-red-cli-multi-repo.md): CLI herda repo filter de `redPlan`.
- [TASK-16](TASK-16-taken-scans-tasks-dir.md): `redPlan` varre `tasks/T*/` do worktree e inclui `pinga_task` de TODAS as TASKs do bundle.
- [TASK-17](TASK-17-worktree-before-taken.md): `redPlan` cria a worktree do plano ANTES de montar `taken`, varrendo `tasks/T*/` da `main` na primeira execução (achado do judge sobre TASK-02/TASK-16).
