# 09 — Observabilidade

Origem: [INTENT-0006](../../../intents/INTENT-0006-sandbox-e-code-mode.md) (palestra Arize) e [DECISION-0003](../../decisions/DECISION-0003-tudo-open-source.md). Complementa [05 — Interface](05-interface.md) (Métricas) e [07 — Eventos](07-eventos.md).

## 1. A palestra da Arize (code mode)

INTENT-0006 cita a palestra "code mode" (Arize/Phoenix, https://www.youtube.com/watch?v=dAoOYFx7ZYw). Medição real deles (18 tasks, 2 rodadas):

| Variante | Reward | Turnos | Prompt tokens |
|---|---|---|---|
| Code mode antigo | 16/18 | 142 | 3,67M |
| Sem code mode | 15/18 | 86 | 2,80M |
| Code mode **após ajustar as instruções** | 16/18 | 101 | 1,56M |

O code mode antigo era **pior** que sem code mode. Só ganhou depois do ciclo eval → traces → ajuste. Resultado final: **−43% de tokens, −31% de custo, reward igual, latência +0,6%**.

Avaliação: **task** = instrução + ambiente + testes. Cada trial roda em **sandbox nova**, e o verifier roda os testes, com reward de 0 a 1 e k trials. Baselines: Claude Code com MCP (uma tool por chamada), Claude Code com CLI + skill, e um **Oracle** (solução de referência).

Problemas em aberto: durabilidade (snapshot); determinismo (Starlark × JS); binários e imagens; **modelos pequenos falham no code mode**. Complexidade operacional: custo de startup (isolate em ms, microVM em centenas de ms, VM cheia em segundos), debug mais difícil, tool discovery, **duplicar o harness** (MCP com tool search e code exec por cima de um harness que já tem os dois). Riscos do código gerado por LLM: limites de CPU/memória/tempo; saída de rede (README injetado exfiltrando dados); segredos dentro da sandbox (`print(env)`); permissões amplas demais. PXI: `bash` + `execute` + `executeSql`, sobre GraphQL/REST/banco; "code mode no browser": o agente escreve um script `ui.*` que roda num Web Worker e dirige a app real.

Conclusão para nós: code mode vale para o **orquestrador** com muitas tools; não para o executor barato. Medir no bench antes de adotar (PLAN-0016).

## 2. O que o Phoenix faz

Phoenix (https://github.com/arize-ai/phoenix) mostra traces de projetos (ex.: `claude-code`) com spans, tokens, custo e turnos. É candidato a backend de observabilidade do harness. Não verificado além disso (INTENT-0006 marca "Não verificado").

## 3. Por que ele é opcional (DECISION-0003)

Licença **Elastic License 2.0**, não aprovada pela OSI. Nossos repos são MIT (DECISION-0003). Nenhum pacote nosso depende ou embute o Phoenix.

A interface é **OTLP** (OpenTelemetry) com as convenções semânticas **OpenInference** (ambas abertas; Apache-2.0, a verificar). O **backend padrão é nosso**, MIT: o `ginga serve` recebe `/v1/traces` e o Roda mostra os painéis. **Phoenix, Jaeger e outros entram como destinos opcionais**, configurados com `GINGA_OTLP_ENDPOINT`. Nenhum pacote nosso depende deles, então a regra da OSI continua valendo para o que distribuímos.

Candidatos OSI (licença a verificar no repo de cada um antes de adotar): Jaeger, Grafana Tempo, Opik (Comet), Laminar, Langfuse (core; a pasta `ee/` tem licença comercial).

## 4. Teste já feito

Ponte ad hoc `bridge.py` (scratchpad, não versionada) converte linhas de `log.md` dos PLANs 0004/0005/0007 em spans OTLP e envia para o Phoenix local. Resultado: **97 spans**, projeto `duh-homelab-ondas-1-2`. O Phoenix só aceita **protobuf** (OTLP/HTTP); JSON não funciona. Atributos usados: `openinference.span.kind` (CHAIN/AGENT), `llm.model_name`, `llm.provider`, `ginga.plan`, `ginga.task`, `ginga.attempt`, `ginga.passed`, `output.value`.

Lição: a ponte é descartável; o alvo real é emitir OTLP direto dos eventos v1 (07) no `ginga serve`, sem passar pelo Phoenix.

## 5. Plano de teste do Phoenix como destino opcional

Ligado ao **PLAN-0014** (métricas/quota/A/B) e à **H6 do PLAN-0016** (traces no nosso receptor vs. Phoenix, que ficou para depois do PLAN-0014 porque o receptor ainda não existe).

Passos:

1. Implementar o receptor OTLP no `ginga serve` (`/v1/traces`) e o painel no Roda (PLAN-0014/0012) — backend padrão.
2. Configurar `GINGA_OTLP_ENDPOINT=http://localhost:6006/v1/traces` (Phoenix) e rodar o mesmo conjunto de eventos; comparar número de spans, atributos e latência com o backend padrão.
3. Verificar que nenhum pacote nosso importa o Phoenix; só a URL de destino muda.
4. Critério de sucesso: paridade de spans (mesmo `v` do evento) e ausência de dependência de runtime. Se falhar, o Phoenix fica só como destino opcional documentado, sem integração no código.

## 6. Métricas desejadas

Tokens, turnos, custo e FTPR por papel e por modelo, a partir dos eventos `attempt`/`receipt`/`handoff`/`learning` (07) e do `state.db` (PLAN-0010):

| Métrica | Fonte | Pergunta |
|---|---|---|
| Tokens de entrada/saída por TASK | `attempt.tokens_in/out` | Onde o contexto vai? |
| Turnos por TASK | `attempt` (contagem) | O modelo está gastando muitos turnos? |
| Custo por TASK/PLAN/SPEC | `attempt.cost_usd` agregado pelas relações do frontmatter | Onde o dinheiro vai? |
| FTPR por papel e por modelo | receipts + `attempt.passed` (scoreboard do pinga maestro) | O modelo barato está dando conta? |
| Falhas por motivo | `attempt.failure` (`done_when`, `quota_exhausted`, `timeout`, `infra`, `judge`) | Por que falham? |
| Quota por provider | evento `quota` (Codex rollout, Claude statusline; AGY/OpenCode Go manuais) | O gargalo é quota? |
| Erros repetidos | `learning` com status + `touch` | O sistema aprende? (06 §6) |
| Handoffs | evento `handoff` (gatilho, tokens, economia estimada) | Quando compensa cortar? |

"Quota esgotada" e "infra" não contam contra o modelo no FTPR, mas entram na taxa de falha (05 §3.6). Quota é estado, não arquivo (ROUTING princ. 4).

## 7. Operacional: detecção e ação (SPEC-0003)

**Traces/Phoenix são a visualização; o vigia é a detecção.** Os spans OTLP/OpenInference (§1–§5) mostram o que aconteceu; o vigia (determinístico, sem LLM) decide se algo está errado e age.

- Sinais novos: `heartbeat`, `cost`, `judge.verdict`, `sandbox.*`, `gate.fail` (e `alert` como saída do vigia), com correlação `trace_id`/`span_id` (PLAN → TASK → attempt → chamada de ferramenta). Catálogo e campos: [SPEC-0003](../../../specs/SPEC-0003-observabilidade-operacional.md#catálogo-de-sinais-eventos-v1-novos).
- Regras: arquivo `.ginga/watch/rules.toml`, uma por incidente real (infra travada, contrato contraditório, modelo com 0/x, estouro de custo, judge sem regressão, 429, falso positivo de gate, violação de sandbox). Cada regra tem sinal, condição, janela, ação, severidade e fixture. Detalhe: [SPEC-0003](../../../specs/SPEC-0003-observabilidade-operacional.md#regras-do-vigia-gingawatchrulestoml).
- Ações: integração com a rota de falhas do manda (breaker, desbloqueio, skip de degrau, remoção de modelo da escada), Discord **só no crítico** (com dedupe e resumo) e painéis da Roda (Inbox/Quadro/Métricas).
- ACs testáveis (replay de log, dedupe, etc.): [SPEC-0003](../../../specs/SPEC-0003-observabilidade-operacional.md#acs-testáveis).

Status: `draft`. Implementação nos PLAN-0004, 0008, 0010, 0012 e 0014 (emendas em SPEC-0003).
path: .ginga/knowledge/design/ginga-revamp/09-observabilidade.md