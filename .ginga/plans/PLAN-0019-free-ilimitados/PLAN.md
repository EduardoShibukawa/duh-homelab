---
type: plan
title: Avaliar beam-free e iceman-contributor-free e decidir onde usá-los
intent: INTENT-0006-sandbox-e-code-mode
kind: investigation
status: approved
repos: [manda, duh-homelab]
depends_on: [PLAN-0008-manda-routing-e-judge]
---
## Objetivo

O OpenCode Go oferece dois modelos **ilimitados** (por tempo limitado; veja o ROUTING, "Limites do OpenCode Go"): o `beam-free` (1M de contexto, sem treino) e o `iceman-contributor-free` (262 mil, **usa os dados para treino**). Este PLAN mede se eles servem como **executor**, e o beam também para **papéis de leitura longa** (pesquisa, retrospectiva, operador). Gasto previsto: US$0. Aprovado pelo dono em 2026-10-28 ("vamos").

## Linha de base (log.md das ondas 1–3, por tentativa)

| Modelo | Tentativas | Pass | Taxa |
|---|---|---|---|
| `opencode/glm-5.3-flash-free` | 37 | 28 | **76%** |
| `opencode/deepseek-v4.1-flash-free` | 25 | 17 | 68% |
| `opencode/nemotron-3-ultra-free` | 42 | 0 | **0%** (sai da escada) |
| `opencode/deepseek-v4-pro` | 7 | 2 | 29% (só pegou TASKs que já tinham falhado; não comparável) |

## Hipóteses pré-registradas (o critério vem antes de rodar)

| | Hipótese | Adotar se |
|---|---|---|
| H1 | O `beam-free` é tão bom quanto o glm-free como executor | taxa ≥ 70% em ≥ 8 tentativas, sem defeito novo no judge atribuível a ele |
| H2 | O `iceman` é tão bom quanto o glm-free como executor (só em repo MIT) | o mesmo critério da H1 |
| H3 | O `beam-free` dá conta de pesquisa e retrospectiva com contexto longo | entrega o arquivo pedido, com fontes, e o revisor (Claude, numa sessão curta) não acha erro factual grave em 5 afirmações sorteadas |
| H4 | Tirar o nemotron da escada não piora nada | trivial: 0/42 |

## Método (observacional, sem infra nova)

- **Executor, H1/H2:**
  - as próximas TASKs reais da onda 3 (0008 TASK-03 em diante, depois 0006 e 0010) rodam com o **primeiro degrau alternado**: `opencode-go/beam-free` nas ímpares, `opencode-go/iceman-contributor-free` nas pares; o resto da escada segue a ROUTING de 2026-10-28;
  - a escolha entra pelo `[runtimes]` do `.ginga/project.toml` do repo-alvo (o manda aceita `runtime:modelo`), sem editar script;
  - cada tentativa vira uma linha em `results.jsonl`: TASK, modelo, tentativa, pass, turnos, tokens (`.ginga/bench/code-mode/tokens.sh`) e segundos.
- **Leitura longa, H3:** a pesquisa de skills e hooks (INTENT-0009), que caiu duas vezes no Pi, roda com `opencode run --standalone -m opencode-go/beam-free`.
- **Privacidade:** o iceman **não** recebe handoff, logs do operador, nem prompts com dados do dono. Só TASK.md + código.

## TASKs

1. **Config:** `[runtimes]` com o degrau alternado em `manda/.ginga/project.toml` (e no ginga quando o 0006/0010 rodar), e o `results.jsonl` iniciado.
2. **Rodar** as TASKs da onda 3 normalmente (`manda run`) e coletar.
3. **H3:** a pesquisa de skills e hooks com beam-free, e a revisão.
4. **Relatório e decisão:** a tabela final, a decisão por hipótese e a emenda na ROUTING.

## Pré-requisito

A **TASK-04 do PLAN-0008** (escada) foi escrita antes da ROUTING de 2026-10-28 e escala sozinha até o `strong`. Ela precisa de **replan**: o `strong` só com `tier: strong` explícito, sem nemotron, com os degraus do Go. Isso vem antes de rodar a escada nova.
