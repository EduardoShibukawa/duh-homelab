---
type: plan
title: Fechar, mergear ou descartar as worktrees paradas
intent: INTENT-0003-worktrees-triage
status: done
done_when: "cd /home/shibuka/Projetos/duh-homelab && for r in p-inga pi-harness gira-g; do git -C $r worktree list --porcelain | grep -c ^worktree; done | awk '$1>1{bad=1} END{exit bad}'"   # só a principal; worktrees estacionadas viram branch WIP
---
## Abordagem

Uma TASK por worktree, com uma ação proposta. **Remover worktree ou branch exige o OK do dono**, porque é irreversível para o que não está commitado.

| Worktree | Situação | Ação proposta | Precisa do dono? |
|---|---|---|---|
| ~~`p-inga-ux`~~ | Removida em 2026-10-27 | — | — |
| ~~`p-inga-enq`~~ | Removida em 2026-10-27 | — | — |
| ~~`p-inga-exec`~~ | Removida em 2026-10-27 (AGENTS.md e GEMINI.md conferidos com `diff -q`, idênticos à main) | — | — |
| `p-inga-run-status` | Só o plano (status read-only de um run) | Virar INTENT no `.ginga` (é entrypoint do ginga) e remover a worktree | sim |
| `p-inga-governed-roles` | T35 não commitada, base antiga | Rebase na main e fechar via pinga, ou descartar | **sim** |
| `pi-harness-bench-uxjudge` | T37 pequena, com `done_when` | Terminar: o bench do pi-harness é a base do bench do ginga | sim |
| `pi-harness-ux` | ~780 linhas de HUD não commitadas | Commit WIP na branch para não perder, e estacionar (a HUD vai para o ginga) | **sim** |
| `gira-g-ux` | ~430 linhas de docsite, inclui `tour.go` | Commit WIP e estacionar; conferir se ataca o acoplamento A3 | **sim** |

Há também uma worktree do gira-g fora deste inventário, em `~/.hermes/profiles/pinga/cache/scratch/bench-wt/gira-g` (bench do Hermes). Estacionar = commit WIP na branch e **remover a worktree** (a branch fica).

## Bloqueado

Esperando a decisão do dono nas linhas marcadas com **sim**.

## Feito (2026-10-28, OK do dono)
Todas as worktrees extras removidas; WIP preservado em `_archive/2026-10-28-worktrees/` (MANIFEST). Exceção: a worktree do bench do Hermes em ~/.hermes ficou intacta.
