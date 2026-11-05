---
type: provider
title: OpenCode Go
runtimes: [opencode, pi]
family: mista (por modelo)
billing: subscription
quota: limites do plano Go
quota_check: "não há comando de quota; opencode stats mostra só o consumo (tokens/sessões); router-health.json do pi-harness é parcial"
---
## Uso

O cavalo de carga: **executores** `cheap` e `medium`, e alternativa barata de Planner. Como tem modelos de várias famílias, também resolve a diversidade do judge sem gastar as assinaturas.

## Modelos (fonte: `opencode models`, 2026-10-27)

A classificação de tier abaixo é **inicial e precisa ser calibrada** com FTPR real (scoreboard do `pinga maestro` / bench).

| Tier inicial | Modelos | Família |
|---|---|---|
| medium+ | `kimi-k3.1-pro`, `qwen3.8-max`, `deepseek-v4-pro`, `glm-5.3`, `mimo-v2.6-pro`, `minimax-m3` | moonshot, alibaba, deepseek, zhipu, xiaomi, minimax |
| cheap | `qwen3.8-flash`, `glm-5.3-flash`, `minimax-m3.1-flash`, `deepseek-v4.1-flash`, `mimo-v2.6-flash` | idem |
| outra família (para o judge) | `claude-haiku-5-5`, `gpt-6-luna`, `gemini-4-argon`, `grok-4.7` | anthropic, openai, google, xai |

O catálogo completo está em `opencode models | grep ^opencode-go/`.
