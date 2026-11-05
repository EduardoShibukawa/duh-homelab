---
type: task
mode: mvp
goal: "loadJevConfig lê [jev] do project.toml e do ambiente, com mode efetivo off quando falta a chave"
title: Configuração [jev]
plan: PLAN-0031-jev-classificadores-no-manda
repo: manda
depends_on: []
tier: free
touch: [src/jev/config.ts, tests/jev/config.test.ts]
done_when: "bun test tests/jev/config.test.ts"
tests_frozen: [tests/jev/config.test.ts]
---
## Fazer
- `[jev] mode, provider, model, min_confidence, classifiers, timeout_ms`; padrão `mode = "off"`, `min_confidence = 0.85`, `timeout_ms = 4000`.
- A chave vem só do ambiente (`providers.json`); `provider = "local"` não precisa. Sem chave (e provider ≠ local) → `effectiveMode = "off"` com `reason: "no_key"`.
- Valor inválido (mode desconhecido, `min_confidence` fora de 0..1) → erro claro na carga, não o default calado.
## Interface
- `loadJevConfig(toml, env): { mode, effectiveMode, provider, model, minConfidence, classifiers, timeoutMs, reason? }`. Teste: padrão, cada erro, ausência de chave, `local`.
## Não fazer
- Não escrever `project.toml`. Não ler `~/.jev-gateway`. Nunca logar a chave.
## Contexto
- SPEC-0004; `[routing]` do manda como modelo de leitura.
