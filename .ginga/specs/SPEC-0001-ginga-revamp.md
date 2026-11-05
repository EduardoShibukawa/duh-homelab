---
type: spec
title: G-Ingá revamp
intent: INTENT-0001-ginga-revamp
status: approved
approved: 2026-10-27
bench: none
---
## Objetivo

Separar o harness em pacotes desacoplados e usáveis sozinhos (pinga como gate, o orquestrador agnóstico de runtime Manda-CARU (`manda`), ginga como UX/async/notificação) e unificar o trabalho em INTENT → SPEC → PLAN → TASK.

O desenho completo está em [design/ginga-revamp](../knowledge/design/ginga-revamp/README.md). Esta SPEC é a porta de entrada; o detalhe fica lá.

## ACs

- [ ] O pinga verifica `TASK-*.md` e `PLAN.md` e não referencia mais o pi-harness (A2 do doc 03).
- [ ] O orquestrador roda como CLI fora do Pi e sobe pelo menos dois runtimes diferentes num mesmo PLAN.
- [ ] O gira não tem caso especial para o pinga (A3).
- [ ] Cada ferramenta emite eventos em `$GINGA_EVENTS` e funciona sem ele.
- [ ] Um repo novo, sem gira, consegue rodar INTENT → PLAN → TASK → verify só com Pi + pinga + manda.
- [ ] Os eventos seguem o schema de [07](../knowledge/design/ginga-revamp/07-eventos.md) (envelope `v:1`), e o `events.jsonl` do pi-harness é migrado.
- [ ] `ginga lint` valida o bundle `.ginga/` (frontmatter, relações, IDs únicos, PLAN com ≥1 TASK; TASK com `mode`, `goal`, `done_when`, `touch`) e exporta para OKF v0.1.
- [ ] Uma porta de contexto entrega slices pelo gira quando ele existe e por `rg` + `git` quando não existe, com a mesma saída.
- [ ] O manda escolhe o modelo pelo `tier` e pelo [ROUTING](../models/ROUTING.md), escala `free → medium → strong`, respeita os tetos de budget (TASK, PLAN, mês) e pede OK só ao passar do teto ou ao cair no claude. `project.toml [runtimes]` tem precedência.
- [ ] O Verifier Judge é cego (só artefatos crus) e de família diferente do executor e do Planner; o executor não consegue alterar os arquivos em `tests_frozen`.
- [ ] A triagem só promove (trilha pequena → feature), nunca rebaixa.
- [ ] A instalação/adoção sai do pinga para o ginga (A2), e o `bin/homelab` vira `ginga` (A5).

## Interface (Roda)

Superfície visual para ver, aprovar, comandar e ser notificado sem precisar de conversa: web, TUI, Discord, Telegram, push e skills, todas como clientes finos dos mesmos verbos do `ginga`. Desenho completo em [05 — Interface](../knowledge/design/ginga-revamp/05-interface.md).

- [ ] Toda ação (intent, approve, answer, decide, pause, retry, budget, handoff, init) existe como verbo na CLI e na API, e nenhuma superfície tem lógica própria.
- [ ] A Roda Web mostra Inbox, Quadro e PLAN a partir do `.ginga/` e substitui o `index.md` escrito à mão.
- [ ] Um blocker chega no Discord e no Telegram (porta de notificação: Hermes, com fallback para o webhook do Discord e stdout), e responder na thread destrava o PLAN.
- [ ] `ginga tick` é idempotente, com claim e lease: rodar dois ticks em paralelo nunca despacha a mesma TASK duas vezes. `ginga serve`, o systemd timer e o cron do Hermes chamam o mesmo tick.
- [ ] `ginga init` prepara um repo novo (`.ginga/` + `project.toml`) e o fluxo do onboarding funciona sem gira.
- [ ] A API e a Roda Web exigem autenticação (token ou allowlist da tailnet); sem isso o `serve` só escuta em localhost.
- [ ] O dashboard de Métricas mostra FTPR, custo por TASK verificada, falhas por motivo e quota por provider.
- [ ] A tela de quota lê o Codex (rollout JSONL) e o Claude (statusline gravando `rate_limits`) automaticamente; AGY e OpenCode Go aparecem como "manual".

## Handoff e learnings

Desenho em [06](../knowledge/design/ginga-revamp/06-handoff-e-learnings.md).

- [ ] `ginga handoff <PLAN>` gera o handoff sem LLM, só a partir dos arquivos e do git.
- [ ] Todo PLAN tem `log.md` (automático) e `LEARNINGS.md`; `kind: investigation` funciona com o mesmo verify.
- [ ] Learnings promovidos viram `LESSON-*.md` e o Planner os encontra pelo `touch`.
- [ ] O A/B nativo vs handoff roda na ontologia de bench, e "erros repetidos" aparece no dashboard.

## Nomes

Decidido em [DECISION-0001](../knowledge/decisions/DECISION-0001-nomes.md): orquestrador **Manda-CARU** (`manda`), console **Roda**.

## Riscos

- O `duh-homelab` não é git: o `.ginga/` do workspace não tem histórico (mitigação: `log.md` + eventos `transition`; backup periódico).
- `pi-harness/HANDOFF-0043.md` e as intents 0054 e 0055 não estão rastreadas no git e podem se perder.
- A API e a Roda na rede sem auth expõem o controle dos agentes (por isso o AC de auth).
- As fontes de quota (rollout do Codex, statusline do Claude) usam formatos não documentados e podem mudar sem aviso.
- A SPEC é grande: o Planner deve quebrá-la em PLANs ordenados, em que cada um entrega algo usável.

## Aprovação

- Nome e mensageria resolvidos (DECISION-0001 e DECISION-0002); protótipos revisados pelo dono no canvas.
- Aprovada em 2026-10-27. Próximo passo: o Planner gera os PLANs.
