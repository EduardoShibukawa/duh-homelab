---
type: task
mode: padrao
goal: "ginga hooks install instala os hooks git versionados de forma idempotente e encadeada; ginga hooks check sai !=0 com drift"
title: ginga hooks install/check (hooks git versionados)
plan: PLAN-0022-merge-gate-no-pacote
repo: ginga
depends_on: []
tier: medium
pinga_task: T25
touch: [src/hooks/, src/cli.ts, tests/hooks_install.test.ts, tests/fixtures/hooks/]
done_when: "bun test tests/hooks_install.test.ts"
tests_frozen: [tests/hooks_install.test.ts, tests/fixtures/hooks/]
---
## Fazer
- A fonte é `.ginga/hooks/git/<hook>` + `hooks.toml` (`[git] repos = [...]`, `hooks = ["reference-transaction"]`).
- Install idempotente: rodar 2× deixa o mesmo resultado. Um hook existente (hk, lefthook, script) é preservado e chamado depois do nosso. `core.hooksPath` é respeitado.
- O `reference-transaction` recusa update de `refs/heads/main` sem `MERGE_GATE=1` (merge, ff, reset), em repo git temporário de fixture.
- `check`: hook ausente ou diferente da fonte → exit 1, listando o repo e o hook.
## Não fazer
- Sem rede, sem push, sem tocar repos reais no teste.
## Contexto
- Hooks feitos à mão em 2026-10-28 (manda, p-inga, ginga): `pre-merge-commit` + guarda no `pre-commit`. Ver REPORT-2026-10-28.
- SPEC-0002 (hooks do host) e `knowledge/research/skills-e-hooks.md`.
