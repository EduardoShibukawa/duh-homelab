---
type: plan
title: Merge gate determinístico no pacote (manda merge) no lugar dos scripts .ginga/bin
intent: INTENT-0008-resolver-dependencias
kind: feature
status: approved
repos: [manda, ginga]
depends_on: [PLAN-0008-manda-routing-e-judge]
---
## Objetivo
Levar para o `manda` o fluxo em processos separados que hoje mora em `.ginga/bin/judge-run.sh`, `merge-gate.sh` e `pipeline.sh`. Esses scripts foram escritos direto em 2026-10-28, com OK do dono, depois que o operador LLM mergeou o PLAN-0008 sem judge e quebrou o e2e. O LLM nunca mergeia: o merge é código determinístico.

## Contexto
- Os scripts atuais são a especificação executável: códigos de saída 10/11/12/13/14/15 e o revert automático. Veja o teste no `log.md` do PLAN-0008, com exit 10, 11 e 13.
- Hooks `pre-merge-commit` + `pre-commit` (MERGE_HEAD na main exige `MERGE_GATE=1`) instalados à mão em manda, p-inga e ginga, com OK do dono em 2026-10-28. A instalação versionada vem pela SPEC-0002 (hooks do host via `ginga install`).
- O judge cego do manda (`src/judge.ts`, PLAN-0008 TASK-07) passa a ser o motor do `manda judge`. Ele precisa emitir `regression` por item.
- `knowledge/research/determinismo-e-placement.md` §5: merge é uma operação da faixa determinística.

## TASKs
- TASK-01 `manda merge <PLAN> <repo> <branch>`: os mesmos códigos de saída de `merge-gate.sh`.
- TASK-02 `manda judge <PLAN> <repo> <branch>`: veredito JSON com `head` e `regression`.
- TASK-03 `manda pipeline <prompt>`: operador → judge → merge, abortando se a main andar. Depois, `.ginga/bin/*.sh` vão para `_archive/` com MANIFEST.
- TASK-04 (ginga) `ginga hooks install|check`: instala de forma versionada e idempotente os hooks git de `.ginga/hooks/git/` nos repos de `hooks.toml`. Encadeia com hk/lefthook/`core.hooksPath`, sem sobrescrever. Usa `reference-transaction` para barrar qualquer update de `refs/heads/main` sem `MERGE_GATE=1`, inclusive fast-forward. `ginga doctor` acusa drift. Depois disso, os hooks feitos à mão em 2026-10-28 são substituídos (o original vai para `_archive/`).
