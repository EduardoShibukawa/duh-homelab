---
type: intent
title: Skills e hooks no harness, entregues por sandbox
source: cli
timestamp: 2026-10-28T00:10:00-03:00
status: open
---
## Pedido do dono

"Faça uma pesquisa também para entender se precisamos de skills e hooks em nosso harness. Eu acho que isso funcionaria muito bem com os sandbox, visto que poderíamos mandar só o necessário para cada um, e skills aceitam determinístico com scripts, usando por exemplo TypeScript."

## Hipóteses

1. **Skills por TASK.** Uma skill (SKILL.md + scripts) entra na sandbox da TASK como mount somente leitura. Cada papel e cada TASK recebe só as skills de que precisa, o que dá menos contexto e menos superfície.
2. **Determinismo.** Os scripts da skill (TypeScript/bun) fazem a parte que não pode errar (validar, migrar, medir). O modelo só decide quando chamá-los. Isso se liga à H3 do PLAN-0016 (CLI + skill ≈ code mode).
3. **Hooks.** Fazem o enforcement do lado de fora: o host aplica gates que o modelo não contorna (tests_frozen, teto de custo, `git add -A`, provider proibido), além dos do lado de dentro da sandbox.
4. **Uma fonte, vários runtimes.** Um setup gera as skills e os hooks para Claude, Codex, OpenCode, Pi, AGY e Hermes a partir de uma definição única. Liga-se ao "setup gerador" da retrospectiva (`knowledge/research/sessao-2026-10-27/analise.md`) e aos PLAN-0006 e PLAN-0015.

## Saída esperada

`knowledge/research/skills-e-hooks.md`, com recomendação. Depois disso, uma SPEC ou emendas nos PLANs 0006, 0008, 0015 e 0016.
