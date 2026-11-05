---
type: task
mode: mvp
goal: "O .ginga/index.md do workspace passa a ser gerado pelo ginga, com o manual arquivado"
title: Workspace usa o index.md gerado
plan: PLAN-0012-roda-web
repo: duh-homelab
depends_on: [TASK-06-index-gerado]
tier: free
touch: [.ginga/index.md, .ginga/index.template.md, _archive/, CLAUDE.md, AGENTS.md]
done_when: "grep -q 'gerado por ginga' .ginga/index.md && test -f .ginga/index.template.md && ginga index --check --root ."
tests_frozen: []
---
## Fazer
- Copiar o `index.md` manual para `_archive/` (registrar no `MANIFEST.md`), extrair o texto livre para `index.template.md` e rodar `ginga index`.
- CLAUDE.md/AGENTS.md: "o `index.md` é gerado; edite o template ou use verbos".
## Interface
- Nenhuma nova: usa `ginga index` e `ginga index --check` da TASK-06.
## Não fazer
- Não apagar o manual.
## Contexto
- `_archive/MANIFEST.md` (PLAN-0002).
