---
repo: manda
---
# TASK-14 — paridade do `manda lane` com `.ginga/bin/lane.sh`

- **PLAN:** PLAN-0023-vigia-e-supervisor
- **Repo:** manda

## Critérios de aceite
- [x] PLAN-0023 paridade do `manda lane` com `.ginga/bin/lane.sh` (pré-requisito do corte; TASK com RED em `src/pipeline.ts`):
  - (a) o prompt de cada rodada é gerado do estado: `.ginga/prompts/op-base.md` + os itens não-ok do `judge/<repo>.json` de cada `ready/<repo>.json` + a última linha do gate no `log.md` + `backlog-<repo>.md`;
  - (b) o operador roda `opencode run --standalone --auto -m <modelo> --title <nome>` com um vigia de **progresso real** (arquivos alterados nas worktrees do repo ou saída não-"> build" no log). 15 min sem progresso → mata **pelo pid** (não por padrão de texto) e troca de modelo (`[supervisor] models`, padrão `opencode/glm-5.3-flash-free`, `opencode-go/beam-free`);
  - (c) aborta com exit 20 se a `main` do repo mudar durante o operador;
  - (d) o `heartbeat.progress` é efeito real, nunca `executed`.
  - RED: cada um de (a)–(d) com fixture; o resultado de uma rodada igual ao do `lane.sh` para o mesmo estado.

## done_when
Testes de (a)–(d) em `manda/tests/` verdes; `bun test` sem falha.
