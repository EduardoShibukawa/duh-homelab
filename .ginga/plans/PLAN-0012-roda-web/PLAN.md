---
type: plan
title: Roda Web — Inbox, Quadro e PLAN + index.md gerado
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: approved
repos: [ginga, duh-homelab]
depends_on: [PLAN-0011-verbos-api-auth]
done_when: "cd ginga && bun test && cd .. && grep -q 'gerado por ginga' .ginga/index.md"
---
## Objetivo

A Roda Web (fases 1 e 2 do doc 05 §8) mostra Inbox, Quadro e detalhe do PLAN a partir do `.ginga/` e do `state.db`, com as ações chamando verbos. O `index.md` passa a ser gerado e deixa de ser escrito à mão.

## Abordagem

- Um modelo de quadro (`src/board.ts`) é a única derivação de estado; web, `ginga board`, `ginga inbox` e o `index.md` gerado leem dele.
- A web é cliente fino: HTML + JS sem build, consumindo `/v1/verbs/*` e `/v1/events` (SSE). Base visual: `p-inga/web/index.html` e os protótipos em `knowledge/design/ginga-revamp/prototipos/Main.dc.html`.
- Render em funções puras (`src/web/render/*.ts` → string HTML) para testar sem browser.
- Layout responsivo: barra lateral no desktop, abas embaixo no celular.

## TASKs

1. [TASK-01](TASK-01-board-model.md): modelo do quadro + `ginga board|inbox --json`
2. [TASK-02](TASK-02-web-shell.md): casca da Roda Web servida pelo `serve`
3. [TASK-03](TASK-03-inbox.md): tela Inbox com ações
4. [TASK-04](TASK-04-quadro.md): tela Quadro (kanban + filtros)
5. [TASK-05](TASK-05-plan-detalhe.md): detalhe do PLAN
6. [TASK-06](TASK-06-index-gerado.md): `ginga index` gera o `index.md`
7. [TASK-07](TASK-07-adotar-index-workspace.md): o workspace passa a usar o `index.md` gerado (raiz sem git: fora das lanes, aplicada pelo Planner)
8. [TASK-08](TASK-08-status-json.md): `ginga status --json` (substitui o MCP `harness_status`/HUD; pré-requisito do PLAN-0017 TASK-04)
9. [TASK-09](TASK-09-painel-alertas.md): painel de alertas por severidade (SPEC-0003)
10. [TASK-10](TASK-10-status-json.md): `ginga status --json` com o frozen corrigido — substitui a TASK-08 (T161 superseded: frozen incompatível com o schema real de `task_exec`; 2026-11-01, operador)

## Ordem

TASK-01 → (02, 06) → 08 → (03, 04, 05) → 09 → 07. A TASK-08 vem cedo porque destrava o PLAN-0017.

## Interfaces (definidas no plano; mudar = replan)

```ts
// src/board.ts (TASK-01)
export type Card = { id: string; kind: "intent"|"spec"|"plan"; title: string; status: string; repo?: string; track: "pequena"|"feature"; tasks: { total: number; pass: number; running: number }; blocked: boolean };
export type Column = "INTENT"|"SPEC"|"PLAN"|"EXECUTANDO"|"VERIFICANDO"|"FEITO";
export type InboxItem = { id: string; type: "blocker"|"aprovar"|"budget"|"decidir"|"promover"|"alerta"; entity: string; title: string; severity?: "info"|"warn"|"high"|"critical"; actions: string[] };
export type Board = { columns: Record<Column, Card[]>; inbox: InboxItem[] };
export function deriveBoard(root: string, db: Database): Board;
// src/alerts.ts (TASK-08)
export type Alert = { id: string; ts: string; rule_id: string; severity: "info"|"warn"|"high"|"critical"; entity: string; summary: string; plan?: string; task?: string };
export function listAlerts(db: Database, o?: { minSeverity?: Alert["severity"]; since?: string }): Alert[];
// src/status.ts (TASK-08)
export type Status = { schema_version: 1; generated_at: string; owner: InboxItem[]; plans: { id: string; status: string; tasks: { total: number; pass: number; open: number }; attempts: number; cost_usd: number }[]; alerts: { critical: number; high: number; warn: number; info: number }; broken_sources: { source: string; error: string }[] };
export function buildStatus(root: string, db: Database, now?: () => Date): Status;
```

## ACs da SPEC cobertos

- A Roda Web mostra Inbox, Quadro e PLAN a partir do `.ginga/` e substitui o `index.md` escrito à mão.
- Nenhuma superfície tem lógica própria (as telas só chamam verbos).
- SPEC-0003: os `alert` aparecem no Inbox/Quadro com filtro por severidade.

## Riscos

- O `index.md` atual tem texto livre ("Como uma sessão trabalha", "Mapa") que o gerador precisa preservar como template, senão a TASK-07 perde informação.
- O `.ginga/` do workspace não é git: a TASK-07 deve copiar o `index.md` manual para `_archive/` antes de trocar.
- Ao Vivo, Modelos/quota, Ledger/Bench, TUI e push ficam fora (Métricas e quota no PLAN-0014). A árvore de spans por `trace_id` (emenda da SPEC-0003) fica com a lacuna 8 (OTLP), que ainda não tem PLAN.
- A TASK-07 toca a raiz do workspace, que não é git: não entra em lane; o Planner aplica depois do merge da TASK-06.
