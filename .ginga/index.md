# duh-homelab: quadro de trabalho

> Bundle OKF `okf: "0.1"`. **Toda sessão começa aqui.** Mantido à mão até o ginga gerar este arquivo.
> Convenção: [design/ginga-revamp/04-artefatos.md](knowledge/design/ginga-revamp/04-artefatos.md)
> **Arquitetura (visão):** [02-visao-atualizada.md](knowledge/design/ginga-revamp/02-visao-atualizada.md) (pacotes, portas, camadas, ciclo de vida, papéis) e [README do revamp](knowledge/design/ginga-revamp/README.md) (decisões 1–14). Decisões posteriores ainda não consolidadas no 02: [DECISION-0003](knowledge/decisions/DECISION-0003-tudo-open-source.md) (OSI/MIT), [DECISION-0004](knowledge/decisions/DECISION-0004-repo-g-inga.md) (g-inga), [PLAN-0017](plans/PLAN-0017-pi-harness-sai/PLAN.md) (pi-harness sai), [INTENT-0006](intents/INTENT-0006-sandbox-e-code-mode.md) (sandbox), [ROUTING 2026-10-28](models/ROUTING.md) (modelos por papel), [INTENT-0008](intents/INTENT-0008-resolver-dependencias.md) e [INTENT-0009](intents/INTENT-0009-skills-e-hooks.md).

## Como uma sessão trabalha

1. Leia este quadro e escolha uma TASK em **Pronto para pegar**, ou o item em **Esperando o dono** que o dono pediu.
2. Leia o `PLAN.md` da TASK. Se houver `spec:`, leia a SPEC também.
3. Escolha o runtime e o modelo pelo `tier` da TASK em [models/ROUTING.md](models/ROUTING.md), checando a quota (`quota_check` em `models/PROVIDER-*.md`).
4. Execute dentro do `touch`, rode o `done_when` e, em repo governado pelo pinga, rode `pinga verify`.
5. Registre o resultado no `log.md` do PLAN e atualize este quadro.

## Em execução

Nada na fila (2026-11-03 14:50, "TUDO PRONTO": backlogs vazios, nada aguardando gate). Lanes paradas; o `ginga-vigia.timer` (10 min) relança quando houver pendência. `handoffs/lane.env` (2026-11-03): escadas free só com Pi (laguna-s-2.1, north-mini, openrouter/free, muse, lightning) mais `opencode-go/iceman-contributor-free` (1º executor, último operador); Zen free segue sem cota; `ALLOW_PAID=0`.

**Guard de segredos (PLAN-0033):** código mergeado (ginga 01/11, manda 01/11). A fiação das lanes (TASK-06: `bin/guard-env.sh`, `lane.sh`, `dispatch-task.sh`, `bin/tests/guard-env.test.sh`) foi aplicada em 2026-11-03 20:03 (backups `*.bak-2026-11-03-guard`); Fase 2 com `.env` falso no Pi: bloqueio `basename_env`, sem vazamento. Falta só a ativação do plugin Hermes (ação do dono, `plugins.enabled` do perfil) e o teste da Fase 2 no opencode.

**Incidente 30/10:** um executor zerou `~/.local/share/opencode/opencode.db` (N9 em [problemas-harness-sessao-guard-2026-10-30](knowledge/research/problemas-harness-sessao-guard-2026-10-30.md)); banco recriado, Go reconectado pelo dono.

## Esperando o dono

| Item | O que precisa |
|---|---|
| [Cobertura da visão 02](knowledge/research/cobertura-visao-02-2026-10-29.md) | Lacunas 1 e 2 com PLAN aprovado (0028, 0029); 3–11 sem PLAN |
| SPEC-0002, SPEC-0003 | Draft |
| [PLAN-0031](plans/PLAN-0031-jev-classificadores-no-manda/PLAN.md) (Jev nos classificadores) | Draft de propósito: aprovar só depois do go da Fase 2 do PLAN-0030. Precisa de provider e chave do Jev e do seu OK para enviar log mascarado a terceiro (ou instalar o `lev` local). Pesquisa: [jev-gateway](knowledge/research/jev-gateway-2026-10-29.md) |
| [PLAN-0033](plans/PLAN-0033-guard-de-segredos/PLAN.md) (guard de segredos) | Código e TASK-06 aplicados; falta o dono ativar o plugin Hermes num perfil de lane (`plugins.enabled`) |
| [models/](models/ROUTING.md) | Budget do Zen quase no fim; quota do Claude via statusline |
| [DECISION-0001](knowledge/decisions/DECISION-0001-nomes.md) | O "Pi" do P-Ingá é o agente Pi ou o π? |
| [DECISION-0005](knowledge/decisions/DECISION-0005-apache-2-e-publicacao.md) (Apache-2.0 e publicação) | Repos publicados (2026-11-05). Falta mergear os PRs de sync p-inga #2 e gira-g #52 (o auto mode bloqueou o merge sem revisão) e as TASKs de LICENSE, portabilidade macOS e cleanup |

SPEC-0004, PLAN-0030 (só código) e PLAN-0032: **approved** pelo dono em 2026-10-29; PLAN-0032 (4 TASKs) em judge/merge na lane manda; sua antiga TASK-04 virou o PLAN-0034 (approved, espera PLAN-0029, 0032 e 0033 TASK-07). SPEC-0001: **approved** (2026-10-27). PLAN-0012, 0013, 0014, 0016, 0028 e 0029: **approved** pelo dono em 2026-10-29.

## Concluído

| PLAN | Quando |
|---|---|
| [PLAN-0002 bundle + cleanup](plans/PLAN-0002-workspace-bundle/PLAN.md) | 2026-10-27 |
| [PLAN-0004 eventos v1 + ginga lint](plans/PLAN-0004-eventos-e-lint/PLAN.md) | 2026-10-28 |
| [PLAN-0008 manda routing + judge](plans/PLAN-0008-manda-routing-e-judge/PLAN.md) | 2026-10-28 |
| [PLAN-0018 sandbox done_when](plans/PLAN-0018-sandbox-done-when/PLAN.md) | 2026-10-28 |
| PLAN-0003, 0005, 0007, 0010, 0020–0027 (mergeados pelo gate) | 2026-10-27 a 29 |
| PLAN-0006, 0009, 0011 (done); PLAN-0015 (falta a TASK-04) | 2026-10-29 |
| PLAN-0028, 0029, 0032, 0034 | 2026-10-31 a 11-01 |
| PLAN-0013, 0033 (código + fiação) | 2026-11-01 |
| PLAN-0012, 0016 | 2026-11-02 |
| PLAN-0014 | 2026-11-03 |
| PLAN-0035 (`.pyc` fora do git; `ginga` main limpa) | 2026-11-03 |

## Backlog (INTENTs sem PLAN)

- [INTENT-0001 ginga revamp](intents/INTENT-0001-ginga-revamp.md) → SPEC-0001 (approved)
- [INTENT-0004 skill deepen](intents/INTENT-0004-deepen-skill.md)
- [INTENT-0005 handoff e learnings](intents/INTENT-0005-handoff-e-learnings.md) → design [06](knowledge/design/ginga-revamp/06-handoff-e-learnings.md)
- Adicionar "Name origin" ao README do p-inga e do futuro ginga/manda ([DECISION-0001](knowledge/decisions/DECISION-0001-nomes.md))

## Mapa

| Pasta | Conteúdo |
|---|---|
| `intents/` | Pedidos crus |
| `specs/` | Objetivo + ACs |
| `plans/` | `PLAN-*/PLAN.md` + `TASK-*.md` + `log.md` |
| `models/` | Providers, modelos, roteamento e budget |
| `knowledge/design/` | Documentos de design (revamp) |
| `knowledge/decisions/` | ADRs (DECISION-0001 nomes, DECISION-0002 mensageria e fila, DECISION-0003 open source, DECISION-0004 repo g-inga, DECISION-0005 Apache-2.0 e publicação) |
| `knowledge/lessons/` | Lições (vazio; o `LESSONS.md` da raiz ainda é usado pelo pi-harness) |
| `handoffs/` | Handoffs gerados (vazio) |
