---
type: task
mode: mvp
goal: "No `ginga install` real (que sempre passa `plugin` no ctx, `src/install/install.ts:856`) o adaptador Claude projeta as entradas `Stop` e `UserPromptSubmit` em `settings.json` chamando `ginga handoff hook --runtime claude`, declara as duas em `owned`, e registra o mod `contrib/claude-mod-handoff` em `installed_plugins.json`/`enabledPlugins` quando a fonte o traz — idempotente"
title: Install real projeta hooks de handoff no Claude + registra o mod
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T312
depends_on: [TASK-15-adapter-claude]
tier: free
touch: [src/install/adapters/claude.ts, tests/install_handoff_real.test.ts]
done_when: "bun test tests/install_handoff_real.test.ts"
tests_frozen: [tests/install_handoff_real.test.ts]
---
## Achado do judge (gate 2026-10-31T18:59, exit 11)
- TASK-15 (grave): `ensureHandoffHooks` só roda se `ctx.plugin === undefined` (`src/install/adapters/claude.ts`), mas o install real sempre passa `plugin` (`install.ts:856`) → os hooks `Stop`/`UserPromptSubmit` nunca chegam ao `settings.json`; `contrib/claude-mod-handoff` não é instalado por nada; `owned` declara só `/hooks/UserPromptSubmit`. O AC de encadeamento automático via `ginga install` não chega ao usuário.

## Fazer
- Condição de projeção: `ctx.plugin === undefined` (chamada direta do adapter, contrato congelado) **ou** a fonte traz artefatos de handoff (`<source>/skills/handoff/SKILL.md` ou `<source>/contrib/claude-mod-handoff/.claude-plugin/plugin.json` existem). Nesse caso `ensureHandoffHooks(settings)` roda sempre no `apply`, e `owned[".claude/settings.json"]` declara `/hooks/Stop` E `/hooks/UserPromptSubmit` (hoje só o UserPromptSubmit).
- Mod: se `<source>/contrib/claude-mod-handoff/.claude-plugin/plugin.json` existe, o apply registra em `installed_plugins.json` a chave `<nome-do-mod>@<market>` (nome lido do plugin.json do mod) com entrada `{scope:"user", installPath: join(source,"contrib","claude-mod-handoff"), version, installedAt, lastUpdated}` e habilita em `settings.enabledPlugins`; `owned`/`volatile` de `installed_plugins.json` e `owned` de `settings.json` devem declarar os ponteiros do mod (estado do módulo como `handoffHooksProjected`, lido depois do apply).
- Idempotente: 2º apply não duplica hooks nem entradas do mod; hook alheio em `settings.json` preservado.
- A fonte sem artefatos de handoff (ex.: fonte fake da suíte congelada T12) continua SEM projetar hooks — `tests/install/install.test.ts` (frozen) exige `hooks` inalterado nesse caso.

## Interface (teste RED tests/install_handoff_real.test.ts)
- Fonte temporária com `skills/handoff/`, `contrib/claude-mod-handoff/` (cópia do repo) e `.claude-plugin/marketplace.json` (`name: pi-harness-local`); HOME temporário com `settings.json` tendo `theme` e um hook `Stop` alheio. `installCmd` dry-run depois apply com `GINGA_PLUGIN_SOURCE=<fonte>`: exit 0; `settings.json` tem `Stop` e `UserPromptSubmit` com exatamente 1 comando `ginga handoff hook --runtime claude` cada (hook alheio intacto); `installed_plugins.json` tem as chaves `pi-harness@pi-harness-local` e `claude-mod-handoff@pi-harness-local` (installPath dentro da fonte); `enabledPlugins` tem as duas chaves; `claudeAdapter.owned` declara `/hooks/Stop` e `/hooks/UserPromptSubmit`.
- Chamada direta do adapter com `plugin` no ctx (cenário do `install.ts:856`): `claudeAdapter.apply(home, {source, now, plugin: "pi-harness"})` projeta os dois hooks.
- Idempotência: 2º dry-run+apply → hooks e mod uma vez só.

## Não fazer
- Não alterar `tests/install_handoff_claude.test.ts` nem `tests/install/install.test.ts` (frozen); não instalar nada no HOME real; não tocar outros adaptadores nem `src/install/install.ts` (a correção é toda no adapter).
