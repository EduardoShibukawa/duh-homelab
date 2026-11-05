---
type: provider
title: OpenCode Zen
runtimes: [opencode, pi]
family: mista (por modelo)
billing: créditos (pago por token) + modelos -free
quota: free com rate limit instável; pago limitado pelo budget de ROUTING.md
quota_check: "painel do Zen (manual)"
---
## Uso

- **Modelos `-free`:** primeira opção para executor `free`. São instáveis: em 2026-10-22, `nemotron-3-ultra-free` e `nemotron-3.5-lightning-free` falharam por `quota_exhausted` depois de 240s (`pi-harness/state/events.jsonl`). Use timeout curto e fallback rápido.
- **Pagos:** só quando o Go e os free estiverem esgotados, dentro do budget de [ROUTING.md](ROUTING.md#budget-do-zen).

## Modelos free (fonte: `opencode models`, 2026-10-27)

`nemotron-3.5-lightning-free`, `nemotron-3-ultra-free`, `nemotron-3.5-super-vl-free`, `glm-5.3-flash-free`, `deepseek-v4.1-flash-free`, `mimo-v2.6-flash-free`, `flint-40b-free`, `beam-free`
