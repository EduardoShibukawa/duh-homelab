---
type: research
title: Modelos free para executor e operador (OpenRouter e outros providers)
date: 2026-10-29
status: 2ª rodada (OpenRouter validado com a chave do dono, US$ 10 comprados); falta chave para Mistral/Gemini
---
# Modelos free: o que há, o que valida, o que precisa do dono

Resumo em 5 linhas:

1. **Validados hoje, sem conta nova:** 4 modelos NVIDIA pelo Pi (`nemotron-3.5-lightning-30b-a3b`, `nemotron-3.5-super-vl-120b-a12b`, `meta/muse-glimmer-30b`, `nemotron-3-nano-omni-30b-a3b-reasoning`). Dois deles (`muse-glimmer`, `lightning`) também rodam no `opencode run`, o que `minimax` e `mistral-large` não fazem.
2. **`minimax-m3.1-flash` regrediu:** o probe "ok" responde em 2 s, mas a TASK devolve `429` duas vezes seguidas. Sai do topo da escada.
3. **ATUALIZAÇÃO (chave ligada, ver seção "OpenRouter validado" abaixo): só `recursive/flint-v1.0:free` fechou 3/3 e passa em `data_collection: deny`; `cohere/north-mini-code:free` também passa em deny mas falhou 2 de 3.** Poolside, NVIDIA e Liquid no OpenRouter são endpoints "Free model training" (a própria OpenRouter recusa com `deny`). Texto original deste item:
   OpenRouter `:free` funciona no opencode e no Pi, com 15 modelos com tool calling hoje. O limite é de 20 req/min e 50 req/dia (1000/dia com US$ 10 comprados), **global**: criar mais contas não ajuda. O gargalo é a **privacidade**, que a doc não esclarece (ver abaixo). Por isso, só executor em repo MIT.
4. **Fora do que já temos:** Mistral (Experiment) é o único com cota folgada (~1B tokens/mês), mas a doc oficial avisa que treina com os dados. Groq tem teto de 8K tokens/min, que não cabe num agente. Cerebras e GitHub Models **acabaram** (ver abaixo). Cloudflare dá 10 mil neurons/dia (pouco). Gemini: limites só no AI Studio logado, e o free treina.
5. **Precisa do dono:** conta e chave do OpenRouter (e, se quiser 1000/dia, US$ 10 de crédito). Passo a passo na seção "Para o dono".

## Tabela

Legenda de "Treina?": **sim** = a doc do provider diz que usa os dados; **não declarado** = a doc que li não diz (tratar como sim para operador); **não** = a doc diz que não.

| Provider | Modelo | Tool calling | Limite | Treina? | Precisa do dono | Testado (2026-10-29) |
|---|---|---|---|---|---|---|
| NVIDIA build (Pi) | `meta/muse-glimmer-30b` | sim | ~40 RPM/conta | já aprovado (NVIDIA) | não | ✅ Pi: probe 3 s, TASK soma 25 s, TASK RED 50 s. ✅ opencode: probe 9 s, TASK soma 30 s |
| NVIDIA build (Pi) | `nvidia/nemotron-3.5-lightning-30b-a3b` | sim (3B ativos) | idem | idem | não | ✅ Pi: probe 2 s, soma 8 s, RED 20 s. ✅ opencode: soma 8 s |
| NVIDIA build (Pi) | `mistralai/mistral-large-4-1t-a52b` | sim | idem | idem | não | ✅ Pi: soma 64 s, RED 30 s (id custom no Pi) |
| NVIDIA build (Pi) | `nvidia/nemotron-3.5-super-vl-120b-a12b` | sim | idem | idem | não | ⚠️ Pi: soma 14 s; RED corrigiu o código mas o processo **não terminou** (timeout 300 s) |
| NVIDIA build (Pi) | `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning` | sim | idem | idem | não | ❌ Pi: soma 21 s ok; **RED falhou** (190 s, 3 falhas) |
| NVIDIA build (Pi) | `minimaxai/minimax-m3.1-flash` | sim (API direta devolveu 429 num burst) | idem | idem | não | ❌ regrediu: probe ok, mas TASK soma dá `429` (2×) |
| NVIDIA build (Pi) | `poolside/laguna-xs-2.1` | sim | idem | idem | não | ⚠️ probe 82 s; soma resolvida mas `ResourceExhausted: Worker local total request limit (45/32)` (rc=1); API direta deu 503. Instável |
| NVIDIA build | `z-ai/glm-5.3-flash`, `deepseek-ai/deepseek-v4.1-flash` | catalogados | idem | idem | não | ❌ fila: timeout em 90 s (probe Pi e API direta), de novo |
| NVIDIA build | `stepfun-ai/step-5-preview` | sim | idem | idem | não | ✅ API direta com tool call em 27 s (TASK completa validada ontem: 106 s) |
| NVIDIA build | `kimi-k2.6`, `nemotron-3-super-120b`, `nemotron-nano-3-30b` | — | — | — | — | 404; `z-ai/glm-5.3` dá 410 Gone. Indisponíveis |
| OpenRouter | `poolside/laguna-s-2.1:free` (118B, 8B ativos, coding agent; ctx 262K) | sim (`tool_choice` só `auto`) | 20 RPM; 1000/dia (confirmado na conta do dono) | **sim**: bloqueado por `data_collection: deny` ("Free model training") | feito | ❌ 429 do pool do upstream (Poolside) em soma e RED; probe ok em 9 s |
| OpenRouter | `poolside/laguna-xs-2.1:free` (ctx 262K) | sim | idem | **sim** (bloqueado por deny) | feito | ❌ 429 do pool do upstream |
| OpenRouter | `cohere/north-mini-code:free` (30B, 3B ativos, agente de código; ctx 256K) | sim | idem | **passa em deny** | feito | ⚠️ soma ok (8 s); RED 1 de 3 (2× `finish_reason: error`/falha, 1× ok em 33 s). Instável |
| OpenRouter | `recursive/flint-v1.0:free` (40B, 2,5B ativos; ctx 262K) | sim | idem | **passa em deny** (provider Recursive) | feito | ✅ probe 2 s, soma 4 s, RED 3 de 3 (17 a 19 s). O melhor do OpenRouter |
| OpenRouter | `thinkingmachines/inkling:free` (975B, 41B ativos; ctx 1M) e `inkling-small:free` | sim | idem | indeterminado (API direta dá 403 "only available on agentic harnesses") | feito | ✅ pelo Pi: soma 10 s, RED 13 s. Só funciona via harness (Pi); o teste de deny não rodou |
| OpenRouter | `nvidia/nemotron-3-ultra-550b-a55b:free`, `nemotron-3.5-super-vl:free`, `nemotron-3.5-lightning:free`, `nemotron-3-nano-omni:free` | sim | idem | **sim** (bloqueados por deny) | feito | ultra: ❌ "Service temporarily overloaded". Os outros não testados; já rodam na NVIDIA |
| OpenRouter | `google/gemma-4-31b-it:free`, `gemma-4-26b-a4b-it:free` (Google AI Studio por trás) | sim | idem | Google free: sim (ver Gemini) | idem | não testado |
| OpenRouter | `xingchen-agi/xing4.0-29b-a4b:free`, `dots-studio/dots-3-note-preview:free`, `liquid/lfm-2.5-2.6b:free` | sim | idem | dots-3 e xing4 passam em deny; liquid não | feito | dots-3 ❌ `400 bad request` (AtlasCloud); xing4 ⚠️ soma funcionou mas `rc=1`; liquid 2,6B: não serve |
| OpenRouter | `openrouter/free` (router) | filtra por tool calling se a request tem `tools` | idem | herda do modelo sorteado | idem | não testado; sorteia o modelo → não reproduzível, **não usar em lane** |
| Mistral (Experiment) | Codestral / Mistral Small / (Devstral, "grátis por período" no lançamento) | sim | ~1 req/s, 500K tokens/min, ~1B tokens/mês (fonte de terceiros; o real está no console) | **sim**: a ajuda oficial avisa que o plano Experiment pode treinar | conta + telefone verificado (sem cartão) | não testado |
| Google AI Studio | Gemini Flash / Flash-Lite, Gemma 4 | sim | só no AI Studio logado; por projeto | **sim** ("provide, improve, and develop" produtos e ML, termos "unpaid services") | conta Google + chave | não testado |
| Groq | `openai/gpt-oss-120b`, `qwen/qwen3.8-27b` | sim | tabela do Developer: 30 RPM, 1K req/dia, **8K tokens/min**, 200K tokens/dia; o free não aparece separado | não declarado | conta + chave | não testado; 8K TPM não comporta um prompt de agente |
| Cerebras | `gpt-oss-120b`, `qwen-3.8-27b` | sim | trial de US$ 5 por 30 dias, 5 RPM, 1M tokens/dia | não declarado | **cartão/forma de pagamento verificada** | **fora**: sem free recorrente (doc oficial) |
| GitHub Models | — | — | — | — | — | **fora**: serviço encerrado em 30/07/2026 (fonte de terceiros) |
| Cloudflare Workers AI | Qwen3.8-27B etc. (função de chamada em parte do catálogo) | parcial | 10 mil neurons/dia compartilhados, zera 00:00 UTC; acima, só no plano pago | não declarado | conta | não testado; cota pequena demais para executor |

## OpenRouter em detalhe

**Limites** (fonte oficial, lida hoje): `:free` tem 20 req/min; 50 req/dia com menos de US$ 10 comprados em toda a conta, 1000 req/dia com ao menos US$ 10 (o limiar real é um crédito abaixo disso). Os limites são governados **globalmente**: "criar mais contas ou chaves não afeta" o limite. A doc não diz se request com erro conta. `GET /api/v1/key` mostra o contador diário (`free_model_daily_requests`).

Uma TASK de executor faz de 10 a 60 requests (cada passo de tool é uma). Com 50/dia, **uma ou duas TASKs por dia**; com 1000/dia, ~20 a 40. Sem o crédito, o OpenRouter não sustenta uma lane.

**Lista `:free` ao vivo** (`GET https://openrouter.ai/api/v1/models`, sem chave, 456 modelos, 16 `:free` + o router): ver tabela. 15 anunciam `tools`; só o `nemotron-3.5-content-safety` não. Todos com uptime 100% nos últimos 30 min, exceto os do Google AI Studio (sem medição).

**Privacidade (lacuna):** nenhuma página oficial que li diz se os endpoints `:free` registram ou treinam. O que a doc diz:

- O OpenRouter em si não guarda prompt nem resposta por padrão.
- `provider.data_collection: "deny"` (por request ou em Privacy settings da conta) restringe a provedores que **não coletam** dados; o padrão `allow` admite quem guarda e pode treinar.
- Cada página de modelo mostra uma tag "Data Policy", que a própria doc diz não ser definitiva.

Não consegui ler a tag (as páginas de modelo só mostram sem login). **Premissa segura:** tratar todo `:free` como "pode treinar", logo **só executor em repo MIT**, nunca operador, handoff ou dado do dono. Se o dono ligar `data_collection: deny`, o OpenRouter pode devolver "no endpoints" para a maioria dos `:free`; isso, por si, já mostra quais não coletam. Teste a fazer com a chave.

**Tool calling:** a lista anuncia suporte e o `openrouter/free` filtra por capacidade quando a request traz `tools`. Há relato de terceiros de `No endpoints found that support tool use` em `:free`. Só o teste com chave confirma, modelo por modelo.

**opencode** (doc oficial): o provider `openrouter` já vem no catálogo. Conectar com `/connect` (ou `opencode auth login`) e a chave; modelos fora do catálogo vão em `opencode.json`:

```json
{ "$schema": "https://opencode.ai/config.json",
  "provider": { "openrouter": { "models": {
    "poolside/laguna-s-2.1:free": {},
    "cohere/north-mini-code:free": {},
    "recursive/flint-v1.0:free": {} } } } }
```

Uso: `opencode run --standalone -m openrouter/poolside/laguna-s-2.1:free "..." < /dev/null`. Para fixar o upstream: `options.provider.order` e `allow_fallbacks: false`.

**Pi** (doc local `docs/providers.md`): OpenRouter é provider nativo; basta `OPENROUTER_API_KEY` (ou `/login openrouter`), e o Pi lista só os modelos que a chave pode usar. Uso: `pi -p --model openrouter/poolside/laguna-s-2.1:free "..." < /dev/null`. Não precisa de `models.json`. Para o `lane.sh` isso vira `pi:openrouter/poolside/laguna-s-2.1:free`.

## Outros providers: como ligar

(Só Groq, Cerebras e Cloudflare têm seção na doc de providers do opencode; Mistral e Google **não**, e o nome da variável do Google no opencode é de memória, não verificada. O Pi tem as variáveis na doc local. Confirmo com `opencode models` quando houver chave.)

| Provider | opencode | Pi | Observação |
|---|---|---|---|
| Mistral | `/connect` → Mistral (pelo catálogo do opencode; a doc de providers não lista seção própria) | nativo: `MISTRAL_API_KEY` | `pi --model mistral/codestral-latest`. Treina no plano Experiment |
| Google AI Studio | provider `google` (o catálogo do opencode usa `GOOGLE_GENERATIVE_AI_API_KEY`; a doc lista só Vertex) | nativo: `GEMINI_API_KEY` | Free treina; pago não |
| Groq | `/connect` → Groq (seção própria na doc) | nativo: `GROQ_API_KEY` | TPM de 8K inviabiliza |
| Cerebras | `/connect` → Cerebras (seção na doc) | nativo: `CEREBRAS_API_KEY` | exige pagamento verificado |
| Cloudflare Workers AI | `/connect` → Cloudflare Workers AI (`CLOUDFLARE_ACCOUNT_ID` + `CLOUDFLARE_API_KEY`) | custom em `models.json` (`openai-completions`) | cota de 10 mil neurons/dia |

## O que mudou no NVIDIA (o que já está ligado)

Catálogo ao vivo hoje: 85 modelos. Probe direto com tool call em todos os candidatos de código: ver tabela. Notas:

- **Mais rápidos e estáveis hoje:** `nemotron-3.5-lightning-30b-a3b` (8 a 20 s) e `muse-glimmer-30b` (25 a 50 s); ambos rodam também pelo `opencode run` (`-m nvidia/nvidia/nemotron-3.5-lightning-30b-a3b`, `-m nvidia/meta/muse-glimmer-30b`). Atenção: o lightning tem 3B ativos; as duas TASKs foram pequenas. **A qualidade em TASK maior não foi medida.**
- **Fila:** `glm-5.3-flash` e `deepseek-v4.1-flash` seguem sem resposta. Deixar fora até aparecerem.
- O 429 do minimax apareceu na API direta (rajada de 8 probes) e **de novo sozinho**, numa 2ª tentativa isolada minutos depois, então não é só a minha rajada: pode ser fila do modelo ou o limite de ~40 RPM por conta (compartilhado com qualquer lane rodando). Não distingui os dois. Os outros testes rodaram em até 3 de cada vez.
- Os testes usam duas TASKs: (1) criar `soma.py` + `test_soma.py` e rodar; (2) corrigir `textutil.py` (dois bugs) sem alterar o teste. O resultado vem de rodar `python3 -m unittest` e conferir o `md5` do teste, não do relato do modelo.

## Escada recomendada

**Executor** (código de repo MIT; failover pelo primeiro token ~60 s, como no PLAN da lacuna 2):

1. `opencode-go/iceman-contributor-free` (treina; só repo MIT)
2. `pi:nvidia/mistralai/mistral-large-4-1t-a52b` (30 a 64 s, o mais forte dos testados)
3. `pi:nvidia/meta/muse-glimmer-30b` (novo)
4. `pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b` (novo; rápido, mas pequeno)
5. `pi:nvidia/stepfun-ai/step-5-preview` (106 s)
6. `opencode/glm-5.3-flash-free` (quando o Zen voltar)
7. (depois da chave do dono) `pi:openrouter/poolside/laguna-s-2.1:free`, `cohere/north-mini-code:free`

Fora: `minimax-m3.1-flash` (429 agora), `nemotron-3-nano-omni` (falhou na TASK RED), `nemotron-3.5-super-vl-120b` (não encerra o processo; só entra com `timeout` duro), `laguna-xs-2.1` na NVIDIA (instável).

**Operador** (vê dados do workspace; só modelo sem treino e já aprovado):

1. `pi:nvidia/mistralai/mistral-large-4-1t-a52b`
2. `pi:nvidia/meta/muse-glimmer-30b`
3. `pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b`
4. `opencode/glm-5.3-flash-free`

Nenhum OpenRouter `:free`, Mistral Experiment ou Gemini free para operador. Operador em OpenRouter só com `data_collection: deny` **e** teste mostrando que o modelo ainda responde.

## Proposta de diff para `handoffs/lane.env` (NÃO aplicado; aguarda OK do dono)

```diff
-OP_MODELS=opencode-go/iceman-contributor-free,pi:nvidia/minimax-m3.1-flash,pi:nvidia/mistralai/mistral-large-4-1t-a52b,opencode/glm-5.3-flash-free
+OP_MODELS=pi:nvidia/mistralai/mistral-large-4-1t-a52b,pi:nvidia/meta/muse-glimmer-30b,pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b,opencode/glm-5.3-flash-free
-EXEC_MODELS=opencode-go/iceman-contributor-free,pi:nvidia/mistralai/mistral-large-4-1t-a52b,pi:nvidia/minimax-m3.1-flash,pi:nvidia/stepfun-ai/step-5-preview,opencode/glm-5.3-flash-free
+EXEC_MODELS=opencode-go/iceman-contributor-free,pi:nvidia/mistralai/mistral-large-4-1t-a52b,pi:nvidia/meta/muse-glimmer-30b,pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b,pi:nvidia/stepfun-ai/step-5-preview,opencode/glm-5.3-flash-free
```

Observação: a lista atual do `OP_MODELS` tem o `iceman` em 1º lugar, o que contraria a regra de nunca usar modelo que treina como operador. A proposta o remove.

## Para o dono (nada disto foi feito por mim)

1. **OpenRouter:** crie conta em https://openrouter.ai, gere chave em https://openrouter.ai/settings/keys. Sem crédito, vale 50 req/dia (inútil para lane). Para 1000/dia, compre **US$ 10 de crédito, uma vez** (o limiar é "comprado em toda a vida", não saldo; os `:free` não gastam esse crédito). Em Settings → Privacy, deixe desligado "OpenRouter Use of Inputs/Outputs". Traga a chave; eu ligo no opencode e no Pi e testo os 6 modelos de código.
2. **Mistral (opcional):** conta + telefone verificado, sem cartão. Aceita treinar com os dados. Só executor em repo MIT. É a maior cota gratuita (~1B tokens/mês) e tem Codestral.
3. **Gemini (opcional):** chave no AI Studio. O free treina; sem vantagem sobre o que temos, exceto o judge (que já usa o `agy`).
4. **Não vale o passo:** Groq (8K TPM), Cerebras (cartão), GitHub Models (encerrado), Cloudflare (10 mil neurons/dia).

Decisão de dono: aprovar ou não o diff do `lane.env`; mandar dados a OpenRouter/Mistral (executor MIT apenas).

## Fontes

- OpenRouter, limites: https://openrouter.ai/docs/api-reference/limits
- OpenRouter, router free: https://openrouter.ai/docs/guides/routing/routers/free-router
- OpenRouter, `data_collection`: https://openrouter.ai/docs/guides/routing/provider-selection
- OpenRouter, privacidade: https://openrouter.ai/docs/guides/privacy/data-collection e https://openrouter.ai/docs/faq
- OpenRouter, catálogo ao vivo: https://openrouter.ai/api/v1/models e `/api/v1/models/<id>/endpoints`
- opencode, providers: https://opencode.ai/docs/providers/
- Pi, providers: `~/.local/share/mise/installs/pi/latest/pi/docs/providers.md` e `models-configuration.md`
- Groq, limites: https://console.groq.com/docs/rate-limits
- Cerebras, limites: https://inference-docs.cerebras.ai/support/rate-limits
- Cloudflare Workers AI, preço: https://developers.cloudflare.com/workers-ai/platform/pricing/
- Google Gemini, limites: https://ai.google.dev/gemini-api/docs/rate-limits; termos: https://ai.google.dev/gemini-api/terms
- Mistral, plano Experiment (terceiros e busca; a página oficial de ajuda deu 404 para mim): https://mintlify.com/cheahjs/free-llm-api-resources/providers/free/mistral-plateforme, https://freellm.net/providers/mistral-ai
- GitHub Models encerrado (terceiro, **não verificado em fonte primária**): https://klymentiev.com/blog/github-models-shutdown
- Lista de recursos free: o repositório `cheahjs/free-llm-api-resources` devolveu 404 no raw e na API do GitHub hoje; usei os espelhos em https://www.mintlify.com/cheahjs/free-llm-api-resources e as páginas oficiais acima.
- NVIDIA, catálogo: `GET https://integrate.api.nvidia.com/v1/models` (85 modelos, 2026-10-29)

## OpenRouter validado (2026-10-29, chave do dono ligada pelo `/login` do Pi)

**Conta (via `GET /api/v1/key`, sem imprimir a chave):** `is_free_tier: false`, **1000 req/dia** (confirmado), crédito total US$ 10, **uso US$ 0,00** depois de todos os testes. Os `:free` não gastaram nada. O contador diário marcou 64 após ~90 requisições minhas (incluídos 429 de upstream e uma rodada de `allow`/`deny` em todos os modelos), então requisições com erro parecem **contar** (não confirmado, a doc é omissa). Restam ~936.

**Privacidade, resolvida pelo teste (o que a doc não dizia):** com `provider.data_collection: "deny"` a OpenRouter responde `404 No endpoints found matching your data policy (Free model training)` para `poolside/laguna-s-2.1` e `-xs-2.1`, `nvidia/nemotron-3-ultra`, `nemotron-3.5-super-vl`, `nemotron-3.5-lightning`, `nemotron-3-nano-omni` e `liquid/lfm-2.5-2.6b`. Esses são, pelo critério da própria OpenRouter, endpoints que coletam/treinam. Passam em `deny`: `recursive/flint-v1.0`, `cohere/north-mini-code`, `dots-studio/dots-3-note-preview`, `xingchen-agi/xing4.0-29b-a4b` (a resposta veio sem nome de provider). A tag é o critério da OpenRouter, "não é fonte definitiva" sobre o upstream (doc), mas é o melhor sinal disponível.

**Execução com TASK de código** (mesmas duas TASKs; Pi; teste conferido por `unittest` + `md5`):

| Modelo | deny | probe | soma | RED (3 rodadas) | Veredito |
|---|---|---|---|---|---|
| `recursive/flint-v1.0:free` | passa | 2 s | ✅ 4 s | ✅✅✅ 17 a 19 s | **entra** como executor free |
| `cohere/north-mini-code:free` | passa | 2 s | ✅ 8 s | ❌ ✅ ❌ (falha, 33 s ok, falha) | reserva; instável |
| `thinkingmachines/inkling:free` | indeterminado | 3 s | ✅ 10 s | ✅ 13 s (1 rodada) | funciona só via harness; privacidade não confirmada → só repo MIT |
| `poolside/laguna-s-2.1:free`, `laguna-xs-2.1:free` | **treina** | 9 a 16 s | ❌ 429 upstream | ❌ 429 upstream | pool compartilhado do Poolside saturado; só repo MIT, e instável |
| `nvidia/nemotron-3-ultra-550b-a55b:free` | **treina** | ❌ overloaded | — | ❌ | fora |
| `dots-studio/dots-3-note-preview:free` | passa | ❌ 400 | — | ❌ | fora |
| `xingchen-agi/xing4.0-29b-a4b:free` | passa | 6 s | ⚠️ ok mas `rc=1` | — | não confiável |

**Dois cuidados práticos:**

- O `pi -p --model openrouter/...` **não envia** `data_collection: deny`: ele só aparece nas minhas chamadas diretas à API. Pelo Pi, a proteção real hoje depende do ajuste de conta em OpenRouter → Settings → Privacy (o que a mensagem de erro chama de "Free model training"). **Peço ao dono para conferir esse ajuste:** se estiver ligado, requests com `allow` chegam a endpoints que treinam, como os Poolside e NVIDIA que responderam acima. Alternativa por modelo: `samplingParams` no `models.json` do Pi (mescla campos no corpo da requisição); proposta abaixo, não aplicada.
- O limite upstream (429 do Poolside, "overloaded" da NVIDIA) é do provider original, não o seu. Falha desse tipo cai na rotação do `lane.sh`.

**Escada de executor, atualizada** (só repo MIT, exceto onde disser): depois de `iceman` e `mistral-large` (NVIDIA), `muse-glimmer`, `lightning`, `step-5`: acrescentar `pi:openrouter/recursive/flint-v1.0:free` (passa em deny; 17 a 19 s) e, como reserva, `pi:openrouter/cohere/north-mini-code:free`. Para **operador**: nenhum OpenRouter, nem o `flint` (a privacidade do upstream vem só da tag da OpenRouter; para dados do workspace, não basta).

**Diff proposto (não aplicado), `handoffs/lane.env`:** acrescentar ao fim de `EXEC_MODELS`, antes de `opencode/glm-5.3-flash-free`: `,pi:openrouter/recursive/flint-v1.0:free,pi:openrouter/cohere/north-mini-code:free`.

**Proposta de `~/.pi/agent/models.json` para forçar deny (não aplicada; precisa do OK do dono):**

```json
{ "providers": { "openrouter": { "modelOverrides": {
  "recursive/flint-v1.0:free": { "samplingParams": { "provider": { "data_collection": "deny" } } },
  "cohere/north-mini-code:free": { "samplingParams": { "provider": { "data_collection": "deny" } } } } } } }
```

Ainda não testei se o Pi aceita um objeto aninhado em `samplingParams`; teste antes de aplicar.

### Complemento: página de coleção `:free` e router `openrouter/free` (2026-10-29)

- **Fonte primária para a privacidade (https://openrouter.ai/collections/free-models):** a página traz 16 modelos free e só 3 têm aviso de treino, todos com a frase do próprio fornecedor. Poolside: "If you are using Laguna S 2.1 [ou XS 2.1] for free, we may use your inputs and outputs to train and improve our models." Liquid: "Prompts and outputs may be retained and used to train Liquid models." Isso confirma por texto o que o `deny` mostrou para Poolside e Liquid. Os modelos NVIDIA não têm aviso na página, mas o `deny` os recusa; vale o teste, não o silêncio da página.
- **Fora da lista dos 16:** `gemma-4-31b/26b:free` não aparecem na coleção, embora estejam em `/api/v1/models` (e deram 429 de upstream). Há também `respan/span-01-lite:free` (modelo de avaliação, não de código) e `nemotron-3.5-content-safety` (guardrail).
- **`openrouter/free` (router):** a página do router não lista pool, seleção nem política de dados. Teste (12 requests, com `tools`): ele sempre devolveu tool call. Em `allow` sorteou `nemotron-3.5-lightning`, `flint`, `north-mini-code`, `dots-3`, `nemotron-3-nano-omni` e `liquid-2.6b` (um a cada request: 6 modelos diferentes em 6 chamadas). Em `deny` só sorteou `flint`, `north-mini-code` e `dots-3`, coerente com a lista que passa no `deny`. **Conclusão:** o router é inadequado para lane (modelo muda a cada passo de tool, inclusive um 2,6B), mas `openrouter/free` com `data_collection: deny` é um pool aceitável de não-treino. Preferir o `flint` fixo.

### Resultado final pelo Pi e escada aplicada (2026-10-29 ~22:00)

- `openrouter/openrouter/free` (router) pelo Pi: probe 3 s, soma 28 s, correção 2/2 (43 e 51 s). Funciona; o modelo é sorteado a cada passo. Entra como **último** fallback do executor.
- O Pi com a chave do OpenRouter lista os mesmos 16 `:free` (o resto é pago). A lista do router (26) inclui embeddings, áudio e rerank; os de chat são os mesmos 16.
- Outros pelo Pi: `inkling-small` ✅ (soma 5 s, correção 146 s); `nemotron-3.5-super-vl:free` ✅ (5 s e 10 s); `nemotron-3.5-lightning:free` ✅ (32 s e 142 s, mais lento que direto na NVIDIA); `laguna-s-2.1` ⚠️ (probe 429; correção ok em 81 s, `rc=1`); `gemma-4-31b/26b` ❌ 429 do Google; `nemotron-3-ultra:free` ❌; `xing4.0` ❌; `dots-3` ❌ 400.
- **Aplicado pelo dono em `handoffs/lane.env`** (backup `lane.env.bak-2026-10-29-pesquisa-free`; `.free-esgotado` removido):
  - `OP_MODELS`: `mistral-large` → `muse-glimmer-30b` → `nemotron-3.5-lightning-30b-a3b` → `opencode/glm-5.3-flash-free`. Sem `iceman`, `minimax` ou OpenRouter.
  - `EXEC_MODELS`: `iceman` → `mistral-large` → `muse-glimmer` → `lightning` → `step-5` → `openrouter/flint:free` → `openrouter/north-mini-code:free` → `glm-5.3-flash-free` → `openrouter/openrouter/free`.
- Pendente: o dono confirmar OpenRouter → Settings → Privacy → "Free model training" desligado (o Pi não envia `data_collection: deny`).

## Hermes / Nous Portal (2026-10-29 ~22:20)

- O Hermes é só cliente (como Pi e opencode). Perfil `pinga`: `opencode-zen` / `deepseek-v4.1-flash` (Zen pago), sem fallback (`hermes fallback list` vazio), credenciais só de `opencode-zen` e `opencode-go`. Perfil global (`~/.hermes`): servidor local (Qwen2.5 3B), `nous` (OAuth do dono), `copilot`, `openai-codex`.
- A conta **`nous` é free-tier** (`check_nous_free_tier` = True). O Portal recomenda 6 modelos free: `upstage/solar-mini4:free`, `poolside/laguna-xs-2.1:free`, `poolside/laguna-s-2.1:free` (esses dois treinam, ver OpenRouter), `stepfun/step-3.7-flash:free`, `reflection/beam-1.0-501b-a23b:free`, `ornith/ornith-1.5-122b:free`.
- **Probe** `hermes -z "responda só: ok" --provider nous -m <modelo>` (stdin fechado): `step-3.7-flash` ✅ 8 s, `beam-1.0-501b` ✅ 13 s, `ornith-1.5-122b` ✅ 9 s, `solar-mini4` ✅ 5 s, `laguna-s-2.1` ✅ 8 s.
- **TASK de código não foi rodada:** o teste usava `hermes --yolo` (aprova ações sem perguntar) e foi bloqueado pelo classificador de permissões. Falta validar tool calling real nesses três.
- Política de dados do Nous Portal: **não verificada**. Mandar dados do workspace a um terceiro novo é decisão do dono; não entram no operador sem isso.
- `models.dev` (cache do Hermes) lista 4 `-free` do OpenCode Go (`cat-jam`, `step-5-preview`, `longcat-2.5-preview`, `minimax-m3.1-flash`) que o opencode recusa ("Model unavailable"). Cache desatualizado, ignorar.

### Decisão do dono: privacidade do OpenRouter (2026-10-29 ~22:40)

- Em OpenRouter → Settings → Privacy os botões "Allow free endpoints that train on request data" e "Allow free endpoints that publish prompts" estão **ligados**, e o dono **decidiu mantê-los** (o workspace vai ser open source). Teste sem `deny`: `laguna-s-2.1` e `nemotron-3.5-lightning` (`:free`) respondem.
- Consequência: o `openrouter/free` (último da escada) pode cair em endpoints que treinam e **publicam prompts**. OpenRouter só no executor, nunca no operador.
- Risco restante: segredo no prompt (`cat .env`, `auth.json`, `env`). Mitigação em curso: guard de hook nas lanes (sessão `28f440af`; TASK pelo harness).

### Operador liberado para OpenRouter (2026-10-29 ~22:50)

- O dono liberou o operador para providers que treinam (workspace open source; segredos continuam proibidos). Aplicado em `handoffs/lane.env` pelo dono (backup `lane.env.bak-2026-10-29-op-openrouter`): `OP_MODELS` ganhou `pi:openrouter/recursive/flint-v1.0:free` e `pi:openrouter/cohere/north-mini-code:free` no fim, depois de NVIDIA e `glm-5.3-flash-free`. `openrouter/free` não entrou no operador (sorteia o modelo a cada passo).
- Lanes já rodando mantêm o ambiente antigo até o próximo relançamento do vigia.
