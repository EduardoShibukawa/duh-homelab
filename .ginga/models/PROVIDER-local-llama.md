---
type: provider
title: llama.cpp local
runtimes: [pi]
family: mista
billing: grátis (GTX 1650 4 GB)
quota: infinita
quota_check: "curl http://127.0.0.1:8089/v1/models"
---
## Uso

Contexto de 16K e modelos de 4 a 9B (`ornith-9b-local`, `qwen2.5-coder-7b-local`, `qwen3.5-4b-local`). Serve só para TASKs minúsculas com `touch` de um arquivo, ou como último recurso offline. Detalhes de capacidade em `llm-bench/RESULTS.md`.
