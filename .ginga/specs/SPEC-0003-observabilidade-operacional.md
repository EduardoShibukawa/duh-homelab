---
type: spec
title: Observabilidade operacional, para o harness ver os próprios erros
intent: INTENT-0010-observabilidade-operacional
status: draft
bench: none
---

## Objetivo

Dar ao harness a capacidade de **detectar os próprios erros** sem operador humano. Hoje o operador (Claude) encontra travamentos, contradições, regressões e estouros de custo lendo logs à mão. Esta SPEC define os **sinais** (eventos v1 novos), a **correlação** entre eles, o **mapeamento** para OTLP/OpenInference, as **regras determinísticas** do vigia (arquivo versionado, testáveis com fixtures) e as **ações** que elas disparam (rota de falhas do manda, Discord só no crítico, painéis da Roda).

Traces/Phoenix são a **visualização**; o **vigia** é a **detecção**. Detalhe de visualização em [09-observabilidade.md](../knowledge/design/ginga-revamp/09-observabilidade.md); schema de eventos em [07-eventos.md](../knowledge/design/ginga-revamp/07-eventos.md).

Princípios: regras **sem LLM**; uma regra por linha da tabela de evidências do INTENT-0010; cada regra **testável** com fixture de eventos; ações via verbos (eventos são fatos, nunca comandos).

## Catálogo de sinais (eventos v1 novos)

Propostos (status: proposto, a selar no PLAN-0004). Adicionam-se aos tipos existentes de [07](../knowledge/design/ginga-revamp/07-eventos.md) sem alterá-los.

| kind | Emissor | `data` |
|---|---|---|
| `heartbeat` | manda / executor / ginga | `runtime`, `pid`, `cpu_pct`, `alive` (bool), `last_event_at` (ISO), `attempt_n` (opt) |
| `cost` | manda / ginga | `runtime`, `provider`, `model`, `amount_usd`, `tokens_in`, `tokens_out`, `cost_source` (`estimated`/`reported`), `scope` (`call`/`task`/`plan`/`month`) |
| `judge.verdict` | manda | `verdict` (`pass`/`fail`/`blocked`), `round`, `new`, `regression`, `model`, `family`, `follow_up` (bool) |
| `sandbox.run` | manda / ginga | `profile`, `exit`, `duration_ms`, `net` (`none`/`allowlist`/`host-debug`), `runtime` |
| `sandbox.violation` | manda / ginga | `path`, `access` (`read`/`write`/`exec`/`network`), `inside_only` (bool), `profile`, `runtime` |
| `gate.fail` | pinga / manda | `gate` (`pre-commit`/`verify`/`lint`/`tests_frozen`), `classification` (`id_collision`/`gate_false_positive`/`contract_conflict`/`env_dependency`/`missing_dep`/`other`), `reason`, `file`, `task` |
| `alert` | ginga (vigia) | `rule_id`, `severity` (`info`/`warn`/`high`/`critical`), `entity` (`plan`/`task`/`attempt`), `summary`, `dedupe_key`, `actions` (lista) |

### Correlação `trace_id` / `span_id`

Proposta de adição **opcional** ao envelope (a validar no PLAN-0004, sem quebrar `v:1`): `trace_id`, `span_id`, `parent_span_id`. Campos desconhecidos são ignorados por quem lê.

- `trace_id`: identifica a **run** do PLAN (ULID gerado no início do despacho). Estável para todos os eventos daquela run.
- `span_id`: identifica a entidade emissora (TASK, attempt, chamada de ferramenta).
- `parent_span_id`: aninha attempt → TASK → PLAN e chamada de ferramenta → attempt.

Hierarquia: `PLAN (root span)` → `TASK` → `attempt` → `tool call`. `heartbeat` e `cost` carregam o `span_id` do attempt a que se referem; `judge.verdict` o do PLAN; `sandbox.*` o do TASK/attempt; `gate.fail` o da TASK.

## Mapeamento para OTLP / OpenInference

O `ginga serve /v1/traces` recebe spans OTLP (protobuf) com convenções OpenInference. Cada evento v1 vira um span (ou atributo de span) conforme abaixo. Backend padrão: `ginga serve` + Roda; destinos opcionais via `GINGA_OTLP_ENDPOINT` (Phoenix, Jaeger…). Nenhum pacote depende do backend.

| Campo do evento | Atributo OTLP / OpenInference | Notas |
|---|---|---|
| `trace_id` | `trace.id` | raiz da run |
| `span_id` | `span.id` | entidade |
| `parent_span_id` | `parent.id` | aninhamento |
| `ts` | `timestamp` | ISO-8601 |
| `source` | `ginga.source` | `pinga`/`manda`/`ginga`/… |
| `kind` | `ginga.kind` | tipo do evento |
| `repo`/`intent`/`spec`/`plan`/`task` | `ginga.repo`, `ginga.intent`, `ginga.spec`, `ginga.plan`, `ginga.task` | agregação por SPEC/PLAN/TASK |
| `attempt.runtime`/`provider`/`model` | `llm.provider`, `llm.model_name` | convenção OpenInference |
| `attempt.tokens_in`/`tokens_out` | `llm.token_count.prompt` / `completion` | — |
| `attempt.cost_usd` / `cost.amount_usd` | `llm.cost.total` (ou `ginga.cost_usd`) | — |
| `attempt.passed`/`failure` | `ginga.passed`, `ginga.failure` | — |
| `attempt.duration_ms` | `duration` (span) | — |
| `judge.verdict.verdict` | `ginga.judge.verdict` | — |
| `judge.verdict.new`/`regression` | `ginga.judge.new`, `ginga.judge.regression` | — |
| `sandbox.violation.*` | `ginga.sandbox.violation.*` | — |
| `gate.fail.*` | `ginga.gate.*` | — |
| tipo de span | `openinference.span.kind` | `CHAIN` (PLAN), `AGENT` (TASK/attempt), `TOOL` (chamada de ferramenta), `LLM` (chamada de modelo) |
| payload resumido | `output.value` | truncado, nunca segredo |

Recurso: `service.name = ginga | manda | pinga`, `service.version` da release. Atributos desconhecidos são ignorados pelo receptor.

## Regras do vigia (`.ginga/watch/rules.toml`)

Arquivo versionado, determinístico, **sem LLM**. Uma regra por linha da tabela de evidências do INTENT-0010. O vigia (`ginga tick` / `ginga watch`) avalia cada regra contra a janela de eventos do `state.db`/`$GINGA_EVENTS` e emite `alert` + dispara a ação.

Schema:

```toml
version = 1

[[rule]]
id            = "infra_stuck"          # identificador estável
signal        = "heartbeat"            # kind de evento de entrada
condition     = "alive && cpu_pct < 1 && (now - last_event_at) > window"
window_minutes = 10                    # janela de avaliação
threshold     = 1                      # quantas vezes na janela para disparar
action        = "kill_and_retry"        # verbo/ação (§Ações)
severity      = "critical"             # info | warn | high | critical
discord       = "on_repeat"            # none | on_repeat | always
dedupe_minutes = 60                    # dedupe por (rule_id, entity)
fixture       = "tests/fixtures/watch/infra_stuck.jsonl"
```

Regras (uma por incidente real):

```toml
version = 1

[[rule]]
id = "infra_stuck"
signal = "heartbeat"
condition = "alive == true && cpu_pct < 1 && (now - last_event_at) > window"
window_minutes = 10
threshold = 1
action = "kill_and_retry"
severity = "critical"
discord = "on_repeat"
dedupe_minutes = 60
fixture = "tests/fixtures/watch/infra_stuck.jsonl"

[[rule]]
id = "contract_conflict"
signal = "attempt"
condition = "same reason_code/hash in 2 consecutive failures"
window_minutes = 0
threshold = 2
action = "breaker_unblock"
severity = "high"
discord = "none"
dedupe_minutes = 30
fixture = "tests/fixtures/watch/contract_conflict.jsonl"

[[rule]]
id = "model_low_pass_rate"
signal = "attempt"
condition = "pass_rate(model) < threshold over window"
window_minutes = 60
threshold = 0.10
action = "remove_from_ladder"
severity = "high"
discord = "always"
dedupe_minutes = 120
fixture = "tests/fixtures/watch/model_low_pass_rate.jsonl"

[[rule]]
id = "budget_cap"
signal = "cost"
condition = "spent_usd >= 0.8 * cap_usd (warn) or >= 1.0 * cap_usd (cut)"
window_minutes = 60
threshold = 0.8
action = "alert_and_cut"
severity = "warn"
discord = "on_repeat"
dedupe_minutes = 30
fixture = "tests/fixtures/watch/budget_cap.jsonl"

[[rule]]
id = "judge_no_regression"
signal = "judge.verdict"
condition = "round > 2 && regression == 0"
window_minutes = 0
threshold = 1
action = "merge_and_followup"
severity = "info"
discord = "none"
dedupe_minutes = 0
fixture = "tests/fixtures/watch/judge_no_regression.jsonl"

[[rule]]
id = "quota_exhausted"
signal = "attempt"
condition = "failure == 'quota' for model in window"
window_minutes = 60
threshold = 1
action = "skip_tier"
severity = "medium"
discord = "none"
dedupe_minutes = 60
fixture = "tests/fixtures/watch/quota_exhausted.jsonl"

[[rule]]
id = "gate_false_positive"
signal = "gate.fail"
condition = "classification in {id_collision, gate_false_positive}"
window_minutes = 0
threshold = 1
action = "auto_unblock"
severity = "medium"
discord = "none"
dedupe_minutes = 30
fixture = "tests/fixtures/watch/gate_false_positive.jsonl"

[[rule]]
id = "sandbox_violation"
signal = "sandbox.violation"
condition = "inside_only == true"
window_minutes = 0
threshold = 1
action = "create_isolation_task"
severity = "medium"
discord = "none"
dedupe_minutes = 60
fixture = "tests/fixtures/watch/sandbox_violation.jsonl"
```

Cada regra é testável: `ginga watch --test <fixture.jsonl>` reproduz o evento e verifica o `alert` emitido e a ação invocada (mock do verbo). Regras são só dados: adicionar uma regra não exige mudança de código.

## Ações

- **Rota de falhas do manda (INTENT-0008):** o vigia não implementa a correção; ele **classifica** e chama o verbo certo do manda:
  - `kill_and_retry` → mata o processo (pid do heartbeat) e re-dispacha a TASK (retry; Discord só se repetir).
  - `breaker_unblock` → breaker dispara e gera TASK de desbloqueio (`contract_conflict`), com `depends_on` invertido (INTENT-0008).
  - `remove_from_ladder` → remove o modelo da escada do tier e avisa.
  - `alert_and_cut` → alerta (80%) e corta gasto (100% do teto).
  - `merge_and_followup` → merge + TASK de follow-up (não bloqueia).
  - `skip_tier` → pula de degrau e registra a janela de quota.
  - `auto_unblock` → desbloqueio automático do gate.
  - `create_isolation_task` → cria TASK de isolamento (HOME falso / `needs:` no perfil).
- **Discord:** só severidade `critical` (e `high` se configurado) dispara mensagem, com **dedupe** por `(rule_id, entity)` dentro de `dedupe_minutes` e **resumo** (digest) quando houver vários hits na mesma janela. Demais severidades vão para o log/painel, sem notificação.
- **Painéis da Roda (PLAN-0012/0014):** todos os `alert` aparecem no Inbox/Quadro com filtro por severidade; Métricas mostram contagem por regra, MTTR e custo por alerta; Quota mostra `cost` agregado.

## ACs testáveis

1. Replay do log de eventos de 2026-10-27 com o cliente opencode travado (porta 49374, 0% CPU) dispara `infra_stuck` em ≤ 10 min e emite `alert{rule_id:infra_stuck,severity:critical}`.
2. Duas falhas consecutivas com o mesmo `reason_code`/hash em `attempt` disparam `contract_conflict` e geram uma TASK de desbloqueio (breaker).
3. Modelo com taxa de passagem < 10% em ≥ 20 tentativas sai da escada e gera aviso (Discord).
4. Gasto por hora ≥ 80% do teto emite alerta; ≥ 100% corta o gasto (nenhuma tentativa paga depois do corte na mesma janela).
5. `judge.verdict` com `round > 2` e `regression == 0` resulta em merge + TASK de follow-up, sem bloquear o PLAN.
6. 429 por modelo/janela emite `skip_tier` e registra a janela de quota (sem contar contra o modelo no FTPR).
7. `gate.fail{classification:gate_false_positive}` (AC-SEC) dispara `auto_unblock` sem intervenção humana.
8. `sandbox.violation{inside_only:true}` cria TASK de isolamento.
9. `ginga watch --test <fixture>` passa para cada uma das 8 fixtures, sem LLM, em < 1 s.
10. Dedupe: dois `alert` iguais (mesmo `rule_id,entity`) dentro de `dedupe_minutes` viram um só no Discord.

## Casos de teste (incidentes reais → fixtures)

| Incidente (2026-10-27) | Regra | Fixture |
|---|---|---|
| Cliente opencode travado porta 49374, 0% CPU, 1h30 | `infra_stuck` | `infra_stuck.jsonl` |
| 6 tentativas `BLOCKED:` idêntico (teste contraditório) | `contract_conflict` | `contract_conflict.jsonl` |
| nemotron 0/42 | `model_low_pass_rate` | `model_low_pass_rate.jsonl` |
| US$6,90 num dia com teto US$2 | `budget_cap` | `budget_cap.jsonl` |
| Judge trazendo itens novos a cada rodada | `judge_no_regression` | `judge_no_regression.jsonl` |
| 429 de free esgotado | `quota_exhausted` | `quota_exhausted.jsonl` |
| Colisão de T<N>, falso positivo AC-SEC | `gate_false_positive` | `gate_false_positive.jsonl` |
| Teste lendo `~/.hermes` real | `sandbox_violation` | `sandbox_violation.jsonl` |

## PLANs afetados (emendas sugeridas)

| PLAN | Emenda sugerida |
|---|---|
| **PLAN-0004** (schema eventos) | Estender o schema v1 (`TASK-02`/nova TASK) para aceitar os kinds propostos + `trace_id`/`span_id`/`parent_span_id` opcionais; `ginga events validate` e `migrate` os reconhecem; fixtures de watch versionadas. |
| **PLAN-0008** (manda routing/judge) | TASK nova (após `TASK-07`) para emitir `judge.verdict`, `cost`, `heartbeat`, `sandbox.*`, `gate.fail` e para consumir `alert` na rota de falhas (breaker/unblock/skip/remove). |
| **PLAN-0010** (tick/serve/notifier) | TASK nova para o vigia no `ginga tick` (avaliação das regras, dedupe Discord, digest) e roteamento de `alert` para painéis. |
| **PLAN-0012** (Roda Web) | TASK nova para painéis de alertas (Inbox filtrado por severidade) e visualização de traces (span tree por `trace_id`). |
| **PLAN-0014** (métricas/quota) | TASK nova para métricas derivadas dos novos sinais (contagem por regra, MTTR, custo por alerta, FTPR excluindo `quota`/`infra`) e export OTLP de traces. |

## Fora do escopo

- Implementação do receptor OTLP e dos painéis (cobertos pelos PLANs acima).
- Detecção baseada em LLM (o vigia é determinístico; LLM só no desbloqueio `other` do INTENT-0008).
- Modificação de código nesta SPEC (só documentação).
- Phoenix/Jaeger como dependência de runtime (destinos opcionais, DECISION-0003).
- Auto-remediação além das ações listadas (sem `auto_merge` de código, sem auto-approve).
- Novos runtimes ou mudanças no sandbox (INTENT-0006).
- Regeneração automática do `situacao-vs-visao` (processo, não código; SPEC só define que deve ser regenerado ao fim de cada onda).