---
type: intent
title: Organizar o duh-homelab, os repos e as docs
source: cli
timestamp: 2026-10-28T00:10:00-03:00
status: open
---
## Pedido do dono

"precisamos organizar os projetos e o duh-homelab também, não? Tô vendo um monte de coisa em tudo, tá uma bagunça, inclusive as docs dos projetos."

## Inventário (2026-10-28)

- **Raiz do workspace:** 33 entradas.
  - 11 são worktrees soltas: 5 `*-plan-*` ativas, `p-inga-governed-roles`, `p-inga-run-status`, `pi-harness-ux`, `pi-harness-bench-uxjudge`, `gira-g-ux`.
  - Legado do pi-harness: `.pi/`, `features/`, `specs/`, `dreams/`, `LESSONS.md`.
  - Pastas vazias: `tasks/` e `intents/`.
  - `bin/` (homelab, dashboard, tuios) e `scripts/` (1 arquivo).
  - `docs-benchmark/` (repo git, sem uso recente) e `llm-bench/` (31 GB, não é git: modelos e benchmarks).
- **pi-harness:**
  - 6 `.md` na raiz: `CLOSEOUT-0011`, `FRICTION`, `HANDOFF-0043`, `OVERNIGHT-REPORT-0008`, `LESSONS` e o `README`.
  - Arquivos fora do git, com risco de perda: `HANDOFF-0043.md`, `intents/0054` e `0055`, `specs/draft-0055`.
- **p-inga:** `AGENTS.md`, `CLAUDE.md` e `GEMINI.md` são três instruções de agente diferentes entre si, ou seja, há deriva.
- **gira-g:** 83 docs em `docs/`, mais `ARCHITECTURE.md` e `CONTEXT.md` na raiz. Precisa verificar se há sobreposição.
- **manda (repo principal):** tem uma cópia antiga, fora do git, de `bin/`, `src/`, `tests/` etc., de 17:11, feita pela primeira execução na pasta errada. Isso vai bater com o merge do PLAN-0007 e precisa ser arquivado antes.

## Direção proposta (a validar)

- **Raiz:** só instruções, `.ginga/`, os repos e `worktrees/`, para onde vão todas as worktrees via `git worktree move`.
- **Por repo:**
  - `README` com "Name origin";
  - um único `AGENTS.md`, com `CLAUDE.md` e `GEMINI.md` apontando para ele;
  - docs de produto em `docs/`;
  - relatórios, handoffs e closeouts saem da raiz: vão para o `.ginga/` ou para `docs/archive/`.
- **Design entre repos** em `.ginga/knowledge/`. Lições espalhadas (`LESSONS.md`, DREAMS) vão para `knowledge/lessons/` (06 §5).
- **Nunca apagar:** mover para `_archive/`, com manifesto.
- Executar só **depois** que as ondas 1–2 fecharem, porque as worktrees estão ativas.

## Decisões do dono (2026-10-28)

1. O `llm-bench` fica no duh-homelab.
2. Vai existir um **`bench/`** na raiz, juntando o `llm-bench` (como `bench/llm/`) e o `docs-benchmark` (como `bench/docs/`). Os modelos (29 GB) ficam fora do git, por gitignore ou symlink para um cache. A integração com o harness entra no PLAN-0014 (A/B e Métricas). Hoje o bench está espalhado em 5 lugares (doc 03 §5): `p-inga/src/bench`, `pi-harness/benchmarks`, `llm-bench`, `docs-benchmark` e `gira-g/bench`.
3. **Só a estrutura**, sem auditoria de conteúdo das docs.

## Sandbox: opção A aprovada

O `done_when` roda no `bwrap` via wrapper do pinga (`PINGA_EXEC_WRAPPER`). É uma TASK no p-inga, a fazer depois do merge do PLAN-0005, que mexe no `verify.ts`.

## Licenças (DECISION-0003)

A organização inclui pôr `LICENSE` MIT em p-inga, pi-harness, ginga, manda e bench, que hoje não têm nenhuma; o gira-g já é MIT. Também inclui `"license": "MIT"` no `package.json` de cada um.

## Nome g-inga ([DECISION-0004](../knowledge/decisions/DECISION-0004-repo-g-inga.md))

Depois que o PLAN-0004 fechar:

- renomear `ginga/` para `g-inga/` (a worktree vai junto, via `git worktree repair`);
- trocar o `name` do `package.json` para `g-inga`;
- trocar, nas docs, as menções ao **repo** (não ao CLI `ginga`).

O antigo `EduardoShibukawa/G-Inga` já virou `g-inga-v1`, arquivado.
