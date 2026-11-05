---
type: provider
title: NVIDIA build (API catalog)
quota: free com fila; modelos populares ficam presos (sem resposta em 60–300 s)
quota_check: "curl https://integrate.api.nvidia.com/v1/models com a chave (auth: opencode `nvidia`, pi `~/.pi/agent/auth.json`)"
---
# NVIDIA build (free)

Chave salva no opencode e no Pi em 2026-10-29. Teste de 2026-10-29 (~16h): TASK de código real (teste RED → passar), `< /dev/null` obrigatório no `opencode run`/`pi -p` (sem isso o processo espera o stdin e trava).

| Modelo | opencode | pi | Uso |
|---|---|---|---|
| `minimaxai/minimax-m3.1-flash` | ❌ "Invalid request" | ✅ 4/4, ~240 s | executor free reserva, só pelo Pi |
| `mistralai/mistral-large-4-1t-a52b` | — | ✅ 2026-10-29 20:35, TASK de teste em 13 s | executor free pelo Pi (id custom no Pi) |
| `stepfun-ai/step-5-preview` | — | ✅ 2026-10-29 20:35, TASK de teste em 106 s | executor free reserva pelo Pi |
| `openai/gpt-oss-20b` | ✅ 4/4, 66 s, erra nome de tool | ❌ 0/4 | não |
| `z-ai/glm-5.3-flash`, `deepseek-ai/deepseek-v4.1-flash`, `stepfun-ai/step-5-preview` | ❌ fila (ECONNRESET 300 s) | ❌ fila | retestar em outro horário |
| `nvidia/nemotron-3.5-bolt-e4b` | ❌ id desatualizado no catálogo do opencode | — | pequeno (~4B); não |
| `kimi-k2.6`, `kimi-k3`, `z-ai/glm-5.3` | indisponíveis para a conta | — | não |

No mesmo teste: `opencode-go/iceman-contributor-free` ✅ 4/4 em 20 s (executor free; treina com os dados → só código de repo MIT, nunca operador); `opencode-go/beam-free` ❌ ECONNRESET.

Próximo: escada do executor `iceman → pi:nvidia/minimax-m3.1-flash → qwen pago` com failover pelo primeiro token (~60 s), no PLAN da lacuna 2.
