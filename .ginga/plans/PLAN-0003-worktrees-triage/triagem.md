# Triagem das worktrees antigas — PLAN-0003

> Levantamento **somente leitura** (2026-10-28). Nenhuma recomendação foi executada: o dono decide.
> Base de comparação: `main` de cada repo no momento do levantamento.

## Tabela-resumo

| Worktree | Repo | Branch | Atrás da main | Não commitado | Conflito com mergeado? | Recomendação |
|---|---|---|---|---|---|---|
| `p-inga-governed-roles` | p-inga | `task/governed-model-roles` | 45 | T35 (verify receipt) + 2 arquivos | **Sim** (ID T35 colide + `web/server.ts` reescrito) | **Arquivar** (patch) |
| `p-inga-run-status` | p-inga | `task/hermes-run-status` | 45 | só o plano `tasks/hermes-run-status/` | Não (sem código) | **Arquivar** plano → virar INTENT |
| `pi-harness-ux` | pi-harness | `task/ux-unificado` | 18 | ~780 linhas HUD + tasks 0044–0049 + specs 0056/0057 | Não (PLAN-0007 tocou `manda-host.ts`/`index.ts`, não `ui.ts`) | **Estacionar** (commit WIP) |
| `pi-harness-bench-uxjudge` | pi-harness | `task/bench-uxjudge-import` | 18 | T37 (`src/bench/importer.ts`, 117+) | Não (PLAN-0007 não tocou `src/bench`) | **Mergear** (terminar) |
| `gira-g-ux` | gira-g | `task/ux-unificado` | 10 | ~430 linhas docsite + tasks + spec | **Parcial** (`cmd/gira/main.go` também mudou na main; toca A3) | **Estacionar** (commit WIP) |

---

## 1. `p-inga-governed-roles` — T35 "verify receipt correlation"

- **Branch:** `task/governed-model-roles` @ `0899228` (45 commits atrás de `main` @ `aad1425`).
- **Não commitado:**
  - `web/server.ts` (M, 7+/29−): troca a extração inline do recibo por `correlateVerifyReceipt(...)`.
  - `web/verify-receipt.ts` (novo, untracked): `correlateVerifyReceipt` deriva a task de `plan_path` e só aceita recibo de stdout se `receipt.task === task`.
  - `tests/web-receipt-correlation.test.ts` (novo, untracked).
  - `tasks/T35/PLAN.md` (untracked).
- **Do que se trata:** correlacionar o recibo de `/api/action/verify` com a task canônica derivada de `plan_path`, evitando associar recibo de outra task. O `PLAN.md` já tem seção "Fechamento" com evidência (`bun test` = 1 pass no teste novo; suíte completa 218 pass / 8 fail, sendo as 8 falhas pré-existentes na base).
- **Conflito com o mergeado (PLAN-0005):**
  - **Colisão de ID:** a `main` já tem um **T35 diferente** — `b96b4b3 feat(ux): ciclo UX unificado T35–T39` (dashboard web + CLI). O T35 desta worktree é outro assunto.
  - **`web/server.ts` reescrito:** `b96b4b3` mudou 1605 linhas em `web/server.ts`; `604ef59` também tocou o arquivo. O diff desta worktree (7+/29−) está sobre uma base 45 commits atrás e precisaria de rebase com provável conflito.
  - `web/verify-receipt.ts` **não existe** na `main` (o trabalho não foi incorporado por outro caminho).
- **Recomendação: arquivar.** Gerar patch (`git diff` + arquivos untracked) em `_archive/` e remover a worktree. O ID T35 está ocupado e a base é antiga; se a correlação de recibo ainda for necessária, reabrir como task nova com ID livre sobre a `main` atual.

---

## 2. `p-inga-run-status` — plano "Hermes run status"

- **Branch:** `task/hermes-run-status` @ `0899228` (45 atrás de `main`).
- **Não commitado:** apenas `tasks/hermes-run-status/` (untracked) — um `PLAN.md` de micro-contrato observacional (consultar uma run por id, read-only, sem criar ledger/schema). Sem mudança de código.
- **Do que se trata:** entrypoint do ginga para consultar o estado de uma execução (estado, gate, receipt). É um plano, não uma implementação.
- **Conflito:** nenhum (não toca código).
- **Recomendação: arquivar** o plano (copiar para `_archive/` ou promover a INTENT no `.ginga/intents/`) e remover a worktree. O conteúdo é um entrypoint do ginga, não do p-inga; não pertence a este repo.

---

## 3. `pi-harness-ux` — UX unificado (cockpit/HUD/docs)

- **Branch:** `task/ux-unificado` @ `041396a` (18 atrás de `main` @ `1662cfe`).
- **Não commitado:** ~780 linhas (15 arquivos modificados) + untracked:
  - Modificados: `.pi/extensions/tui-driver.ts`, `.pi/extensions/ui.ts`, `src/harness/task_ops.ts`, `src/hud/collect.ts`, `src/hud/inventory.ts`, `README.md`, `docs/*`, `claude-plugin/*`, 6 testes.
  - Untracked: `specs/draft-0056-ux-unificado-pi-harness.md`, `specs/draft-0057-bench-eval-trio.md`, `tasks/0044..0049/`, 8 testes novos.
- **Do que se trata:** ciclo UX unificado — inventário (0044), auditoria dos 4 harnesses de bench (0045), gate adversarial (0046), e execução de aceite/estado (0047), HUD/card (0048) e docs (0049). Specs `draft-0056` (UX cockpit/HUD/docs) e `draft-0057` (bench do trio) aprovadas.
- **Conflito com o mergeado (PLAN-0007):** PLAN-0007 adicionou `.pi/extensions/manda-host.ts` e 2 linhas em `.pi/extensions/index.ts`. Esta worktree **não** toca `index.ts` nem `manda-host.ts` (toca `ui.ts`/`tui-driver.ts`). Sem conflito direto; só a defasagem de 18 commits.
- **Recomendação: estacionar como branch WIP.** Commit WIP na branch `task/ux-unificado` (preserva as ~780 linhas + specs + tasks) e remover a worktree. A HUD vai para o ginga no revamp; o trabalho não deve ser perdido nem mergeado às pressas no pi-harness.
- **2026-10-29:** a INTENT 0047 (cockpit) foi **cancelada pelo dono** e arquivada na main do pi-harness (`30930b6`, `status: ARCHIVED`). A rodada do `PROMPT-ORQUESTRADOR-0047.md` está encerrada sem spec.

---

## 4. `pi-harness-bench-uxjudge` — T37 "import legado sem falso verde"

- **Branch:** `task/bench-uxjudge-import` @ `041396a` (18 atrás de `main`).
- **Não commitado:** `src/bench/importer.ts` (M, 117+/12−), `tasks/T37/PLAN.md` (untracked), `tests/unit/bench_importer_uxjudge.test.ts` (untracked).
- **Do que se trata:** o importador tratava JSON legado `ux-judge*.json` sem `tasks[]` como `done`/`score=1.0` (falso verde). A mudança deriva `specId` do diretório, calcula `score` como fração de critérios que atingem o `floor`, e descarta arrays (`findings`/`quarantine`). `PLAN.md` tem `done_when` definido e decisões de implementação registradas.
- **Conflito com o mergeado (PLAN-0007):** nenhum — PLAN-0007 não tocou `src/bench/`.
- **Recomendação: mergear.** É uma correção pequena, autocontida e com `done_when`. Rebase na `main`, rodar `bun test tests/unit/bench_importer_uxjudge.test.ts`, fechar via pinga e mergear. O bench do pi-harness é a base do bench do ginga, então a correção tem valor imediato.

---

## 5. `gira-g-ux` — UX unificado (superfície humana + docsite)

- **Branch:** `task/ux-unificado` @ `21a82fd` (10 atrás de `main` @ `9acce17`).
- **Não commitado:** ~430 linhas (9 arquivos modificados) + untracked:
  - Modificados: `cmd/gira/docs_cmd.go`, `cmd/gira/main.go` (111 linhas), `cmd/gira/symbol_ops.go` (90), `internal/docsite/{builder,graph,landing,theme,tour,types}.go`.
  - Untracked: `cmd/gira/ux_exit.go`, `ux_help.go`, `ux_test.go`, `internal/docsite/ux_*_test.go`, `specs/2026-10-26-ux-unificado.md`, `tasks/2026-10-26-*` e `tasks/2026-10-27-*`.
- **Do que se trata:** fechar lacunas da superfície humana (comandos `outline`/`read` fora do caminho comum `emitHuman`) e estender a régua ao docsite. Spec `2026-10-26-ux-unificado.md` (v2, aprovada no gate adversarial).
- **Conflito com o mergeado:**
  - **`cmd/gira/main.go`:** a `main` ganhou 40 linhas em `e97d5bd` (outline via `go/parser`); esta worktree também mexe em `main.go` (111 linhas). Rebase com provável conflito.
  - **A3 (acoplamento gira→pinga):** a worktree toca `internal/docsite/tour.go` e `landing.go`, que são exatamente os arquivos do hardcode A3 (`tour.go:309`, `landing.go:18/425/533`). O PLAN-0009 (A3) depende do destino desta worktree — **bloqueia a onda 4**.
- **Recomendação: estacionar como branch WIP.** Commit WIP na branch `task/ux-unificado` e remover a worktree. Antes de qualquer merge, conferir se o trabalho **ataca** o A3 (move o conteúdo para `gira.yaml` do repo-alvo) ou **adiciona** mais hardcode — isso decide se entra antes ou depois do PLAN-0009.

---

## Observações

- Nenhuma das 5 worktrees está **à frente** da `main` (todas são ancestrais, só defasadas); o risco está no que **não está commitado**.
- `gira-g-ux` é a única que bloqueia a onda 4 (PLAN-0009/A3). As demais podem ser decididas em qualquer ordem.
- Há ainda uma worktree do gira-g fora deste inventário, em `~/.hermes/profiles/pinga/cache/scratch/bench-wt/gira-g` (detached @ `21a82fd`, bench do Hermes) — listada em `git -C gira-g worktree list`.
