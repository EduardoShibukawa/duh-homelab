---
type: task
mode: padrao
goal: "Corrigir os achados do judge na TASK-03: handoff completo (estado das TASKs, git real nos repos, ordem descartada/armadilha primeiro, frontmatter determinístico no buildHandoff) e evento handoff válido pelo schema (context_tokens, data.file, plan no envelope)"
title: handoff completo (correção do judge 2026-10-30T02:07)
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T143
depends_on: [TASK-03-handoff]
tier: medium
touch: [src/handoff.ts, src/verbs/handoff.ts, tests/handoff_full.test.ts, tasks/T143/PLAN.md]
done_when: "bun test tests/handoff_full.test.ts tests/handoff.test.ts"
tests_frozen: [tests/handoff_full.test.ts]
---
## Fazer (achados do judge ginga-20261030T020548, TASK-03)
- `src/handoff.ts`: o git injetado roda em cada repo do frontmatter `repos:` do PLAN (`cwd = root/<repo>`), não no planDir; sem `repos`, cai no root.
- Estado das TASKs: cada `TASK-*.md` tem `pinga_task: T<N>` e `repo:` no frontmatter; o estado (state/receipt/última tentativa) vem de `pinga queue --json --root <root>/<repo>` (spawn de `pinga` permitido; sem fila ou sem dir, degrada sem crash e diz "sem fila"). A seção lista `TASK-xx (T<N>) — <state>[/<receipt.status>]`.
- `### Próxima TASK aberta`: primeira TASK (ordem dos arquivos) cujo estado não é done/superseded; sem fila, seção vazia com "sem fila".
- `### Blockers`: seção `## Blockers` do PLAN.md, se houver. `### SPEC`: `spec:` do frontmatter do PLAN.
- Learnings: ordem `descartada` e `armadilha` antes das demais (descartada antes de armadilha), depois o resto — o teste congelado do T142 (armadilha antes de confirmada) continua válido.
- Frontmatter dentro do `buildHandoff`: o `markdown` começa com `---\ntype: handoff\nplan: <PLAN|all>\ndate: <AAAA-MM-DD de now>\n---` e o `path` usa a mesma data — relógio só entra por `now`, nunca por `new Date()` dentro do verb.
- `src/verbs/handoff.ts`: injeta git real (`Bun.spawnSync(["git", ...args], { cwd })`, erro → ""), passa `now: new Date()` uma única vez e grava exatamente o `markdown` retornado.
- Evento `handoff` válido pelo `src/events/validate.ts`: envelope com `source` (ex.: "cli") e `plan` no nível superior (para o gancho do log.md ler `ev.plan`); `data` com `trigger: "boundary"`, `handoff_tokens > 0`, `context_tokens` (número, estimativa chars/4) e `file` (string, o path gravado) — sem `data.path`, sem `plan` dentro de `data`.

## Teste (novo, congelado aqui)
`tests/handoff_full.test.ts` (RED antes): git com cwd no repo do PLAN; estado T900 done/pass e próxima aberta T901; ordem descartada < armadilha < confirmada; frontmatter com `date` de `now`; SPEC e Blockers no markdown; CLI grava arquivo e emite evento que passa em `validateEvent`, com `ev.plan` e `data.file`/`context_tokens`, e cai no `log.md` via `appendPlanLog`; CLI com repo git real mostra `??` no status (prova do git injetado).

## Não fazer
- Não alterar `tests/handoff.test.ts` (frozen do T142) nem os frozen de outras TASKs; não tocar em TASK-04+; sem gatilho automático (TASK-10).

## Contexto
- Judge: `.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T020548.log` (TASK-03 "grave"). Interface do PLAN.md continua valendo; `queue` entra como injeção opcional `opts.queue` (padrão: spawn de `pinga queue --json --root <repoDir>`, só se o dir existir).
