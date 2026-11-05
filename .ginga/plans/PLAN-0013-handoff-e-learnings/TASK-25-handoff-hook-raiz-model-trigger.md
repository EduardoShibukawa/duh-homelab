---
type: task
mode: mvp
goal: "Corrigir os achados graves do judge no hook de handoff (TASK-12/TASK-19): resolver a raiz do bundle (.ginga) a partir do cwd do stdin e gravar o handoff em <raiz>/handoffs (com conteúdo do PLAN), passar o modelo real no redirect (nunca --model \"\"), e aceitar trigger idle|manual no schema do evento handoff (TASK-11/TASK-18)"
title: Hook enraizado no .ginga + model real no redirect + trigger idle/manual válido
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T315
depends_on: [TASK-12-handoff-hook, TASK-19-handoff-hook-cli-correcao]
tier: free
touch: [src/handoff/hook.ts, src/handoff/policy.ts, src/verbs/handoff.ts, src/events/validate.ts, docs/events-v1.md, tests/handoff_hook_raiz.test.ts, tests/handoff_cli_hook.test.ts]
done_when: "bun test tests/handoff_hook_raiz.test.ts tests/handoff_cli_hook.test.ts tests/handoff_hook.test.ts tests/handoff_cli_session.test.ts tests/events.test.ts"
tests_frozen: [tests/handoff_hook_raiz.test.ts]
---
## Fazer
- **Raiz do bundle:** `runHook` resolve a raiz (.ginga) a partir do `cwd` do stdin subindo diretórios até achar um que contenha `.ginga/` (`resolveBundleRoot(cwd)`; fallback `join(cwd, ".ginga")`). Se `deps.root` for passado pela CLI (`runHookVerb` repassa `ctx.root`) e existir, ele vence. Usar essa raiz em TUDO: `parseConfig` (`<raiz>/project.toml`), estado (`<raiz>/state/handoff-<sess>.json`), `buildHandoff(raiz, ...)` e o handoff gravado em `<raiz>/handoffs/` (o `path` devolvido por buildHandoff; o mkdir é do diretório desse path). Com `plans/` na raiz, o handoff sai com o conteúdo do PLAN. Nunca gravar em `<cwd>/handoffs`.
- **Modelo real no redirect:** `model = cfg.model ?? process.env.GINGA_MODEL ?? "sonnet"` (mesmo default do verbo manual), passado ao `open(path, { userPrompt, model })`; `claude --bg` nunca sai com `--model ""`. Adicionar `model?: string` ao `HandoffCfg` e parsear `[handoff] model = "..."` em `parseHandoffCfg`/`applyFields` (src/handoff/policy.ts).
- **Trigger válido no schema:** `src/events/validate.ts` kind `handoff` passa a aceitar `trigger` em `boundary|context|cache|idle|manual`, e `docs/events-v1.md` (linha do kind handoff) é atualizado para o mesmo enum. Assim o evento emitido pela CLI de sessão (`--trigger idle|manual`, src/verbs/handoff.ts) é aceito pelo `ingest` (src/state/ingest.ts valida com validateEvent) e chega ao log.md/state.db.
## Interface
- Teste congelado novo `tests/handoff_hook_raiz.test.ts`:
  - ws temporário com `.ginga/project.toml` (mode suggest), `.ginga/plans/PLAN-0099-x/PLAN.md` e um subdiretório `repo/` passado como `cwd` no stdin → `runHook("claude", stdin Stop+120k, {now})` grava o handoff em `.ginga/handoffs/` (não em `repo/handoffs/`), o markdown contém "PLAN-0099", e o estado fica em `.ginga/state/`.
  - redirect com `deps.open` capturando `opts.model`: com `model = "modelo-toml"` no project.toml → model é "modelo-toml"; sem model no toml e `GINGA_MODEL=env-model` → "env-model"; sem nada → "sonnet". Nunca "".
  - `validateEvent` (via `emitEvent` para completar o envelope) aceita evento `handoff` com `trigger: "idle"` e `"manual"` (e continua aceitando "boundary").
- `tests/handoff_cli_hook.test.ts` (frozen da TASK-19, nossa) é atualizada no mesmo commit RED: handoffs em `fx.dir/.ginga/handoffs`, e no redirect o `claude` falso grava o argv num arquivo e o teste exige `--model` seguido de valor não vazio.
## Não fazer
- Não alterar os demais testes frozen (TASK-12 etc.); não mudar a decisão do `decideHandoff`; não corrigir ainda o evento fixo do `--open` (TASK-13, próxima rodada) nem o item de Inbox "promover?" (TASK-05). Sem scripts de depuração fora do `touch` (use /tmp).
## Contexto
- Achados graves do judge 2026-10-31T23:11 (gate exit 11): `src/handoff/hook.ts` usa `buildHandoff(cwd,…)` e grava em `<cwd>/handoffs` (fora de `.ginga`, sem `plans/` → handoff sem conteúdo do PLAN; tests/handoff_cli_hook.test.ts:97 consagrava isso) e passa `model: ""` no redirect (`claude --model ""`); AC handoff-automatico também cita evento `trigger idle` inválido pelo schema (src/events/validate.ts só aceita boundary|context|cache), que faz o ingest descartar (TASK-11/TASK-18).
