---
type: research
title: jev-gateway (vinilana) — usar, adaptar, implementar nosso ou descartar?
date: 2026-10-29
status: 1ª rodada; nada instalado, nada executado, nenhum dado enviado a ninguém. Aguarda decisão do dono
---
# jev-gateway: avaliação para o harness (executor e operador das lanes)

## Recomendação (resumo)

**Descartar o `jev-gateway` como componente do harness, e não construir agora um roteador de tools próprio. Adaptar só a parte barata e já prevista: o Jev como classificador pontual (ROUTING) e uma guarda determinística de `tool_call` no Pi.** Em 5 linhas:

1. **O ganho que o projeto promete não bate com o nosso gargalo.** As lanes falham por `command_failed` (56), `scope_drift` (24), `tests_frozen_changed` (5) e `BLOCKED:` de contrato (~10), em ~171 linhas de falha nos `log.md`. Erro de *escolha de tool* aparece 2 vezes em ~390 logs. O limite dos modelos free é cota (RPM, req/dia, 429, fila), não escolher a tool errada.
2. **Não há evidência de ganho com modelo fraco ou free.** O benchmark do autor (120 sessões, 5 por célula, só modelos fortes) mostra ganho em depuração, piora em feature (Opus 5: +83% de tempo; Luna, o mais fraco: 3/5 contra 5/5 resolvidas). A própria doc do projeto avisa que modelos free não seguiram `tool_choice` forçado.
3. **No Pi e no opencode as tools têm argumento de texto livre** (`bash`, `read`, `edit`, `write`). Então o modo `direct` (resposta sem chamar o LLM) nunca dispara; sobra `forced`, que ainda faz 1 request ao LLM por passo. Nos tiers com teto em *requests* (NVIDIA ~40 RPM, OpenRouter 1000/dia), o gateway não reduz o gasto da cota e, se o upstream recusar o `tool_choice` (400/422), reenvia o original e **gasta 2 requests**.
4. **Dados:** cada passo manda ao provider do Jev o system prompt (até 4000 caracteres), as tools e as últimas voltas da conversa com saídas de tool (arquivos lidos, saída de `bash`), até 60 000 caracteres por chamada. É um terceiro a mais, além do modelo da lane. Para operador, isso é decisão do dono.
5. **A parte aproveitável já existe sem o gateway:** o Pi 1.4.0 traz classificadores Jev nativos (`ctx.modelRegistry.classify()`, `codemode`), inclusive `opencode/jev-1.13-free` e modelos de decisão locais via llama.cpp (`lev`, 4B, Apache-2.0). É o caminho para o item "Classificação estruturada: Jev" do ROUTING, sem processo extra e sem reescrever tráfego.

**O que precisa do dono:** (a) decidir se o Jev pode ver textos de log/`BLOCKED:` do workspace (só para o classificador, texto curto e mascarado) e por qual provider; (b) uma chave do Jev (passo a passo abaixo); (c) OK para o experimento de acurácia (custo estimado < US$ 0,01 por 1 000 classificações, a confirmar). Nada disso é urgente.

## 1. O projeto

- Repositório https://github.com/vinilana/jev-gateway, MIT, TypeScript, v0.5.1 (2026-10-06), último commit 2026-10-22 (`feat: let Jev see the images…`). Autor único (Vinicius Lana), "independente, sem afiliação com a TypeSafe". Clonado em diretório vazio sob `$CLAUDE_JOB_DIR/tmp`; **só li o código** (nada de `npm install`, scripts ou `node`).
- **O que faz:** servidor HTTP local (Hono) que finge ser a API do LLM. Para cada request com `tools`, monta um "estado" (conversa) e pergunta ao Jev: qual tool, se precisa de tool, e cada argumento de conjunto fechado (enum/boolean). Depois decide:

| Modo | Quando | Efeito |
|---|---|---|
| `direct` | tool escolhida com confiança e **todos** os argumentos são enum/boolean/constante | o gateway responde a chamada de tool sozinho, **sem LLM** |
| `forced` | tool escolhida, argumentos abertos | reenvia ao LLM com `tool_choice` = essa tool; o LLM só preenche argumentos (opcional `ARGS_MODEL` mais barato) |
| `hint` | `tool_choice` não pode mudar (Claude Code com thinking, cache) | acrescenta uma sugestão de uma linha |
| `none` | Jev confiante de que não precisa de tool | `tool_choice: none` (padrão, exceto Codex) |
| `passthrough` | confiança < 0,7, as duas perguntas discordam (`needs_tool`), erro/timeout (4 s), sem tools, etc. | request intacto |

- **Como intercepta** (`src/app.ts`, `src/adapters/chat.ts`): rotas `POST /v1/chat/completions`, `/v1/responses`, `/v1/messages`, Gemini e Devin (protobuf). O cliente aponta o `baseURL` ao gateway; o gateway lê o corpo, decide, reescreve (`tool_choice`) e repassa a **um único upstream** (`UPSTREAM_BASE_URL`, o caminho `/v1` é cortado e anexado), com o header `Authorization` do cliente intacto. Resposta de upstream com 400/422 a um request reescrito → reenvia o original (`upstream_rejected_*`).
- **Fallback quando o Jev falha:** abre (fail-open). Erro, timeout de 4 s, resposta inesperada → `passthrough`; 1 retry em 100 ms para 408/429/5xx. Se o *gateway* cai, o cliente fica sem endpoint (não há fail-open do lado do cliente).
- **Portas e dashboard:** launchers usam 8788 (Gemini), 8789 (Claude), 8790 (Codex), 8791 (opencode), 8792 (Devin), 8793 (Kilo); servidor avulso, 8787. Escuta só em `127.0.0.1`. `/dashboard` (atualiza a cada 2 s, mostra só metadados) e `/router/decide` (dry-run que chama o Jev) **sem autenticação** quando não há `ROUTER_API_KEY`: qualquer processo local pode gastar a chave do Jev (o README admite).
- **Dependências e supply chain:** runtime = `hono` 4.13.8 + `@hono/node-server` 2.1.1 (peer = hono); **0 dependências transitivas em runtime** (lockfile conferido). O resto dos 116 pacotes do lockfile é dev (vitest, vite, tsx, typescript, esbuild…); `@typesafe-ai/sdk` é devDependency e só entra por `import type`. Sem `postinstall`/`preinstall` próprios. Publicação por npm *trusted publishing* (OIDC), Actions fixadas por SHA, CI com `--frozen-lockfile`. Rede: só o endpoint do Jev e o upstream configurados; não achei telemetria em `src/` nem `bin/`. Ponto fraco: mantenedor único, projeto de 6 semanas, API do Jev em evolução (providers e alias `jev-latest` mudaram em outubro).
- **O que grava em disco:** `~/.jev-gateway/.env` (chave do Jev, 0600, dir 0700), `~/.jev-gateway/<client>.log` (JSON por request: modelo, nomes de tool, confiança, tokens, motivo; **sem prompt nem argumentos**) e `<client>.pid`. Opt-in `JEV_DEBUG_DUMP_DIR` grava o corpo inteiro (conversa completa; headers sensíveis mascarados; arquivos 0600). Os launchers não tocam `~/.codex`, `~/.config/opencode` etc. Só existem se usarmos os launchers `jev-*`; rodando o servidor avulso, o log vai ao stdout.

## 2. Dados que saem e para quem

"Gateway" = o `jev-gateway` rodando local. "Provider do Jev" = TypeSafe, OpenRouter, Vercel ou OpenCode Zen, à escolha (`JEV_PROVIDER`).

| Dado | Vai para | Quando / limite | Observação |
|---|---|---|---|
| Corpo inteiro da request (prompt, tools, histórico) + `Authorization` do cliente | **Upstream do LLM** (NVIDIA, OpenRouter…) | sempre | **igual a hoje**; o gateway só passa pelo meio |
| System prompt (≤ 4 000 caracteres por campo) | **Provider do Jev** | a cada request com `tools` | truncado "cabeça 60% + cauda" |
| Nome e descrição de cada tool (≤ 1 024 caracteres; orçamento 48 000) | Provider do Jev | idem | não são segredo |
| Voltas recentes da conversa: texto do usuário, texto do modelo, **argumentos das tool calls e saídas das tools** (cada campo ≤ 4 000 caracteres; total ≤ 60 000, ~15 mil tokens) | Provider do Jev | idem | **aqui vão trechos de arquivo lidos, saída de `bash`, caminhos, o texto da TASK**. Sem redação de segredos |
| Até 2 imagens PNG/JPEG inline (`JEV_MAX_IMAGES`) | Provider do Jev | se existirem | `0` desliga |
| Chave do Jev (`Bearer`) | Provider do Jev | idem | nunca vai ao LLM |
| `http-referer: github.com/vinilana/jev-gateway`, `x-title` | Provider do Jev | idem | atribuição no OpenRouter |
| Chave do LLM do cliente | só passa para o upstream do LLM | idem | o gateway local a vê em memória |
| Logs de roteamento | disco local | sempre | metadados |

**Política de dados dos providers do Jev** (a verificar em contrato; não achei texto primário):
- OpenCode Zen: declara "zero-retention, não treina" para provedores em geral e **não** lista exceção para o Jev, mas também **não** dá política própria do Jev; remete à doc da TypeSafe ([doc do Zen](https://opencode.ai/docs/zen/)).
- TypeSafe: fontes secundárias dizem que a política de privacidade proíbe treinar com prompts; retenção é contraditória entre as fontes (ZDR só para enterprise; DPA sem prazo); hospedagem nos EUA ([resumo](https://neuraltrust.ai/blog/jev-typesafe-ai-security), [innFactory](https://innfactory.ai/en/ai-models/typesafe-jev/)). A página de introdução da doc ([docs.typesafe.ai](https://docs.typesafe.ai/introduction)) não diz nada sobre retenção ou treino.
- OpenRouter e Vercel: política para o modelo Jev não verificada.

**Leitura para as regras do workspace:** o operador "vê dados do workspace; só modelo sem treino e já aprovado". O Jev como intermediário nesse caminho é **um terceiro novo** com o mesmo conteúdo. Para executor em repo MIT é menos grave, mas o texto da TASK e o código que o executor lê também iriam. **Isto é decisão do dono; nenhum dado real foi enviado nesta avaliação.**

## 3. Compatibilidade com o nosso stack

Versões locais: opencode v2.2.2, Pi 1.4.0, Hermes v0.22.5.

| Cliente | Dá para pôr o gateway no caminho? | Evidência |
|---|---|---|
| **opencode v2.2.2** (lanes `opencode run`, Zen/Go) | **Provavelmente não pelo launcher; não verificado para configuração manual.** | O README testa a v1.18.31 e diz "OpenCode v2 is out of scope". Na v2.2.2: `opencode debug config` devolve um *array* de documentos, não o objeto que o launcher espera (`/^\{/m`); injetei um provider `jev-gateway` por `OPENCODE_CONFIG_CONTENT` e por `OPENCODE_CLI_CONFIG_CONTENT` e **nenhum apareceu** em `debug config`; as duas variáveis `OPENCODE_EXPERIMENTAL_NATIVE_LLM`/`_CODE_MODE` que o launcher liga **não existem** no binário da v2. O binário v2 tem strings `systemone` (suporte próprio a classificadores). Além disso, nossos modelos (`opencode/…-free`, `opencode-go/…`, `nvidia/…`) não apontam para um `baseURL` nosso; cada um exigiria um provider custom, e o gateway só tem **um** upstream por instância. Zen free "exige OpenCode" (doc do Zen), e não sei se isso sobrevive a um proxy. |
| **Pi 1.4.0** (lanes `pi:<provider/modelo>`) | **Sim, tecnicamente, pelo `baseUrl`.** | `models.json` aceita sobrescrever só `baseUrl` de um provider mantendo o catálogo ([custom-provider.md](https://github.com/earendil-works/pi)); o gateway fala Chat Completions (`openai-completions`), que é o que o Pi usa nos providers NVIDIA e OpenRouter. Precisaria de **uma instância por upstream** (NVIDIA numa porta, OpenRouter em outra) e `~/.pi/agent/models.json` alterado (não alterei). Sem launcher: tem que subir/derrubar o gateway fora do `lane.sh`. |
| **Hermes v0.22.5** | **Possível, não testado.** | O perfil `pinga` já usa `model.base_url` (`https://opencode.ai/zen/v1`), então um `base_url` local OpenAI-compatível é suportado em princípio. O README não cita o Hermes. O Hermes só faz `hermes send`/operações pontuais; não é onde as lanes gastam passos. |
| **NVIDIA/OpenRouter free pelo Pi** | **O gateway entraria no caminho**, upstream = `https://integrate.api.nvidia.com/v1` ou `https://openrouter.ai/api/v1`. | Riscos: (1) o `tool_choice` forçado pode ser ignorado (o README diz isso de `kilo-auto/free` e `nemotron-3-super:free`) ou rejeitado → reenvio gasta 2 requests da cota; (2) o `lane.sh` detecta 429/cota por texto no log do Pi, e um gateway no meio muda esse log; (3) gateway fora do ar = Pi sem modelo (conexão recusada, não fail-open), vira `infra_stuck` só 15 min depois. |
| **`lane.sh` / `dispatch-task.sh`** | Não precisam mudar as chamadas (`pi -p --model …`); só precisariam subir o gateway antes e a config do Pi apontar para ele. | O gateway fica entre o Pi e o provider, **não** entre o `lane.sh` e o modelo. |

**Teste local seguro que dá para fazer, e que não fiz:** `npm ci --ignore-scripts` + `pnpm test` do gateway dentro de `bwrap` sem rede, para ver que o código roda e que `scripts/mock-jev.mjs` (um Jev falso) deixa exercitar o roteamento **sem chave**. Exige instalar código de terceiros; deixei para o OK do dono.

## 4. Valor esperado

- **Evidência pública:** o benchmark do próprio autor, [jev-gateway-bench](https://github.com/vinilana/jev-gateway-bench): 6 modelos fortes (GPT-6 Astra/Sol/Luna no Codex; Fable 5.1, Opus 5, Sonnet 5 no Claude Code), 2 tarefas de xadrez (provavelmente vistas no treino), 5 execuções por célula, 120 sessões, medianas. Depuração: menos tokens de saída em todos (−7% a −57%). Feature: misto (Opus 5 +22% saída, +61% entrada, +83% tempo; Sonnet 5 +9%/+16%/+37%; Luna 3/5 resolvidas com Jev e 5/5 sem). Série opencode v1 com Opus 5: −62% saída e −79% tempo em depuração, −29%/−31% em feature, 5/5 sempre; o próprio texto diz que não isola o harness como causa. A doc da TypeSafe não traz números de acurácia ([introdução](https://docs.typesafe.ai/introduction)). **Nada sobre modelo free ou pequeno.**
- **Onde o "Jev escolhe a tool" ajuda:** (a) rosters grandes (Claude Code manda ~280 tools; o Jev ranqueia em duas chamadas); (b) modelos com raciocínio caro, em que forçar a tool poupa tokens de pensamento; (c) depuração, em que o próximo passo é mais óbvio. **Onde não ajuda:** o nosso Pi tem poucas tools (read/bash/edit/write); a escolha é quase trivial e o erro de tool é raro (2 em ~390 logs). Para modelo free pequeno (`lightning` 3B ativos), o risco é o contrário: forçar a tool errada com confiança ≥ 0,7 faz o agente derrapar (o README admite) e o "Luna" do benchmark piorou em correção.
- **Contra o que realmente limita as lanes (cota por request):** `direct` nunca dispara com nossas tools; `forced` mantém 1 request/passo; o reenvio por 400/422 soma +1. No melhor caso o gateway encurta o número de passos (como no benchmark, −15% a −42% de requests em alguns modelos fortes), o que **não está medido para os nossos modelos**.
- **Latência e custo por passo** (README e preços do Zen): o Jev leva ~0,5 a 1 s por turno com tools (o README cita 712 ms no teste de chave e < 0,5 s no Kilo); timeout de 4 s; janela de 32k tokens. Nas lanes, um passo de modelo free leva de segundos a dezenas de segundos, então +0,5 a 1 s é +5% a +15%. Custo no Jev pago: US$ 0,042 por 1M de entrada, saída grátis ([Zen](https://opencode.ai/docs/zen/)); estado de até ~15 mil tokens → **≤ US$ 0,0006 por passo**, ~US$ 0,025 por TASK de 40 passos, ~US$ 0,6 por 1 000 passos (com estados típicos menores, ~US$ 0,2). Em OpenRouter/Vercel o preço do Jev não foi verificado.
- **O que sobra de gratuito de fato:** (1) **Jev 1.13 Free pelo OpenCode Zen**, "por tempo limitado", sem prazo publicado; o Zen free de *chat* está esgotado e **não sei se o Jev Free divide esse limite** (não testei: não encontrei credencial do Zen no formato antigo, `~/.local/share/opencode/auth.json` não existe na v2, e não procurei a nova para não mexer em credenciais). (2) **Modelo de decisão local**, a única opção durável e grátis: `ggml-org/lev-GGUF` (4B, Apache-2.0, 3,03 GB em Q4_K_M, servido por `llama serve -hf …:Q4_K_M` em `/v1/systemone`; [página](https://huggingface.co/ggml-org/lev-GGUF)); o `OpenJev` de 27B é CC BY-NC e pesa 19,4 GB ([página](https://huggingface.co/ggml-org/OpenJev-GGUF)), inviável aqui. Esta máquina tem GTX 1650 de 4 GB e 15 GB de RAM com ~2 GB livres agora, sem llama.cpp instalado: o 4B só cabe no limite e processar 15 mil tokens por passo na CPU seria lento. **Local serve para classificação curta (centenas de tokens), não para tool por passo.** Sem números de acurácia publicados na página do `lev`.

## 5. Alternativas próprias (esforço e risco)

| Opção | O que é | Esforço | Risco | Ganho |
|---|---|---|---|---|
| **(a) Classificador determinístico de tool por regra** no `lane.sh`/extensão do Pi | Mapear etapa → tool permitida | ~0,5 dia | baixo, mas **pouco útil**: o fluxo já é prescrito pela TASK; escolher tool não é o gargalo | ~nenhum |
| **(a′) Guarda `tool_call` no Pi** (variante útil de (a)) | Extensão TS que bloqueia `edit`/`write` fora dos globs `touch` do PLAN e em testes congelados, antes de a escrita acontecer | ~0,5 a 1 dia (60 a 100 linhas, na API `pi.on("tool_call")`) | médio: a doc diz que **falha do handler bloqueia a tool** (fail-safe), então um bug trava a lane (15 min até `infra_stuck`); testar em `unittest`/lane de teste | ataca `scope_drift` (24) e `tests_frozen_changed` (5) de ~171 falhas; o `dispatch-task.sh` já restaura o snapshot, então hoje o custo é uma tentativa perdida |
| **(b) Jev só como classificador** (previsto no ROUTING): motivo de `BLOCKED:`, novo × regressão no judge, triagem de tier | Script `bin/jev-classify.sh` (curl do `systemone`) ou chamada `ctx.modelRegistry.classify()` no Pi, mais fixtures dos `log.md` (já há ~129 linhas `fail` com `reason_code` como rótulo, e ~10 `BLOCKED:` de texto livre) e o experimento de acurácia | ~0,5 a 1 dia para script + fixtures + medição | baixo-médio: calibração ruim (exigir confiança ≥ 0,85 e cair para regex/LLM abaixo); dado enviado (texto curto, mascarar segredos); Free por tempo limitado | volume pequeno (dezenas/dia), mas custo ~0 e já planejado; elimina intervenção manual na classificação de `BLOCKED:` |
| **(c) Hook no Pi (`before_provider_request`) que injeta `tool_choice`** a partir de um classificador | "Gateway dentro do Pi", sem processo extra | ~1 a 2 dias + bench A/B | médio-alto: `tool_choice` ignorado ou 400 em modelo free; não verifiquei se o hook é assíncrono e dá acesso ao `ctx` do classificador (a verificar em `types.ts`); mesmo problema de dados | desconhecido; só vale depois de medir a concordância em sombra |
| **(d) Medir antes de decidir: gateway em modo sombra** (`JEV_SHADOW=true`) numa sessão do Pi só com TASK sintética/repo MIT | O gateway pergunta ao Jev ao lado e **só registra** o que faria; o request vai intacto | ~1 a 2 h de preparo + OK do dono para instalar e para a chave | baixo (não altera a resposta; ainda envia dados ao Jev e custa tokens) | dá a taxa de concordância Jev × modelo free, a evidência que falta |

## 6. Passos propostos

1. **Agora (nada exige o dono):** nenhum. Não mudei `lane.env`, scripts, `~/.pi`, `~/.hermes` nem `opencode.json`.
2. **Recomendado, com OK do dono (item (b)):**
   1. Dono decide o provider e o escopo de dados do classificador (só texto curto e mascarado de `log.md`; nunca handoff/segredo).
   2. Dono cria a chave (abaixo). Eu extraio os rótulos dos `log.md`, escrevo `bin/jev-classify.sh` e rodo o experimento de acurácia (meta ≥ 90%, abaixo de 80% fica regex/regra) em texto sintético ou já anonimizado.
   3. Se passar, entra no PLAN-0008 como classificador; senão, registro o resultado e descarto.
3. **Opcional, mesmo OK (item (a′)):** TASK para a guarda `tool_call` do `scope_drift`, via fluxo do harness (TASK + RED + `pinga verify` + judge).
4. **Só se o dono quiser a evidência (item (d)):** sandbox `bwrap` + `npm ci --ignore-scripts`, gateway em sombra contra o Pi/NVIDIA, 20 a 30 passos de TASK sintética.
5. **Reabrir a decisão se:** o roster de tools passar de ~30 (muitos MCP), aparecerem erros de tool nos logs, ou um benchmark público mostrar ganho em modelo pequeno/free.

### Diff proposto, NÃO aplicado (só se o item (d) ou uma adoção futura for aprovado)

`~/.pi/agent/models.json` (hoje só tem `local-llama`): apontar o provider `nvidia` ao gateway local; usar `compat` do provider se o Pi pedir.

```json
{ "providers": { "nvidia": { "baseUrl": "http://127.0.0.1:8794/v1" } } }
```

Gateway (fora do `lane.sh`; uma instância por upstream, em sombra):

```bash
JEV_SHADOW=true JEV_CLIENT=pi PORT=8794 UPSTREAM_BASE_URL=https://integrate.api.nvidia.com/v1 \
  JEV_PROVIDER=opencode OPENCODE_API_KEY=… node dist/index.js   # chave do dono; build em sandbox
```

## 7. Chaves e contas (passo a passo para o dono; não fiz nenhum)

Todos exigem decisão do dono (conta, chave e dados a um terceiro). Qualquer um serve; o código tem a mesma interface.

1. **OpenCode Zen** (`jev-1.13-free`, grátis por tempo limitado; `jev-1.13` pago a US$ 0,042/1M): https://opencode.ai/auth → API key (`OPENCODE_API_KEY`). Zen já é provider usado; o saldo pago do Zen está baixo (ROUTING). Verificar se o Free divide o limite do Zen free.
2. **OpenRouter** (`typesafe/jev-1.13`, `typesafe/jev-1.14`): o dono já tem a chave e US$ 10; só falta liberar uso do classificador (preço do Jev lá não verificado). Configurar Privacy → treino desligado, como na pesquisa free.
3. **TypeSafe direto** (`jev-latest`): https://typesafe.ai (cadastro e chave `TYPESAFE_API_KEY`); a política de retenção deve ser confirmada por escrito (DPA).
4. **Vercel AI Gateway** (`typesafe-ai/jev`): https://vercel.com/dashboard/ai-gateway/api-keys.
5. **Local, sem terceiro** (só para classificação curta): instalar llama.cpp ≥ 0.6.0 e `llama serve -hf ggml-org/lev-GGUF:Q4_K_M`; o Pi lista como classificador. Download de 3 GB; confirmar memória disponível.

## 8. Limites desta avaliação

- Não instalei nem executei o gateway; só li o código. Afirmações sobre comportamento em runtime vêm do README, dos testes e do código, não de uma execução.
- Não chamei o Jev: sem chave do Jev, sem credencial do Zen acessível, e usar o crédito OpenRouter do dono (mesmo ~US$ 0,001) pareceu decisão dele.
- A política de dados da TypeSafe vem de fontes secundárias; precisa de confirmação primária.
- A incompatibilidade com opencode v2.2.2 é de `debug config` e de variáveis de ambiente; uma configuração manual em `opencode.json` não foi testada (não posso alterá-lo).
- A contagem de falhas vem de `grep` nos `log.md` e nos logs das lanes (191 logs de lane, 198 de TASK); é ordem de grandeza, não taxa por modelo.

## Fontes

- Código e README do gateway: https://github.com/vinilana/jev-gateway (commit `83b5b98`, 2026-10-22); `src/decide.ts`, `src/state.ts`, `src/app.ts`, `src/upstream.ts`, `src/jev.ts`, `bin/launcher.mjs`, `bin/clients.mjs`, `bin/setup.mjs`, `pnpm-lock.yaml`.
- Benchmark: https://github.com/vinilana/jev-gateway-bench
- TypeSafe, introdução: https://docs.typesafe.ai/introduction
- OpenCode Zen (Jev, preços, privacidade): https://opencode.ai/docs/zen/
- Privacidade da TypeSafe (secundárias): https://neuraltrust.ai/blog/jev-typesafe-ai-security, https://innfactory.ai/en/ai-models/typesafe-jev/
- Modelos de decisão locais: https://huggingface.co/ggml-org/lev-GGUF, https://huggingface.co/ggml-org/OpenJev-GGUF
- Pi 1.4.0 (docs locais em `~/.local/share/mise/installs/pi/latest/pi/docs/`): `models.md` ("Use classifier models"), `codemode.md`, `virtual-models.md`, `llama-cpp.md`, `extensions.md`, `models-configuration.md`, `custom-provider.md`, exemplo `examples/extensions/jev-router.ts`.
- Contexto local: `.ginga/models/ROUTING.md`, `.ginga/knowledge/research/determinismo-e-placement.md`, `.ginga/knowledge/research/modelos-free-2026-10-29.md`, `.ginga/handoffs/lane.env`, `.ginga/bin/lane.sh`, `.ginga/bin/dispatch-task.sh`, `.ginga/plans/*/log.md`.
