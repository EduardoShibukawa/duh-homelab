---
type: task
mode: padrao
goal: "ginga install não tem o nome pi-harness fixo: fonte e nome do plugin vêm de config/env"
title: Plugin instalado vira parâmetro
plan: PLAN-0006-install-sai-do-pinga
repo: ginga
depends_on: [TASK-01-ginga-install-copia]
tier: medium
pinga_task: T15
touch: [src/install/, tests/install/plugin_param.test.ts]
done_when: "bun test tests/install/ && ! rg -n 'pi-harness' src/install"
tests_frozen: [tests/install/plugin_param.test.ts]
---
## Fazer
- `pickSource`: `GINGA_PLUGIN_SOURCE` → `[install].source` do config → erro claro (sem `../pi-harness` adivinhado).
- Nome do plugin, marketplace (`pi-harness-local`) e arquivos (`plugins/pi-harness.ts`, `.pi/agent/extensions/pi-harness.ts`) derivados de `[install].plugin`.
- Os testes copiados passam a fixar `plugin = "pi-harness"` no fixture, não no código.
## Não fazer
- Não mudar os caminhos de destino dos hosts.
## Contexto
- Hardcodes: `install.ts:122-186`, `adopt.ts:85-406`, `adapters/hermes.ts:9-168`, `adapters/opencode.ts:7-60`.
