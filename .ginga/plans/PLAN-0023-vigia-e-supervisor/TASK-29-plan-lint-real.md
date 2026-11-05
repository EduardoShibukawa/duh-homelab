---
type: task
mode: padrao
goal: "manda plan com o ginga lint real: só erro de frontmatter bloqueia (staging plano), prompt pede intent, suíte hermética quanto ao ginga do PATH"
title: PLAN-0023 TASK-29 — manda plan x ginga lint real
plan: PLAN-0023-vigia-e-supervisor
repo: manda
depends_on: [TASK-23-lane-paridade2]
tier: free
pinga_task: T114
touch: [src/plan.ts, tests/setup.ts, bunfig.toml, tests/plan_lint_real.test.ts, tasks/T114/PLAN.md]
done_when: "bun test tests/plan_lint_real.test.ts tests/plan_cmd.test.ts"
tests_frozen: [tests/plan_lint_real.test.ts]
---

## Fazer
- `src/plan.ts` `runGingaLint`: chamar `ginga lint <staging> --json` (o 1º arg continua `lint`, o 2º a pasta plana). Exit 0 → ok. Exit ≠ 0: `JSON.parse(stdout)`; se vier `{errors:[…]}`, bloqueiam só os erros com `field === "frontmatter"`, `message === "obrigatório"` ou `message` começando em `inválido:` (os relacionais do staging plano — "PLAN sem nenhuma TASK", "plan inexistente", "depends_on inexistente", numeração — não valem fora de um bundle); `output` = esses erros como `arquivo: campo: mensagem`. JSON ilegível em exit ≠ 0 → inválido, `output` = texto cru.
- `buildPrompt`: em "Campos obrigatórios:" o PLAN.md passa a ter `type, title, intent` (id do INTENT de origem).
- `tests/setup.ts` + `bunfig.toml` (`[test] preload = ["./tests/setup.ts"]`): remove de `process.env.PATH` os diretórios que contêm um executável `ginga`, antes dos testes.
## Não fazer
- Não alterar `tests/plan_cmd.test.ts` nem `tests/plan_lint_real.test.ts`.
