---
type: plan
title: Manda-CARU núcleo — CLI manda e runtime port (A1)
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: done
repos: [manda, pi-harness]
depends_on: [PLAN-0004-eventos-e-lint]
done_when: "cd manda && bun test && bun test tests/e2e/two_runtimes.test.ts"
---
## Objetivo

Extrair o orquestrador de dentro do Pi para o repo `manda/` (a criar): uma CLI `manda run <PLAN>` que lê o bundle, sobe o executor no runtime certo em worktree isolada, passa pelo gate e emite `attempt`/`transition`. O Pi vira só um host adapter.

## Abordagem

- **Portar, não importar.** O núcleo vem de `pi-harness/.pi/extensions/runners.ts` (1200 l.), `worktree.ts` (271 l.) e trechos de `sdlc.ts` (4698 l.). Esses arquivos importam `@earendil-works/pi-coding-agent` e `src/hud/controls.ts`; o manda não pode depender de nenhum dos dois.
- Runtime port: `RuntimeAdapter { name; family(model); run(req) → {passed, usage, failure, stdout} }`. Adapters: pi, opencode, claude, codex (recusado como executor, gate `PI_CODEX_ENABLED`), agy.
- Gate genérico: `[commands].verify` do `project.toml` (padrão: o `done_when` da TASK). Com pinga: `pinga verify {task} --root {repo}`. O manda não conhece o pinga.
- `tests_frozen`: o manda restaura esses arquivos da base antes do gate e marca `tests_frozen_changed` se o diff do executor os tocou. Isso soma ao guard que o pinga já tem (`guards.ts`).
- O routing completo (ROUTING, escalada, budget, judge) é o PLAN-0008. Aqui o runtime vem de `project.toml [runtimes]` ou de um mapa `tier → runtime` simples.
- **Execução:** TASKs como `tasks/T<N>/PLAN.md` em `manda/` (pinga desde o `git init`) e no pi-harness.

## TASKs

1. [TASK-01](TASK-01-manda-repo.md): repo `manda/` + CLI
2. [TASK-02](TASK-02-leitor-bundle.md): leitor de PLAN/TASK + ordem do DAG
3. [TASK-03](TASK-03-runtime-pi-opencode.md): runtime port + pi + opencode
4. [TASK-04](TASK-04-runtime-claude-codex-agy.md): claude, codex, agy
5. [TASK-05](TASK-05-worktree-gate.md): worktree, gate genérico e `tests_frozen`
6. [TASK-06](TASK-06-manda-run.md): `manda run` + eventos
7. [TASK-07](TASK-07-e2e-dois-runtimes.md): e2e com dois runtimes no mesmo PLAN
8. [TASK-08](TASK-08-pi-host-adapter.md): `/manda` no Pi (host adapter)

## ACs da SPEC cobertos

- O orquestrador roda como CLI fora do Pi e sobe pelo menos dois runtimes diferentes num mesmo PLAN.
- Cada ferramenta emite em `$GINGA_EVENTS` (manda). O executor não consegue alterar `tests_frozen` (parte do manda).

## Riscos

- Os parsers de saída dos runtimes dependem de formatos não documentados (JSONL do pi/opencode/codex); os fixtures precisam vir de saídas reais.
- `sdlc.ts` mistura UI do Pi com lógica: só portar o necessário; o resto (DREAMS, UX gate, Reality BDD) fica fora deste PLAN.
