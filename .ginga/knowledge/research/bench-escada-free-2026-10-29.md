---
type: research
title: Benchmark de qualidade da escada free (3 TASKs de tamanho real)
date: 2026-10-29
status: completo (2 rodadas); flint sem a rodada 2 por falha do upstream; diff proposto, NÃO aplicado
---
# Benchmark da escada free: qualidade em TASK maior

Complementa `modelos-free-2026-10-29.md`, que só tinha TASKs minúsculas (`soma.py`, 2 bugs em `textutil.py`).

## Resumo em 6 linhas

1. **Mais confiáveis: `mistral-large` e `lightning` (6/6 cada)**, mas lentos (mediana de 250 s e 274 s por execução; `lightning` chegou a 572 s na rodada 2, perto do `timeout 600`).
2. **Mais rápido e bom: `iceman` (5/6, mediana 50 s).** Falhou uma vez: a refatoração deixou `process_orders` com 29 linhas (limite 25) e respondeu "feito" sem conferir.
3. **`flint` foi 3/3 em 32 a 49 s, mas só tem 1 rodada válida por TASK:** a rodada 2 (e 4 retentativas) deu `503 no upstreams available` do provider Recursive. Dado insuficiente, não falha do modelo.
4. **Fora da escada:** `step-5-preview` trava em 600 s **6 de 6** vezes, sem nenhuma linha de saída (na TASK C o código ficou certo, mas o processo nunca encerra). `north-mini-code` morre com `Provider finish_reason: error` no meio da escrita em A e B nas 4 tentativas e só passa a TASK C (a menor).
5. **`muse-glimmer`:** 2/2 em B e C, mas **trava 600 s sem saída na TASK A nas duas rodadas** (a classe de ~70 linhas a partir de 21 testes).
6. **`openrouter/free`** (router): 4/6, as duas falhas são `Response was truncated: output token limit`. Continua só como último fallback.

## Método

- **3 TASKs sintéticas em Python** (nada do workspace), cada uma em `mktemp -d` novo, com `timeout -k 10 600`, `< /dev/null`; fixtures e scripts em `probes/bench-escada/` (`tasks/`, `ref/` = solução de referência que prova que o teste é satisfazível, `run.sh`, `check.sh`, `lane.sh`, `results.tsv`).
  - **A, classe a partir de testes:** `LRUCache` com TTL e relógio injetável, em arquivo novo `lru.py`; 21 testes (recência, TTL por item, expiração, `purge`, estatísticas, validação). Base: RED (import error).
  - **B, bug em 2 módulos:** `invoice.py` trata a alíquota de `rates.py` (percentual: 18.0 = 18%) como fração, e `money.to_cents` trunca (`19.99 → 1998`) em vez de arredondar meio-para-cima. É preciso ler os três; mexer em `rates.py` é proibido (md5). 13 testes, 6 passam na base.
  - **C, refatorar + caso novo:** `process_orders` (~55 linhas) deve ficar com nenhuma função > 25 linhas e ≥ 3 auxiliares (conferido por AST), mantendo 16 testes verdes, e implementar o cupom `FRETEGRATIS` (1 teste novo, fornecido, falhando na base).
- **Passou** = `unittest` OK **e** `md5` dos `test_*.py` (e `rates.py` na B) intacto **e**, na C, estrutura OK pela AST. O relato do modelo não conta.
- 2 rodadas por modelo × TASK (24 execuções por rodada), 2 processos em paralelo: **lane NVIDIA** e **lane OpenRouter + iceman** (os 40 RPM da NVIDIA e os 20 req/min do OpenRouter nunca foram divididos). Sem 429 em sequência de verdade; as 2 pausas de 300 s do NVIDIA/OpenRouter vieram de (a) falso positivo do meu contador na rodada 1 e (b) os 503 do Recursive na rodada 2.
- OpenRouter: contador `free_model_daily_requests` em 133/1000 antes e **233/1000 depois** (~100 requests, incluindo as retentativas do flint), checado a cada execução (limite de parada: < 300 restantes; nunca chegou perto). Chave nunca impressa.
- **Erro de provider** = 503/429/overloaded/`finish_reason: error` no log. **Travou** = `rc=124` (timeout). O restante é erro do modelo.

## Resultado por modelo × TASK

Células: `passou/rodadas válidas` e **mediana do tempo das 2 rodadas** (timeout conta 600 s). `h2` = travou nas 2; `+Np` = N rodadas descartadas por erro de provider. Total = passou/válidas.

| Modelo | A (LRU) | B (2 módulos) | C (refatorar) | Total | Mediana geral | Falhas |
|---|---|---|---|---|---|---|
| `pi:nvidia/mistralai/mistral-large-4-1t-a52b` | 2/2 · 409 s | 2/2 · 168 s | 2/2 · 228 s | **6/6** | 250 s | nenhuma |
| `pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b` | 2/2 · 448 s | 2/2 · 370 s | 2/2 · 88 s | **6/6** | 274 s | nenhuma (572 s no pior caso) |
| `opencode-go/iceman-contributor-free` | 2/2 · 50 s | 2/2 · 68 s | 1/2 · 34 s | 5/6 | **50 s** | modelo: C r2, 29 linhas na função |
| `pi:openrouter/recursive/flint-v1.0:free` | 1/1 · 49 s (+1p) | 1/1 · 38 s (+1p) | 1/1 · 32 s (+1p) | 3/3 | 32 s | provider: 503 do Recursive ×3 (e ×4 em retentativas) |
| `pi:nvidia/meta/muse-glimmer-30b` | **0/2 h2** · 600 s | 2/2 · 138 s | 2/2 · 126 s | 4/6 | 178 s | travou 2× na A (0 bytes de saída) |
| `pi:openrouter/openrouter/free` | 1/2 · 50 s | 2/2 · 40 s | 1/2 · 53 s | 4/6 | 43 s | modelo: truncou por limite de saída ×2 (sorteia o modelo) |
| `pi:openrouter/cohere/north-mini-code:free` | 0/0 (+2p) | 0/0 (+2p) | 2/2 · 17 s | 2/2 válidas, **2/6 contando provider** | 16 s | provider: `finish_reason: error` no meio da escrita ×4, reproduzível; A e B ficam com `lru.py`/código pela metade |
| `pi:nvidia/stepfun-ai/step-5-preview` | 0/2 h2 | 0/2 h2 (10/13 e 6/13 testes) | 2/2* h2 | **0/6** (*) | 600 s | travou 6×; na C o código estava certo mas o processo não encerra |

(*) `step-5` na C: `unittest` verde e md5 intacto, mas `rc=124`. Numa lane isso custa 10 min e o executor nunca "termina"; contei como falha operacional.

Falhas de provider **separadas das de modelo**: só o `flint` (503 do upstream Recursive) e o `north-mini` (`finish_reason: error` reproduzível). **Nenhum 429 da NVIDIA** nas 48 execuções; os travamentos NVIDIA (`muse` A, `step-5`) saíram com 0 bytes, então não dá para dizer se é o modelo, a fila ou o stream; os dois travam sempre nas TASKs em que a resposta exige escrever um arquivo grande.

## Ranking

**Executor** (qualidade em TASK real, depois tempo):

1. `iceman`: 5/6 e 50 s. Melhor custo-benefício; **treina** (hoje liberado pelo dono, ver `workspace-vai-ser-opensource`).
2. `mistral-large`: 6/6, mas 3 a 7 min por TASK.
3. `flint`: 3/3 em 32 a 49 s; entra acima do `lightning` pelo tempo, mas **sem a rodada 2** e com upstream caído hoje (cai em 16 s para o próximo, custo baixo).
4. `lightning`: 6/6, lento e variável (88 a 572 s).
5. `muse-glimmer`: 4/6; o travamento de 600 s na A custa 10 min antes do failover por primeiro token ainda atuar (sem saída nenhuma).
6. `opencode/glm-5.3-flash-free`: **não medido aqui**; fica onde está.
7. `openrouter/free`: 4/6; modelo muda a cada passo; só como último.
8. Retirar: `north-mini-code` (provider quebra a escrita de arquivos maiores) e `step-5-preview` (0/6 operacional).

**Operador** (só NVIDIA, sem modelo que treina, por instrução desta avaliação): `mistral-large` > `lightning` > `muse-glimmer`; `glm-5.3-flash-free` mantém o fim. Troca em relação ao hoje: `lightning` sobe acima do `muse` (6/6 contra 4/6).

## Proposta de diff para `handoffs/lane.env` (NÃO aplicado; decisão do dono)

```diff
-OP_MODELS=pi:nvidia/mistralai/mistral-large-4-1t-a52b,pi:nvidia/meta/muse-glimmer-30b,pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b,opencode/glm-5.3-flash-free
+OP_MODELS=pi:nvidia/mistralai/mistral-large-4-1t-a52b,pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b,pi:nvidia/meta/muse-glimmer-30b,opencode/glm-5.3-flash-free
-EXEC_MODELS=opencode-go/iceman-contributor-free,pi:nvidia/mistralai/mistral-large-4-1t-a52b,pi:nvidia/meta/muse-glimmer-30b,pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b,pi:nvidia/stepfun-ai/step-5-preview,pi:openrouter/recursive/flint-v1.0:free,pi:openrouter/cohere/north-mini-code:free,opencode/glm-5.3-flash-free,pi:openrouter/openrouter/free
+EXEC_MODELS=opencode-go/iceman-contributor-free,pi:nvidia/mistralai/mistral-large-4-1t-a52b,pi:openrouter/recursive/flint-v1.0:free,pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b,pi:nvidia/meta/muse-glimmer-30b,opencode/glm-5.3-flash-free,pi:openrouter/openrouter/free
```

Mudanças: `lightning` antes do `muse` nas duas listas; `flint` sobe para 3º no executor; saem `step-5-preview` e `north-mini-code` do executor.

**Decisão separada do dono (não incluída no diff):** a memória `workspace-vai-ser-opensource` diz que o operador **já pode** usar provider que treina. Se o dono quiser operador rápido, `iceman` (5/6, 50 s) ou `flint` (3/3, 32 s) seriam candidatos a operador; o benchmark não mediu TASK de operador (`pinga verify`, git), só a qualidade de código. Por isso mantive a restrição que esta avaliação pediu.

## O que a amostra pequena NÃO prova

- **N = 2 por célula.** 6/6 não é "confiável a 100%": um intervalo de 95% para 6 acertos em 6 vai de ~60% a 100%. A diferença entre `mistral-large`/`lightning` (6/6) e `iceman` (5/6) é uma única execução e não separa os três. O que o dado sustenta é só o grosso: `step-5` e `north-mini` são ruins; `muse` trava na TASK A; `iceman`/`mistral-large`/`lightning`/`flint` funcionam.
- **`flint` tem 3 execuções válidas** em 3 TASKs, nenhuma repetida. A posição 3 é aposta, não medição.
- **3 TASKs sintéticas em Python**, enunciado e teste prontos. Não medem TASKs em Bun/TS/Go, repos grandes, leitura de contexto do workspace, `pinga verify` nem commit; nem operação de operador.
- **Tempo depende da hora e da carga.** As lanes reais do dono rodavam em paralelo (o `lightning` foi de 323 s para 572 s na A entre rodadas; o `mistral-large` variou menos, exceto na C: 130 s e 327 s). A mediana não é latência estável.
- **Travamento ≠ modelo ruim:** `muse` e `step-5` saíram com 0 bytes; pode ser fila ou stream da NVIDIA naquele momento. A TASK A pede uma resposta com um arquivo grande, e os dois travaram exatamente aí.
- **`openrouter/free` sorteia o modelo** a cada passo: o 4/6 é uma mistura, não de um modelo.
- **Quem trava** não foi testado com o failover de primeiro token (~60 s) que a lane usa; com ele, `muse`/`step-5` podem custar menos do que 600 s. Medi o executor "puro".
- A C mede obediência ao limite de 25 linhas, que o `iceman` quebrou uma vez; é um critério do meu enunciado, não de correção do código.
