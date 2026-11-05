---
type: research
title: Perfis do Hermes por tipo de trabalho
date: 2026-10-29
status: aplicado em 2026-10-29 ~22:30 (dono: "bora"): pinga migrado, executor e pesquisa criados; falta integrar o executor nas lanes
---
# Perfis do Hermes: um por tipo de trabalho

> **ATUALIZAÇÃO (aplicado):** ver a seção 9. Onde o texto abaixo diz "proposta", valem os resultados da seção 9; em especial o `muse-glimmer-30b` **saiu** da cadeia do controle (falha de tool calling no Hermes).

## Resumo

1. **Só dois papéis chamam o Hermes hoje**: o **controle** (gateway do Discord, com LLM) e o **aviso** (`hermes send`, sem LLM). A **compressão de contexto** é um auxiliar dentro de cada perfil. Operador, executor, judge e planner/pesquisa **não** usam o Hermes: rodam em Pi, opencode e Claude Code (tabela 1).
2. Por isso "um perfil por papel" tem dois sentidos. Os perfis de **operador** e **judge** não trazem ganho: o Pi (operador) e o Claude (judge) já fazem isso e funcionam. Os perfis que trazem ganho são os que **abrem capacidade nova**: um **executor** e uma **pesquisa** em cima dos modelos free do Nous Portal (conta do dono, hoje sem uso).
3. **Proposta: 3 perfis agora, 2 reservados.**
   - `pinga` (controle, **mantém o nome**) → NVIDIA, Zen pago só como último fallback.
   - `executor` (novo) → Nous free, só repo MIT.
   - `pesquisa` (novo) → Nous free, só pergunta pública.
   - `operador` e `judge`: config pronta, **não criar** (justificativa na seção 3).
4. **Validado hoje** (sem `--yolo`): o Nous faz tool calling de arquivo (ler e editar) nos 3 modelos; as 3 configs carregam em perfil temporário; `fallback_providers` funciona. **Não validado**: NVIDIA pelo Hermes (o Hermes só lê a chave do `.env` do perfil, não do ambiente), terminal/testes no executor, política de dados do Nous.
5. **Precisa do dono**: (a) OK para criar os perfis; (b) aprovar o Nous como destino de dados (executor MIT e pesquisa pública); (c) pôr `NVIDIA_API_KEY` no `.env` do `pinga` (comando na seção 6); (d) `approvals.mode` do controle (`off` hoje vs `manual`); (e) manter ou tirar o Zen pago do fim da cadeia do controle.

## 1. Quem chama o Hermes hoje

| Papel | Quem executa | Chama o Hermes? | Fonte |
|---|---|---|---|
| Controle (Discord) | gateway do Hermes, perfil `pinga`, LLM `opencode-zen/deepseek-v4.1-flash` | **Sim, com LLM**. Roda `status.sh` e lança `claude -p` em segundo plano | `prompts/hermes-controle.md` |
| Aviso | `bin/notify.sh` → `hermes send -t discord` com `HERMES_HOME=…/profiles/pinga` | **Sim, sem LLM**: só usa o token do bot do perfil | `bin/notify.sh:4` |
| Compressão de contexto | `auxiliary.compression` do perfil | **Sim**, em cada perfil: `pinga` usa `opencode-zen/deepseek-v4.1-flash` (pago) | `profiles/pinga/config.yaml` |
| Plugin `pinga-harness` | ferramentas `pinga`/`gira`/Maestro dentro do Hermes (subprocess para `pinga.ts`) | Roda **dentro** do Hermes; não chama modelo | `plugins/pinga-harness/__init__.py` |
| Operador de lane | `lane.sh`: `pi:` / `claude/` / `opencode run` | **Não** | `bin/lane.sh:34-36` |
| Executor | `dispatch-task.sh`: `pi -p` / `opencode run` | **Não** | `bin/dispatch-task.sh:57,75-77` |
| Judge | `judge-run.sh`: `claude -p` (plan, read-only); fallback `opencode run … gpt-6-luna` | **Não** | `bin/judge-run.sh:31,38` |
| Planner / pesquisa | Claude Code (assinatura) | **Não** | `ROUTING.md` |

Fatos de infraestrutura que pesam no desenho (lidos em `~/.hermes`, v0.22.5):

- **Um só gateway multiplexado** (`gateway.multiplex_profiles: true`, pid 3415174, `served_profiles: [default, pinga]`) atende o Telegram do perfil `default` e o Discord do `pinga`. **Reiniciar o gateway derruba os dois.**
- Perfis novos em `profiles/` entram no multiplexador (cada um com seu `state.db`), mas **só sobem adapter de Discord se tiverem token próprio**. Dois perfis com o mesmo token do bot colidem (o `profile create` recusa `--clone-channels` num gateway vivo). Logo: **só um perfil tem Discord, o `pinga`**.
- `notify.sh` e o `hermes-controle.md` têm o caminho `profiles/pinga` fixo. **Renomear o `pinga` quebra o aviso.** Mantenha o nome.
- Credenciais: o `auth.json` do `pinga` só tem `credential_pool` de `opencode-zen`/`opencode-go`, mas `hermes auth status nous` dá "logged in" nele e "logged out" num perfil em diretório vazio. Ou seja, o login do Nous é **da instalação** (`~/.hermes`), não do perfil, então perfis em `~/.hermes/profiles/` herdam o Nous. Isso é inferência; confirmar com `hermes auth status nous` logo após criar o primeiro.
- Chaves de API (NVIDIA, Zen) ficam no **`.env` do perfil**. `profile create --clone` copia o `.env` (menos tokens de bot); por isso crie **sem `--clone`** e ponha só a chave que cada perfil precisa.

## 2. Tabela: papel × perfil × modelo × fallback × privacidade × validação

| Papel | Perfil | Modelo primário | Cadeia de fallback | Privacidade | Estado |
|---|---|---|---|---|---|
| Controle + aviso + compressão do controle | `pinga` (existe) | `nvidia/mistralai/mistral-large-4-1t-a52b` | muse-glimmer-30b → nemotron-3.5-lightning → `opencode-zen/deepseek-v4.1-flash` (pago, último) | Dados do dono e do workspace: **só NVIDIA** (aprovada). O Zen pago só no fim, como já é hoje | ⚠️ cadeia carrega; **modelo NVIDIA não testado no Hermes** (falta a chave no `.env`) |
| Executor (repo MIT) | `executor` (novo) | `nous/stepfun/step-3.7-flash:free` | ornith-1.5-122b → beam-1.0-501b → `nvidia/mistral-large-4` | **Só repo MIT.** Nous: política **não verificada** → exige OK do dono | ✅ ler+editar arquivo, 3/3 modelos (7 a 19 s); ❌ terminal/testes não rodados |
| Pesquisa | `pesquisa` (novo) | `nous/stepfun/step-3.7-flash:free` | ornith → beam | Só pergunta pública; **nunca** trecho do workspace. Exige OK do dono para o Nous | ✅ tool calling de arquivo; ❌ `web` não testado |
| Operador de lane | `operador` (**reservado**) | `nvidia/mistral-large-4` | muse-glimmer → lightning (= `OP_MODELS`) | Só NVIDIA | ❌ não criar (seção 3) |
| Judge | `judge` (**reservado**) | `nvidia/mistral-large-4` | muse-glimmer | Lê repo privado: só NVIDIA; família diferente do executor | ❌ não criar (seção 3) |

Famílias e judge: o `pinga judge` exige família diferente do executor (`assertDistinctFamily`). Executor Nous (StepFun/Ornith/Reflection) e judge Claude já são distintos; um judge NVIDIA-Mistral também seria, mas não há razão para trocar o Claude.

Probes do dia (2026-10-29, `HERMES_HOME=~/.hermes`, stdin fechado, toolset `file`, sem `--yolo`):

| Modelo Nous | Ler `nota.txt` → `AZUL-7421` | Corrigir `a-b` → `a+b` com edição de arquivo |
|---|---|---|
| `stepfun/step-3.7-flash:free` | ✅ 7 s | ✅ 19 s |
| `ornith/ornith-1.5-122b:free` | ✅ 7 s | ✅ 16 s |
| `reflection/beam-1.0-501b-a23b:free` | não rodado | ✅ 8 s |

Isso prova tool calling de **arquivo**. Não prova que o modelo roda o `done_when` no terminal e itera sobre a falha, que é o que o executor faz de verdade.

## 3. Por que `operador` e `judge` ficam só reservados

- **Operador.** O Pi já roda a escada NVIDIA como operador (`lane.sh:35`). Um perfil Hermes faria o mesmo trabalho com outro cliente, e dividiria a mesma cota da NVIDIA (~40 req/min **por conta**, compartilhada). Nenhum ganho de capacidade, mais uma peça. Só vale se o Pi sair de cena.
- **Judge.** O `judge-run.sh` depende de `claude -p --permission-mode plan --disallowedTools Edit,Write` e confere que a worktree não mudou. O Hermes não tem um modo "somente leitura" equivalente garantido (o toolset `file` inclui escrita). Perderíamos a garantia de separação de processos que o script dá.
- Os `config.yaml` deles estão na seção 4, prontos, para o dia em que a lane precisar.

## 4. `config.yaml` propostos (texto; nada gravado)

Todos validados em perfil temporário com `hermes config check/get` e `hermes fallback list`. Falta a linha `_config_version: 52` nos perfis novos (o `config check` acusa "0 → 52"); o `hermes config migrate` a acrescenta.

### 4.1 `pinga` (controle) — substitui o atual

```yaml
model:
  provider: nvidia
  default: mistralai/mistral-large-4-1t-a52b
  context_length: 65536
fallback_providers:
  - {provider: nvidia, model: meta/muse-glimmer-30b}
  - {provider: nvidia, model: nvidia/nemotron-3.5-lightning-30b-a3b}
  - {provider: opencode-zen, model: deepseek-v4.1-flash}   # pago; único fallback fora da cota NVIDIA
approvals:
  mode: manual            # hoje "off". Ver decisão (d). Pedidos perigosos chegam como /approve no Discord
  single_query_mode: deny
  unattended_mode: deny
  cron_mode: deny
agent:
  max_turns: 40
auxiliary:
  compression:
    provider: nvidia
    model: meta/muse-glimmer-30b
    context_length: 65536
platform_toolsets:
  discord: [terminal, memory, session_search, clarify, todo, pinga]   # sem web, file, delegation, code_execution
plugins:
  enabled: [pinga-harness, tuios-agent-state]
  disabled: [g-inga]
display: {skin: omarchy}
platforms: { …  # manter o bloco discord atual (home_channel, allowed_users) sem mudança }
_config_version: 52
```

Mantidos do atual: `display`, `platforms.discord`, `local_runtime`, `telemetry`, `skills.disabled`, `onboarding`. O `.env` ganha `NVIDIA_API_KEY` e mantém `DISCORD_*` e `OPENCODE_ZEN_API_KEY`; o `OPENCODE_GO_API_KEY` pode sair (Go é proibido fora do `opencode run`).

Contexto: 65536 é folgado para um controle que só roda `status.sh` e lança operador; a compressão corta antes.

### 4.2 `executor`

```yaml
model:
  provider: nous
  default: stepfun/step-3.7-flash:free
  context_length: 131072
fallback_providers:
  - {provider: nous, model: "ornith/ornith-1.5-122b:free"}
  - {provider: nous, model: "reflection/beam-1.0-501b-a23b:free"}
  - {provider: nvidia, model: mistralai/mistral-large-4-1t-a52b}
approvals:
  mode: manual
  single_query_mode: deny   # `hermes -z`: comando perigoso é NEGADO, nunca aprovado; sem --yolo
agent:
  max_turns: 60
auxiliary:
  compression:
    provider: nous
    model: "stepfun/step-3.7-flash:free"
    context_length: 131072
platform_toolsets:
  cli: [file, terminal, todo]
plugins:
  enabled: []
_config_version: 52
```

`.env`: só `NVIDIA_API_KEY` (para o último fallback). Sem Discord, sem Zen. Regra de uso: **só repo MIT**, e o `dispatch-task.sh` precisa recusar repo privado nesse slot. Context 131072 é palpite (não medi o limite do Nous); se der 400, baixe para 65536.

### 4.3 `pesquisa`

```yaml
model:
  provider: nous
  default: stepfun/step-3.7-flash:free
  context_length: 131072
fallback_providers:
  - {provider: nous, model: "ornith/ornith-1.5-122b:free"}
  - {provider: nous, model: "reflection/beam-1.0-501b-a23b:free"}
approvals: {mode: manual, single_query_mode: deny}
agent: {max_turns: 30}
auxiliary:
  compression: {provider: nous, model: "stepfun/step-3.7-flash:free", context_length: 131072}
platform_toolsets:
  cli: [web, file, memory, session_search, todo]
plugins: {enabled: []}
_config_version: 52
```

Sem `terminal` e sem NVIDIA: não toca o workspace por acaso e não tem chave de ninguém. Regra de uso: prompt sem dados do workspace.

### 4.4 Reservados (não criar)

`operador`: igual ao `pinga` acima, sem `platforms`, `provider: nvidia`, cadeia `mistral-large-4 → muse-glimmer → lightning`, `platform_toolsets.cli: [file, terminal, todo]`, `.env` só com `NVIDIA_API_KEY`.
`judge`: igual, `platform_toolsets.cli: [file]`, cadeia `mistral-large-4 → muse-glimmer`. Sem garantia de somente leitura (seção 3).

## 5. Migração do perfil `pinga` atual

Ordem segura (cada passo precisa do OK do dono; o gateway é compartilhado com o Telegram):

1. **Backup**: `cp ~/.hermes/profiles/pinga/config.yaml{,.bak-20261029}` e `.env` idem.
2. **Chave NVIDIA** no `.env` do `pinga` (comando na seção 6, não imprime o valor).
3. **Teste antes de ligar**: probe com o modelo NVIDIA pelo próprio perfil (seção 6), incluindo tool calling de arquivo. Se falhar, **pare**: o `pinga` segue como está.
4. **Aplicar o `config.yaml`** da seção 4.1 (diff, não reescrita: trocar `model`, `fallback_providers`, `approvals`, `agent`, `auxiliary.compression`, `platform_toolsets`).
5. **Reiniciar o gateway** (`hermes gateway restart`): derruba Telegram e Discord uns segundos. Fazer quando as lanes estiverem paradas.
6. **Verificar**: `HERMES_HOME=~/.hermes/profiles/pinga hermes fallback list`; `bin/notify.sh "teste de perfil"` (chega no Discord); uma mensagem "status" no canal e conferir o modelo no log.
7. **Reverter** se qualquer passo falhar: restaurar o `.bak` e reiniciar o gateway.
8. Só depois criar `executor` e `pesquisa` (`hermes profile create executor --no-alias --no-skills --description "…"`, sem `--clone`), gravar a config, `hermes auth status nous` e rodar o teste de TASK da seção 6.
9. Integração do executor no `dispatch-task.sh` (diff abaixo) e na escada do `lane.env`, **só depois** do teste de TASK com terminal passar.

Diff proposto (não aplicado) em `bin/dispatch-task.sh:75-77`:

```bash
      hermes:*) (cd "$WT" && HERMES_HOME=/home/shibuka/.hermes/profiles/${m#hermes:} \
                   timeout -k 30 "$ATT_TIMEOUT" hermes -z "$(cat "$T"; echo; echo "$BASE $prev")" </dev/null >"$LOG" 2>&1);;
```

e em `handoffs/lane.env`, `EXEC_MODELS`: inserir `hermes:executor` **depois de** `opencode-go/iceman-contributor-free`. O Nous tem cota própria, então tirar carga da NVIDIA (que o operador também consome) é o ganho real. O perfil faz o fallback interno, então conta como um slot na escada.

## 6. Comandos para o dono colar com `!`

**a) Chave NVIDIA no perfil `pinga`** (copia da chave que o Pi já usa; não imprime):

```bash
! python3 -c "import json,os;print('NVIDIA_API_KEY='+json.load(open(os.path.expanduser('~/.pi/agent/auth.json')))['nvidia']['key'])" >> ~/.hermes/profiles/pinga/.env && chmod 600 ~/.hermes/profiles/pinga/.env
```

**b) Probe NVIDIA pelo Hermes, com tool calling** (depois de (a); não altera nada além da sessão):

```bash
! mkdir -p /tmp/hp && echo "codigo-secreto: AZUL-7421" > /tmp/hp/nota.txt && cd /tmp/hp && for m in mistralai/mistral-large-4-1t-a52b meta/muse-glimmer-30b nvidia/nemotron-3.5-lightning-30b-a3b; do echo "== $m"; HERMES_HOME=$HOME/.hermes/profiles/pinga timeout 120 hermes -z "Leia /tmp/hp/nota.txt com a ferramenta de arquivo e responda só com o codigo-secreto." --provider nvidia -m "$m" -t file < /dev/null 2>&1 | tail -3; done
```

**c) Teste de TASK do executor com terminal, sem `--yolo`** (rode só depois de criar o perfil `executor`; `single_query_mode: deny` nega comando perigoso e o `cd` fica num diretório descartável):

```bash
! rm -rf /tmp/hx && mkdir -p /tmp/hx && cd /tmp/hx && printf 'export const soma=(a:number,b:number)=>a-b\n' > soma.ts && printf 'import {test,expect} from "bun:test"\nimport {soma} from "./soma"\ntest("soma",()=>expect(soma(2,3)).toBe(5))\n' > soma.test.ts && HERMES_HOME=$HOME/.hermes/profiles/executor timeout 300 hermes -z "O teste soma.test.ts falha. Rode 'bun test', corrija soma.ts com edição cirúrgica, rode de novo e responda só 'verde' ou 'vermelho'." < /dev/null 2>&1 | tail -5; bun test 2>&1 | tail -3
```

Critério de aprovação: sai "verde" **e** o `bun test` final passa, nas duas chamadas seguidas (uma por modelo, trocando `-m`).

## 7. Riscos

| Risco | Efeito | Mitigação |
|---|---|---|
| Gateway compartilhado | Reiniciar para aplicar a config derruba o Telegram do `default` e o Discord do `pinga` | Reiniciar com lanes paradas; backup e rollback no passo 7 |
| Cota NVIDIA única (~40 req/min por conta, dividida com o Pi) | Os três primeiros modelos do controle falham juntos quando as lanes saturam; o 4º (Zen pago) é o único independente | Manter o Zen no fim; controle é de baixo volume. Se o dono tirar o Zen, o controle fica mudo nesses momentos |
| `approvals: manual` no controle | O operador lançado via `nohup claude -p …` pode cair como "perigoso" e pedir `/approve` no Discord | Testar a mensagem "retoma" uma vez; se travar, voltar a `off` (decisão do dono) ou liberar o padrão em `command_allowlist` |
| Política de dados do Nous Portal não verificada | Código MIT e perguntas públicas iriam a um terceiro novo | Decisão do dono antes de criar `executor`/`pesquisa`; o `pinga` não usa Nous |
| Modelos Poolside (`laguna-*`) treinam | Vazamento se entrassem na cadeia | Ficam **fora** de todas as cadeias |
| Executor sem validação de terminal | Pode "dizer" que corrigiu sem rodar o teste | Teste (c) e, na lane, o `done_when` + judge continuam sendo a fonte de verdade, não o relato do modelo |
| `executor` em repo privado | Dados privados no Nous | `dispatch-task.sh` precisa checar licença/visibilidade antes de escolher `hermes:executor` (hoje já é a regra do `iceman`) |
| `-z` sem stdin fechado | Trava | Sempre `< /dev/null` (já nos comandos) |
| Perfis novos entram no multiplexador | Cada um ganha `state.db` e participa do tick de cron | Sem cron nem plataforma, custo desprezível; conferir `hermes profile list` |
| Chave NVIDIA copiada para o `.env` do `pinga` | Mais um lugar com a chave | `chmod 600`; é a mesma conta já aprovada; revogar na NVIDIA se o perfil for descartado |
| `openrouter/free` e Gemini/Mistral Experiment | Treinam com os dados | Nenhum perfil Hermes os usa |

## 8. Decisões que são do dono

| # | Decisão | Recomendação |
|---|---|---|
| a | Criar `executor` e `pesquisa` e trocar o modelo do `pinga` | Sim, na ordem da seção 5 |
| b | Nous Portal como destino de dados (código MIT e pesquisa pública) | Só depois de ler a política de dados do Portal; até lá, nem `executor` nem `pesquisa` |
| c | Copiar `NVIDIA_API_KEY` para o `.env` do `pinga` | Sim (mesma conta aprovada) |
| d | `approvals` do controle: manter `off` ou `manual` | `manual`; reverter se travar o fluxo do operador |
| e | Zen pago no fim da cadeia do controle | Manter (saldo ~US$ 3; uso de controle custa centavos) |
| f | Criar `operador`/`judge` | Não, por ora |

## 9. Aplicado e validado (2026-10-29 22:20 a 22:35)

| Passo | Resultado |
|---|---|
| Backup | `profiles/pinga/config.yaml.bak-20261029` e `.env.bak-20261029` |
| `NVIDIA_API_KEY` no `.env` do `pinga` e do `executor` | feito (`chmod 600`, copiada de `~/.pi/agent/auth.json`, sem imprimir) |
| Probe NVIDIA pelo Hermes (ler arquivo, toolset `file`) | `mistral-large-4` ✅ 31 s (com lanes rodando); `nemotron-3.5-lightning` ✅ 14 s; **`muse-glimmer-30b` ❌** devolveu a chamada de ferramenta como texto cru (funciona no Pi, não no Hermes) |
| `pinga/config.yaml` aplicado | primário `nvidia/mistral-large-4`; fallback `nvidia/nemotron-3.5-lightning` → `opencode-zen/deepseek-v4.1-flash`; `approvals.mode: manual`; compressão em `nemotron-3.5-lightning`; `platform_toolsets.discord` reduzido |
| `hermes gateway restart` | gateway 522741, `discord`, `pinga:discord` e `telegram` conectados; `active_agents` era 0 |
| `notify.sh` após a migração | enviado |
| Perfis `executor` e `pesquisa` | criados sem `--clone`; `hermes auth status nous` = **logged in** (o login do Nous é da instalação, confirmado) |
| **Teste de TASK do executor com terminal, sem `--yolo`** (`bun test` falhando → corrigir → rodar de novo) | `step-3.7-flash` ✅ 40 s; `ornith-1.5-122b` ✅ 16 s; `beam-1.0-501b` ✅ 14 s; nos três o `bun test` final passou (1 pass, 0 fail) |
| `pesquisa` com `web` | respondeu com fonte em 27 s; não conferi se a resposta veio da ferramenta ou da memória do modelo |

Pendências:

1. **`dispatch-task.sh` e `lane.env` não foram alterados** (as lanes estão rodando). O diff da seção 5 continua válido; inserir `hermes:executor` na escada é o próximo passo, com TASK/RED pelo harness.
2. **Mensagem real no Discord** ao controle ainda não testada com `approvals: manual` (o fluxo "retoma" pode pedir `/approve`). Se travar, `approvals.mode: off` no `config.yaml` do `pinga` e `hermes gateway restart`.
3. O log do gateway tem `TERMINAL_CWD does not exist: …/p-inga-exec` (cwd antigo apontando para diretório inexistente): anterior a esta mudança, vale limpar.
4. **Política de dados do Nous (fonte: `nous-free-2026-10-29.md`, sessão nous-portal-free-validator):** prompts e saídas podem treinar os modelos da Nous e ser repassados a terceiros; sem retenção publicada; limites do plano free não publicados; catálogo free gira toda semana. O dono liberou código dos repos ("é tudo open source") **só para executor**. Logo: `executor` ok; `pesquisa` só pergunta pública; **o Nous nunca entra em operador, controle nem judge** (veem handoffs e ledger). O `laguna-*` expira em 2026-10-31 e treina: continua fora.
5. **Cuidado:** o `~/.hermes/config.yaml` global tem `approvals.mode: off`; rodar `hermes -z` com `HERMES_HOME=~/.hermes` e `terminal` equivale a `--yolo`. Em lane, use sempre `HERMES_HOME=…/profiles/executor` (manual + `single_query_mode: deny`).
6. **Rollback**: copiar os `.bak-20261029` de volta e `hermes gateway restart`.

## Fontes

- Código e docs locais: `~/.hermes/hermes-agent` (`agent/agent_init_fallback.py`, `gateway/AGENTS.md`, `website/docs/user-guide/security.md`), `hermes profile create --help`.
- `knowledge/research/modelos-free-2026-10-29.md` (escada, privacidade, seção Hermes/Nous), `models/ROUTING.md`, `handoffs/lane.env`, `prompts/hermes-controle.md`, `bin/{notify,lane,dispatch-task,judge-run}.sh`.
- Testes de hoje em diretório temporário (`HERMES_HOME=$(mktemp -d)`), sem tocar `profiles/*`; probes do Nous em `~/.hermes` com toolset `file` e stdin fechado.
