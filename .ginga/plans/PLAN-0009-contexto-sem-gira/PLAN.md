---
type: plan
title: Gira sem caso especial (A3) + porta de contexto com fallback rg
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: done
approved: 2026-10-29
repos: [gira-g, p-inga, manda]
depends_on: [PLAN-0005-pinga-task-e-plan, PLAN-0008-manda-routing-e-judge]
done_when: "cd gira-g && mise exec -- go test ./... && cd ../manda && bun test && cd ../p-inga && bun test"
---
## Objetivo

O gira volta a ser folha (sem saber que o pinga existe), o contexto passa por uma porta com a mesma saída via gira ou via `rg` + `git`, e um repo novo sem gira roda INTENT → PLAN → TASK → verify só com Pi + pinga + manda.

## Abordagem

- **A3:** os casos especiais estão em `internal/docsite/tour.go:309` (passos do tour), `landing.go:18` (`FormatProjectTitle`), `landing.go:425` (comandos de exemplo) e `landing.go:533` (pilares). O conteúdo vai para a config do repo-alvo (seção `docsite:` do `gira.yaml`), e o p-inga recebe esse conteúdo no `gira.yaml` dele.
- **Porta de contexto** (doc 02 §2): protocolo `<provider> capabilities|outline|slice|impact --json`. Mora no manda (`manda context`), que é o consumidor principal; o gira ganha `gira capabilities --json`. O fallback `rg` + `git` é embutido.
- **A6:** mensagens de hook e o `doctor` do pinga só citam o gira quando o provider é o gira.
- **Execução:** PLAN-0005 e PLAN-0008 fechados: TASKs do bundle via `manda` (`pinga verify --root`), uma worktree `plan/0009` por repo, merge pelo merge-gate. No gira-g, lefthook via `mise exec`.

## TASKs

1. [TASK-01](TASK-01-gira-tour-config.md): tour e landing do docsite vindos da config (gira-g)
2. [TASK-02](TASK-02-pinga-gira-yaml.md): conteúdo do site do P-Ingá no `gira.yaml` do p-inga
3. [TASK-03](TASK-03-gira-capabilities.md): `gira capabilities --json`
4. [TASK-04](TASK-04-context-port.md): `manda context` + adapter gira
5. [TASK-05](TASK-05-context-rg.md): fallback `rg` + `git` com a mesma saída
6. [TASK-06](TASK-06-pinga-a6.md): mensagens do pinga condicionais ao provider (A6)
7. [TASK-07](TASK-07-e2e-sem-gira.md): e2e INTENT → PLAN → TASK → verify sem gira

## ACs da SPEC cobertos

- O gira não tem caso especial para o pinga (A3).
- Uma porta de contexto entrega slices pelo gira quando ele existe e por `rg` + `git` quando não existe, com a mesma saída.
- Um repo novo, sem gira, consegue rodar INTENT → PLAN → TASK → verify só com Pi + pinga + manda.

## Riscos

- ~~Worktree `gira-g-ux`~~ resolvido (2026-10-29): a worktree e a branch `task/ux-unificado` sumiram; o conteúdo entrou na main pelo PR `feat/generic-multi-project-docsite` (`8595f44`).
- A TASK-02 roda `gira docs` e precisa do binário com a TASK-01: reinstalar o gira (`mise run install`) a partir da main do gira-g depois do merge da TASK-01, ou rodar o executor da TASK-02 só depois desse merge.
- "Mesma saída" entre gira e rg só é possível no schema e no conjunto de arquivos; a precisão do rg é menor (sem AST). O teste compara schema + caminhos num fixture.
- O e2e (TASK-07) depende do `pinga` instalado no PATH e do `manda plan` do PLAN-0008.
