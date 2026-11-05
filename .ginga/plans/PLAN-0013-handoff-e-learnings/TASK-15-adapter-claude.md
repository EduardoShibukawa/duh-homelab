---
type: task
mode: mvp
goal: "ginga install projeta as entradas Stop e UserPromptSubmit do Claude que chamam ginga handoff hook --runtime claude, idempotente e em dry-run por padrão, e o mod ginga-handoff chama o mesmo comando"
title: Adapter Claude (hooks + mod opcional)
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T154
depends_on: [TASK-12-handoff-hook, TASK-13-handoff-open, TASK-14-skill-handoff]
tier: free
touch: [src/install/adapters/claude.ts, contrib/claude-mod-handoff/, tests/install_handoff_claude.test.ts]
done_when: "bun test tests/install_handoff_claude.test.ts"
tests_frozen: [tests/install_handoff_claude.test.ts]
---
## Fazer
- O adapter acrescenta as duas entradas de hook em `settings.json` (HOME injetável), sem duplicar nem remover entradas alheias; `--apply` grava, o padrão só lista.
- `contrib/claude-mod-handoff/` (`.claude-plugin/plugin.json`, `hooks/hooks.json`, `hooks/register.ts`): só repassa o JSON ao `ginga handoff hook`; zero lógica de decisão.
## Interface
- Teste: HOME temporário com `settings.json` que já tem outro hook → dry-run não grava; `--apply` 2× → as 2 entradas uma vez só e o hook alheio intacto; `plugin.json` e `hooks.json` são JSON válidos com os campos `name`, `hooks` (substitui o `claude plugin validate`, que não roda no sandbox).
## Não fazer
- Adapters opencode, Pi, Codex e AGY ficam para o PLAN seguinte (doc 11 §6).
## Contexto
- Doc 11 §3 (proposta TASK-13 de lá).
