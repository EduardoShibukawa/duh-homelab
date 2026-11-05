# G-Ingá Revamp

Redesenho da arquitetura do G-Ingá: um harness pessoal e portável, que funciona em qualquer projeto e com qualquer runtime (Pi, Claude, Codex, OpenCode, AGY, Hermes). Cada peça também precisa ser usável sozinha.

## Documentos

| # | Documento | Status |
|---|---|---|
| 01 | [Proposta inicial](01-proposta-inicial.md): o desenho original e a primeira revisão | fechado |
| 02 | [Visão atualizada](02-visao-atualizada.md): pacotes, portas, trilhas, falhas, papéis | em discussão |
| 03 | [Situação atual](03-situacao-atual.md): inventário, dependências reais, duplicações, estado, gap | rascunho |
| 04 | [Artefatos](04-artefatos.md): INTENT/SPEC/PLAN/TASK, cardinalidade, async e convenção OKF | em discussão |
| 05 | [Interface (Roda)](05-interface.md): superfícies, verbos, telas, Discord, notificações | proposta |
| 06 | [Handoff e learnings](06-handoff-e-learnings.md): checkpoint contínuo, LEARNINGS.md, PLAN de investigação, A/B | proposta |
| 07 | [Eventos](07-eventos.md): schema JSONL de `$GINGA_EVENTS` | proposta |
| 08 | [Execução](08-execucao.md): ondas, quota por papel, prompts em `.ginga/prompts/` | proposta |
| 09 | [Observabilidade](09-observabilidade.md): palestra Arize, Phoenix opcional, OTLP, métricas | proposta | (2026-10-28) |
| 10 | [Sandbox](10-sandbox.md): isolamento, fases, networking, perfil declarativo, matriz | proposta | (2026-10-28) |
| 11 | [Handoff automático](11-handoff-automatico.md): gatilhos (cache/contexto), núcleo, adapters por runtime, TASKs 08–13 | proposta | (2026-10-29) |

## Decisões

1. **Três pacotes + contexto.** O pinga fica enxuto (gate). O **orquestrador** é agnóstico, extraído do pi-harness: **Manda-CARU** (`manda`). O **ginga** fica com UX, async, notificação, install, memória e bench. O gira é opcional, atrás de uma porta de contexto.
2. **O pi-harness sai como pacote**, porque o orquestrador dele roda como extensão do Pi. Os runtimes e os hosts viram adapters.
3. **Dependências:** `ginga → {orquestrador, pinga}`, `orquestrador → runtime port`, `{orquestrador, pinga} -.-> context port` (opcional).
4. **Integração só por CLI, JSON e arquivos.** CLI primeiro, MCP opcional. Cada ferramenta emite eventos JSONL (`$GINGA_EVENTS`) e o ginga roteia.
5. **Artefatos:** INTENT → SPEC (opcional) → PLAN → TASK. Toda SPEC tem PLAN; nem todo PLAN tem SPEC; todo PLAN tem TASKs e toda TASK pertence a um PLAN.
6. **Trilha pequena = PLAN sem SPEC.** A triagem só promove, nunca rebaixa.
7. **O async começa no PLAN aprovado.**
8. **Rotas de falha:** TASK falha → o Planner ajusta a TASK; abordagem errada → replan; Judge reprova algo simples → TASK de fix; Judge reprova algo inesperado → novo INTENT/SPEC; blocker → Discord e humano.
9. **Verifier Judge cego:** só artefatos crus, de outra família de modelo. O `tests_frozen` impede o Executor de mexer no teste do Planner.
10. **O arquivo guarda o contrato, o db guarda a execução.**
11. **OKF v0.1 como compatibilidade, não como fundação.** Relações ficam no frontmatter; parser e validador são nossos. O PLAN é `PLAN.md`, não `index.md`.
12. **Mensageria e fila** ([DECISION-0002](../../decisions/DECISION-0002-mensageria-e-fila.md)): Hermes como adapter, fila no `ginga tick`, `ginga serve` num host por workspace.
13. **Nomes** ([DECISION-0001](../../decisions/DECISION-0001-nomes.md)): orquestrador Manda-CARU, console Roda.
14. **Handoff e learnings** ([06](06-handoff-e-learnings.md)) e **eventos** ([07](07-eventos.md)).
15. **Tudo open source / OSI** ([DECISION-0003](../../decisions/DECISION-0003-tudo-open-source.md)): repos MIT; observabilidade por OTLP + OpenInference; backend padrão `ginga serve /v1/traces` + Roda; Phoenix/Jaeger etc. opcionais via `GINGA_OTLP_ENDPOINT` (2026-10-28).
16. **Repo e pacote `g-inga`, CLI `ginga`** ([DECISION-0004](../../decisions/DECISION-0004-repo-g-inga.md)) (2026-10-28).
17. **O pi-harness sai como pacote** (PLAN-0017): o Pi vira host adapter no manda; o repo vai para `_archive/` (2026-10-28).
18. **Roteamento 2026-10-28** ([models/ROUTING.md](../../../models/ROUTING.md)): papéis × modelos, Go só no opencode, sem escalada automática para strong (2026-10-28).
19. **Desbloqueio automático** ([INTENT-0008](../../../intents/INTENT-0008-resolver-dependencias.md)): TASK de desbloqueio por classe de `BLOCKED:` na rota de falhas (2026-10-28).
20. **Skills e hooks** ([INTENT-0009](../../../intents/INTENT-0009-skills-e-hooks.md), [SPEC-0002](../../../specs/SPEC-0002-skills-e-hooks.md)): fonte única `.ginga/skills/` + `hooks.toml` + perfis, gerador no `ginga install/init` (2026-10-28).
21. **Porta `Sandbox`** separada da porta de runtime ([INTENT-0006](../../../intents/INTENT-0006-sandbox-e-code-mode.md)): `sandbox.run(profile, cmd, worktree)` (2026-10-28).

## Em aberto

- Benchmark: como projetar (base: `pi-harness/src/bench`).
- Critérios numéricos da triagem.
- Migração do formato do pi-harness (os `tasks/T<N>/` do pinga ficam como legado).
- Destino das worktrees com trabalho não commitado.
