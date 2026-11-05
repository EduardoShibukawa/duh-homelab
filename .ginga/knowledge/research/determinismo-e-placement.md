# Avaliação: determinismo × Jev × LLM e placement de tooling

Escopo: read-only sobre o inventário real (`.ginga/bin/*`, `.ginga/prompts/*`, `models/ROUTING.md`, intents 0006/0008/0009/0010, specs 0001/0002/0003, design 02/07/08/10, research `skills-e-hooks.md` e `sessao-2026-10-27/analise.md`, PLAN-0008/0016, `manda/src`, `p-inga/src`, hooks do host). Fonte Jev: https://opencode.ai/docs/zen/. Onde não souber: "a verificar".

## 1. Taxonomia em 3 faixas

| Faixa | Critério | Exemplos | Onde mora (típico) |
|---|---|---|---|
| **Determinístico** (script/código/gate) | resultado verificável, repetível, erro inaceitável | validar frontmatter, teto de custo, merge, detectar travado | script/CLI, código de pacote, hook do host, config |
| **Classificação estruturada (Jev)** | decisão fechada sobre texto livre, probabilidade importa, custo ~0 | classe de `BLOCKED:`, novo×regressão, severidade de alerta | chamada Jev + código que consome o valor/probabilidade |
| **Generativo (LLM)** | escrever código, testes, planos, pesquisa, revisão aberta | teste RED, julgar diff, replan | prompt de papel + runtime |

**Regra de ouro:** o LLM nunca decide o que pode ser verificado; o Jev decide classes; o script verifica. (Jev é "System One" da TypeSafe AI: não gera texto, avalia um `state` contra perguntas tipadas `noul`/`choice`/`score` e devolve valor + probabilidade, várias em paralelo; endpoint `https://opencode.ai/inference/systemone/v1/systemone`; Free grátis por tempo limitado; pago US$0,042/1M entrada, saída grátis.)

## 2. Tabela de operações do harness (inventário real)

| Operação | Faixa | Por quê | Onde mora | Pacote dono | PLAN/INTENT |
|---|---|---|---|---|---|
| Validar frontmatter SPEC/PLAN/TASK | D | campos/tipos/relações verificáveis | skill `pinga` + script/CLI `ginga lint` | ginga/pinga | SPEC-0002 / PLAN-0004 |
| Unicidade de `pinga_task` no ledger | D | consulta determinística ao SQLite | código p-inga (`ledger`) + script | p-inga | INTENT-0008 / PLAN-0008 |
| Escolher modelo por tier | D | tabela de routing, sem julgamento | config ROUTING + código manda `route` | manda | PLAN-0008 |
| Escalada `free→medium→strong` | D | regra fixa de tentativas | código manda | manda | PLAN-0008 |
| Breaker (3 falhas mesmo `reason_code`) | D | contagem determinística | código manda/p-inga | manda | PLAN-0008 |
| Triagem de trilha (task vs feature) | D+G | critérios determinísticos + LLM só no desempate | código ginga + prompt | ginga | SPEC-0001 |
| Triagem de tier (light/standard/heavy) | J | classificação de texto livre, custo ~0 | Jev + código manda | manda | PLAN-0008 (novo) |
| Classificar motivo de `BLOCKED:` | J | 6 classes fechadas, prob. importa | Jev + código manda (rota de falhas) | manda | INTENT-0008 |
| Gerar TASK de desbloqueio | D (id_collision/env) / G (contract_conflict) | regra por classe; Planner para conflito | código manda + prompt Planner | manda | INTENT-0008 |
| Detectar cliente travado (heartbeat) | D | regra `alive && cpu<1 && Δt>N` | código ginga + `watch/rules.toml` | ginga | SPEC-0003 |
| Teto de custo (pré-chamada) | D | medição antes da chamada (bug atual mede depois) | hook host + código manda | manda/ginga | PLAN-0008 / SPEC-0002 |
| Medir tokens/custo | D | contagem/medição | script (`tokens.sh`/`pi-run.sh`) + código manda | manda | PLAN-0014 |
| Decidir se alerta vai ao Discord | D | severidade + dedupe por regra | código ginga + `rules.toml` | ginga | SPEC-0003 |
| Severidade de alerta | J (tipos novos) / D (regra) | classe fechada; prob. para texto livre | Jev + código ginga | ginga | SPEC-0003 (novo) |
| Merge | D | só após receipt `pass` + judge `pass` | script git + ação `merge_and_followup` | manda | SPEC-0003 / PLAN-0008 |
| Gerar `situacao-vs-visao` | D | regeneração a partir do estado, não à mão | script/CLI ginga | ginga | SPEC-0003 (processo) |
| Escrever teste RED | G | criação de código/teste | prompt `planner-red` + p-inga `prove-red` | p-inga | PLAN-0005/0008 |
| `prove-red` (baseline falha) | D | execução do gate | código p-inga | p-inga | (existente) |
| `verify` (`done_when`) | D | execução em sandbox | código p-inga + `sandbox-done-when.sh` | p-inga | PLAN-0018 |
| Julgar diff (Verifier Judge) | G (veredito) + D (selo) | julgamento aberto, selado por família distinta | prompt `judge` + código p-inga `judge` | p-inga | PLAN-0008 |
| Novo × regressão no judge | J | classificação de achados entre rodadas | Jev + código manda (`judge.verdict`) | manda | SPEC-0003 / PLAN-0008 |
| Classificar falha de sandbox | D | vocabulário de `failure.ts` | código manda `failure.ts` | manda | (existente) |
| Classificar falha de execução (quota/infra/timeout) | D | regex em log | código manda `classifyRunnerFailure` | manda | (existente) |
| Escolher skills de uma TASK | D | perfil declarativo por papel | config `project.toml` + código ginga `install` | ginga | SPEC-0002 |
| Resumo de handoff | D | geração sem LLM a partir de arquivos/git | código ginga `handoff` | ginga | PLAN-0013 |
| Emitir eventos v1 | D | append JSONL, fato não comando | código de todos os pacotes | pinga/manda/ginga | SPEC-0001 / PLAN-0004 |
| Hook `bashRefusal` (git add -A, --no-verify, push force) | D | bloqueio determinístico fora da sandbox | hook do host (ginga) | ginga | SPEC-0002 |
| Payload guard (write >100 linhas) | D | limite verificável | código p-inga `hooks.ts` | p-inga | (existente) |
| Redigir segredos em eventos | D | padrão/redaction | código p-inga `redact.ts` | p-inga | (existente) |
| Instalar/projetar skills e hooks por runtime | D | geração idempotente da fonte única | código ginga `install/init` | ginga | PLAN-0006/0015 + SPEC-0002 |
| `gate.fail` → desbloqueio automático | D | classificação + ação por regra | código ginga (vigia) + manda | ginga/manda | SPEC-0003 |
| `sandbox.violation` → TASK de isolamento | D | regra `inside_only==true` | código ginga (vigia) | ginga | SPEC-0003 |
| `quota_exhausted` → pular degrau | D | 429 por modelo/janela | código manda + vigia | manda | SPEC-0003 |
| `model_low_pass_rate` → remover da escada | D | taxa < limiar em N tentativas | código manda + vigia | manda | SPEC-0003 |
| `judge_no_regression` → merge + follow-up | D | `round>2 && regression==0` | código manda | manda | SPEC-0003 |

## 3. Onde vive cada tipo de tooling

- **Skill:** pasta `SKILL.md` + `scripts/` (+ references/assets), progressive disclosure; scripts TS/bun fazem o determinístico; entra na sandbox como mount read-only. Usar quando um papel/TASK precisa de conhecimento reutilizável + ação verificável (ex.: `pinga`, `red-audit`, `gira-context`).
- **Hook do host:** código fora da sandbox que observa/bloqueia tools antes/depois. Usar para enforcement que o modelo não contorna (teto de custo, `tests_frozen` ro-bind, `bashRefusal`, provider proibido).
- **Script/CLI:** executável determinístico, imprime JSON no stdout. Usar para operação verificável/repetível (validar, medir, migrar).
- **Código de pacote:** lógica do harness (manda/pinga/g-inga) — estado, roteamento, ledger, vigia. Usar quando há estado cross-run ou porta de integração.
- **Prompt de papel:** instrução para o LLM gerar artefato. Usar para escrita/criação/revisão aberta (teste RED, julgamento, planos).
- **Config de projeto:** `project.toml` / `ROUTING.md`. Usar para escolhas por projeto/ambiente (runtimes, tetos, perfis de sandbox).

```mermaid
flowchart LR
  E[Evento] --> H[Hook/vigia (determinístico)]
  H -->|classe incerta| J[Jev (classifica)]
  J -->|precisa escrever/criar| L[LLM (só se precisar)]
  L --> S[Script verifica]
  H --> S
  J --> S
```

## 4. Onde o Jev entra primeiro

Aplicações de maior retorno (todas são classificação fechada; probabilidade importa):

1. **Classificar motivo de `BLOCKED:`** (6 classes) — INTENT-0008. Elimina as 4 intervenções manuais da onda 1–2 (contrato, id, gate, env).
2. **Novo × regressão no judge** (`judge.verdict`) — SPEC-0003. Evita rodadas infinitas de fix.
3. **Severidade de alerta + rota Discord** — SPEC-0003. Reduz ruído; hoje tudo é lido à mão.
4. **Triagem de tier (light/standard/heavy)** — PLAN-0008. Barato e frequente.
5. (candidato, a verificar) **Classificar falha de sandbox desconhecida** (env_dependency vs infra vs other).

**Experimento (para cada aplicação):** rótulos manuais extraídos dos `log.md` reais e das tabelas de INTENT-0008/0010 e SPEC-0003 (fixtures de watch). Rodar Jev com perguntas tipadas em paralelo, medir acurácia vs rótulo e calibração (probabilidade média dos acertos vs erros), custo por 1k classificações. **Meta: ≥ 90% de acurácia**; abaixo de 80%, manter regex/regra ou LLM. Custo estimado < US$0,01 por 1k (a verificar).

**Riscos:** probabilidade mal calibrada (confiança alta em erro) → exigir threshold (ex.: ≥0,85) e fallback para regra/LLM quando abaixo; Free "por tempo limitado" → não depender em produção sem plano pago; dados enviados (state + texto) → não enviar segredos/handoff, mascarar e enviar só o necessário; latência/endpoint único (a verificar).

## 5. O que hoje está na faixa errada nesta sessão

- Operador LLM (Claude) fazendo merge e lendo log à mão → deveria ser script/vigia (D) + Jev (classificação) + LLM só no resíduo (INTENT-0010).
- Teto de custo medido **depois** da chamada (`dispatch-task.sh`) → D pré-chamada (SPEC-0002/PLAN-0008).
- Claude escrevendo testes RED, TASKs e prompts de judge direto, gastando quota Pro → G via Pi/executor barato; Claude só passada RED curta (design/08 §5; analise §1.6).
- `~/.pi` default `opencode-go` (proibido) → D config fail-closed (INTENT-0008).
- Judge trazendo itens novos a cada rodada → J (novo×regressão) + regra `judge_no_regression` (SPEC-0003).
- nemotron 0/42 sem remoção automática → D regra `model_low_pass_rate` (SPEC-0003).
- Classificação de `BLOCKED:` à mão (6 tentativas idênticas) → J + desbloqueio (INTENT-0008).
- Geração manual de `situacao-vs-visao` → D regeneração (SPEC-0003).
- Enforcement de papéis só em doc, violado → hook do host (SPEC-0002).

## Fontes

`.ginga/models/ROUTING.md`; intents 0006/0008/0009/0010; specs 0001/0002/0003; design 02/07/08/10; research `skills-e-hooks.md`, `sessao-2026-10-27/analise.md`; PLAN-0008, PLAN-0016; `.ginga/bin/*`; `manda/src/runtime/*`; `p-inga/src/hooks.ts`, `redact.ts`; `~/.claude/settings.json` (hooks listados); https://opencode.ai/docs/zen/.