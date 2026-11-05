---
type: plan
title: O pi-harness sai como pacote (fecha a decisão 2 do revamp)
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: approved
repos: [pi-harness, manda, g-inga, bench, duh-homelab]
depends_on: [PLAN-0003-worktrees-triage, PLAN-0004-eventos-e-lint, PLAN-0006-install-sai-do-pinga, PLAN-0007-manda-nucleo, PLAN-0008-manda-routing-e-judge, PLAN-0011-verbos-api-auth, PLAN-0012-roda-web, PLAN-0013-handoff-e-learnings, PLAN-0014-metricas-e-quota, PLAN-0015-init-e-homelab]
done_when: "test ! -d pi-harness && test -f _archive/pi-harness/MANIFEST.md && test -f _archive/pi-harness/HANDOFF-0043.md && ! rg -n -i 'pi-harness' --glob '!_archive/**' --glob '!.ginga/knowledge/**' --glob '!.ginga/plans/**' --glob '!**/events/migrate*' . && (cd manda && bun test) && (cd g-inga && bun test)"
---
## Objetivo

Fechar a decisão 2 do revamp (README do revamp; 02; 03 §7): o pi-harness deixa de existir como pacote. Tudo que ainda é usado passa a morar no manda (orquestrador e adapters), no g-inga (UX, install, Discord), no `bench/` (INTENT-0007) ou no pinga (gate), ou então é descartado com justificativa. O repo vai para `_archive/` com manifesto e **não é apagado**.

## Abordagem

- **Onda 7, último PLAN da SPEC-0001** (08 §3): só começa depois que 0014 e 0015 passarem no judge. Ele **arquiva o que os PLANs anteriores portaram**. Se o inventário achar algo em uso sem destino, isso vira TASK aqui ou emenda no PLAN dono.
- **Destino por módulo** (03 §7, 06). A TASK-01 confirma cada linha com evidência de uso:

  | Origem no pi-harness | Destino | PLAN que porta |
  |---|---|---|
  | `sdlc.ts`, `runners`, `router` (inclui `health_ledger`), `worktree`, `pipeline` (`task_runner`, `judge_guard`), `autonomy`, `intent` (`plan_linter`, `spec_judge`, `tier_judge`) | manda | 0007/0008; o que faltar, TASK aqui |
  | `async` (`dispatcher`, `budget_scheduler`, `task_checkpoint`, `task_resume`) | manda (checkpoint: 06) | 0013 |
  | `intent/decomposition_linter` | g-inga lint (04 §3) | 0004 |
  | `harness/events`, `task_ops`, `record_claude_cost` | eventos v1 / g-inga | 0004, 0014 |
  | `metrics`, `dashboard`, `hud` | g-inga (Roda/Métricas) | 0012, 0014 |
  | `hosts/*`, `global_install`, `skill_*`, `scaffold`, `doctor`, `hermes-plugin`, `claude-plugin` | g-inga install | 0006 (emenda: incluir os dois plugins) |
  | `src/bench`, `benchmarks` | `bench/` (INTENT-0007, decisão 2) | **0014: emenda** (hoje diz "o bench continua no pi-harness") |
  | `dreams.ts`, `LESSONS.md`, `dreams/` | **substituídos** pelo ciclo LEARNINGS→LESSON (06); o histórico vai para o arquivo | 0013 |
  | `.pi/extensions` restantes: `reality-repair`, `verifier`/`contract_verifier` (Reality BDD), `housekeeping`, `gate-*`, `merge-lock`, `*guard`, `session_recipe`, `task_*_tool`, `codex_review`, `lsp`, `intents`, `knowledge`, `gira`, `websearch-*` | decidir um por um na TASK-01 (portar ou descartar com motivo) | 0017 |
  | `tui-driver`, `ux-*` | aguardar a decisão do dono sobre a `pi-harness-ux` | 0003 |

- **O Pi vira host adapter no manda** (decisão 2 do README). Das extensões, só sobrevivem o `manda-host.ts` (T59, PLAN-0007) e o registro dele, que vão para `manda/hosts/pi/` e são instalados pelo `ginga install` (0006).
- **Estado:**
  - `events.jsonl` migrado com `ginga events migrate` (0004);
  - `taskhub.db`, `state/` e `runs/` vão para o arquivo;
  - os `tasks/T<N>/` ficam como legado lido pelo pinga (0005).
- **Arquivos fora do git** (`HANDOFF-0043.md`, `intents/0054` e `0055`, `specs/draft-0055`): são salvos no arquivo. A 0054 pode virar INTENT no `.ginga/`. A 0055 já foi substituída pelo 05.

## TASKs (os arquivos `TASK-0N-*.md` são criados antes de `approved`)

1. **Inventário** (sem código, tier free): `inventario.md` com uso real, destino e PLAN de cada linha da tabela; salva os 4 arquivos fora do git.
2. **Host Pi no manda** (manda, tier free): move `manda-host.ts` com o teste; `ginga install` instala no `~/.pi`.
3. **Referências no workspace** (duh-homelab, tier medium): `bin/homelab`, CLAUDE.md, AGENTS.md, Hermes profile e skills; `rg` limpo.
4. **Referências na home do dono** (**ação do dono**, não TASK de modelo): `~/.claude/settings.json` e o MCP `pi-harness` no `~/.claude.json`. A troca só é feita quando o `ginga status --json` (0011) e a Roda (0012) substituírem `harness_status`/`harness_next` e a HUD.
5. **Arquivar:** mover `pi-harness/` para `_archive/pi-harness/` com `MANIFEST.md` (commit final, branches, destino de cada módulo); atualizar index, ROUTING e o 08 §3.

## ACs da SPEC cobertos

- Decisão 2: o pi-harness sai como pacote; o Pi vira adapter.
- O `events.jsonl` do pi-harness é migrado (via 0004).

## Riscos

- **Ferramenta em uso:** o MCP `pi-harness` e a HUD. Por isso a TASK-04 só acontece depois de 0011 e 0012.
- **Portar demais:** são ~32k linhas. A regra é portar só o que a TASK-01 provar que está em uso; o resto é descartado com motivo no manifesto.
- **Emendas pendentes:** 0014 (bench vai para `bench/`) e 0006 (incluir `hermes-plugin` e `claude-plugin`). Elas precisam entrar antes de esses PLANs serem aprovados.
