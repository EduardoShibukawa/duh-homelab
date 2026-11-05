---
type: plan
title: Learnings que funcionam (captura limpa, replan com teto, handoff lê bullets, lições curadas)
intent: INTENT-0005-handoff-e-learnings
kind: change
status: approved
repos: [duh-homelab, manda, ginga]
depends_on: []
done_when: "bash .ginga/bin/tests/learning-capture.test.sh && cd manda && bun test tests/replan_learnings_cap.test.ts && cd ../ginga && bun test tests/handoff_bullet_learnings.test.ts"
---
## Objetivo

Análise de 2026-11-05: o ciclo de learnings captura lixo, não promove nada e quase não chega a quem precisa.

- `dispatch-task.sh` (linha ~93) faz `grep -i -m1 'learning:'` no log inteiro do executor e grava tudo depois do `learning:`, inclusive eco do prompt e JSON de ferramenta. Resultado: 2 de 83 entradas (PLAN-0011 e PLAN-0022) têm 7 mil e 18 mil caracteres, 54% dos bytes.
- `manda/src/replan.ts:38` injeta o `LEARNINGS.md` inteiro, sem teto, no prompt do replan.
- `ginga/src/handoff.ts` só lê entradas `## L-NN`; as 83 entradas em bullet (`- TASK-NN (modelo): texto`) nunca entram num handoff. O `ginga lint` também as ignora.
- `knowledge/lessons/` está vazia: nada foi promovido.

Decisão (harness-decide-o-coberto): manter a captura em bullet (barata para executor free), limpar na origem, limitar no consumo e fazer o handoff ler os bullets. Lições curadas ficam em `knowledge/lessons/` à mão, no formato do `ginga lessons`.

## TASKs

1. [TASK-01](TASK-01-captura-limpa.md): captura limpa no `dispatch-task.sh` (raiz; troca por `mv` atômico, só com as lanes paradas ou na virada de rodada)
2. [TASK-02](TASK-02-replan-com-teto.md): manda, replan com teto no LEARNINGS
3. [TASK-03](TASK-03-handoff-le-bullets.md): ginga, handoff lê os bullets
4. TASK-04 (sem arquivo: trabalho de conteúdo do Planner): limpar os dois LEARNINGS poluídos e promover lições reais para `knowledge/lessons/`

## Riscos

- TASK-01 mexe num script que as lanes usam agora (o operador chama `dispatch-task.sh`): escrever `dispatch-task.sh.new`, testar, `mv`.
