---
type: plan
title: Manda-CARU — routing, escalada, budget e Judge cego
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: done
repos: [manda, p-inga, duh-homelab]
depends_on: [PLAN-0007-manda-nucleo, PLAN-0005-pinga-task-e-plan]
done_when: "cd manda && bun test && cd ../p-inga && bun test tests/judge_external.test.ts"
---
## Objetivo

O manda escolhe o modelo pelo `tier` e pelo [ROUTING](../../models/ROUTING.md), escala sozinho `free → medium → strong`, para nos tetos de budget, roda o Verifier Judge cego de outra família e sabe gerar um PLAN (`manda plan`) para o fluxo sem ginga.

## Abordagem

- O ROUTING hoje é prosa e tabelas. A TASK-01 adiciona um frontmatter legível por máquina (`ladder`, `pools`, `budget`) sem mudar o texto; os `PROVIDER-*.md` já têm `runtimes`, `family`, `billing`.
- Precedência: `project.toml [runtimes]` > ROUTING > padrões embutidos. Papel fixado no projeto ignora a escada.
- Escalada e breaker seguem o ROUTING: `free×2 → medium×2 → strong×1`; breaker com 3 falhas seguidas do mesmo `reason_code` (sem contar `quota_exhausted`/`infra`). OK do dono só ao passar do teto ou quando o próximo candidato é o claude.
- Judge: roda no manda (bundle cego num diretório temporário: SPEC/PLAN, diff, receipts, `metrics.json`) e é selado pelo pinga. Hoje o `pinga judge` chama ele mesmo um endpoint OpenAI-compatível (`judge.ts:270-372`); a TASK-05 adiciona `--verdict <arquivo>` para selar um veredito externo com `assertDistinctFamily`.
- **Execução:** TASKs como `tasks/T<N>/PLAN.md` em manda/p-inga; a TASK-01 é do workspace (sem pinga, como o PLAN-0002).

## TASKs

1. [TASK-01](TASK-01-pi-fail-closed.md): pi.ts fail-closed (sem provider/modelo padrão)
2. [TASK-02](TASK-02-routing-legivel.md): frontmatter máquina no ROUTING.md (workspace)
3. [TASK-03](TASK-03-routing-manda.md): `manda route` com precedência
4. [TASK-04](TASK-04-escalada-breaker.md): escada de tiers + breaker
5. [TASK-05](TASK-05-budget.md): tetos TASK/PLAN/mês + OK do dono
6. [TASK-06](TASK-06-pinga-judge-externo.md): `pinga judge --verdict` (p-inga)
7. [TASK-07](TASK-07-judge-cego.md): Judge cego de outra família
8. [TASK-08](TASK-08-manda-plan.md): `manda plan <INTENT|SPEC>` (papel Planner)

## ACs da SPEC cobertos

- O manda escolhe o modelo pelo `tier` e pelo ROUTING, escala, respeita os tetos e pede OK só ao passar do teto ou ao cair no claude; `project.toml [runtimes]` tem precedência.
- O Verifier Judge é cego e de família diferente do executor e do Planner.

## Riscos

- Onde o manda guarda o gasto quando roda sem ginga: proposta `.ginga/state/manda-spend.jsonl` (append de `cost_usd`); com ginga, o `state.db` passa a ser a fonte. Divergência possível entre os dois.
- `modelFamily` existe em duas versões (`p-inga/src/family.ts:45` e `pi-harness/.pi/extensions/router.ts:332`); o manda precisa de uma terceira, com o mesmo resultado (teste de paridade).
- A família "mista" do OpenCode Go/Zen é por modelo: a escolha do judge depende de classificar cada modelo.

## Emenda (INTENT-0008): desbloqueio automático

> Resumo do [INTENT-0008](../../intents/INTENT-0008-resolver-dependencias.md). Quando uma TASK depende de algo, o harness cria a TASK que resolve, em vez de parar no operador.

O executor já escreve `BLOCKED: <motivo>`. O passo novo é **classificar** o motivo (regra simples ou modelo free) e, para cada classe conhecida, gerar uma **TASK de desbloqueio** com `depends_on` invertido (a TASK original passa a depender dela) e rodar de novo.

**Classes de `BLOCKED:` e a TASK de desbloqueio correspondente:**

| Classe | O que é | TASK de desbloqueio |
|---|---|---|
| `contract_conflict` | teste antigo contradiz o contrato novo | TASK do **Planner** alinha os testes (não pode ser o executor) |
| `id_collision` | `pinga_task` repetido entre PLANs | renumerar de forma **determinística, sem LLM** |
| `gate_false_positive` | pre-commit barra por falso positivo (ex.: AC-SEC) | fix de 1 linha dentro do `touch` + novo selo |
| `env_dependency` | teste dependente da máquina (lê `~/.hermes`, estado real) | TASK isola com HOME falso, ou o perfil da sandbox declara o mount/fixture (`needs:`) |
| `missing_dep` | dependência ausente | TASK que provê a dependência |
| `other` | qualquer outro motivo | **vai para o humano** (não é automatizado) |

**Limites:**

- no máximo **1 desbloqueio automático por TASK** e **2 por PLAN**;
- `other` e qualquer mudança de abordagem continuam indo para o humano (decisão 8 do revamp);
- o desbloqueio nunca pode afrouxar `tests_frozen` que não são dele.

**Prevenção no Planner** (antes de despachar): rodar todos os testes do `done_when` contra o contrato e checar a unicidade do `pinga_task` no ledger.

**Onde encaixa:** na rota de falhas do manda (routing, escalada e judge) — como emenda ou TASK nova deste PLAN. Os perfis de sandbox com `needs:` ficam no INTENT-0006.

**Princípio relacionado (dono, 2026-10-28):** nenhum padrão implícito de ferramenta ou provider. O manda resolve runtime/provider/modelo pela config do projeto (`[runtimes]` no `.ginga/project.toml` + `models/ROUTING.md`), passa `--provider/--model` explicitamente e falha (fail-closed) sem rota. O `opencode-go` é proibido (é a primeira TASK da onda 3).
