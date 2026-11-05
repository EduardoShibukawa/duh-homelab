---
type: research
title: Guard de segredos nas lanes (desenho, lista de bloqueio, riscos)
timestamp: 2026-10-29
status: draft
---

# Guard de segredos nas lanes

Cadeia: [INTENT-0013](../../intents/INTENT-0013-guard-de-segredos.md) → [SPEC-0005](../../specs/SPEC-0005-guard-de-segredos.md) → [PLAN-0033](../../plans/PLAN-0033-guard-de-segredos/PLAN.md) (8 TASKs, `draft`). Nada foi instalado nem executado nas lanes; o que rodou foi um protótipo e os testes dele num `mktemp`.

Legenda: **[verificado]** li no código/doc local ou rodei; **[inferência]** dedução minha, não confirmada.

## 1. Resumo

- **O que protege:** um hook `antes da tool` (Pi `tool_call`, opencode `tool.execute.before`, Hermes `pre_tool_call`) que barra leitura de segredo, e um hook `depois da tool` (Pi `tool_result`, opencode `tool.execute.after`, Hermes `transform_tool_result`) que **redige** formato de chave e valor de variável sensível antes de o resultado virar contexto (e, então, prompt para o provider).
- **Uma lista, um casador.** `deny.json` (dados) + `core.ts` (casador, ~110 linhas) + `cases.json` (a mesma tabela de testes nos três runtimes). Pi e opencode importam o casador; o plugin Hermes chama `bun src/guard/cli.ts` (não há segunda implementação).
- **Escopo por variável de ambiente `GINGA_GUARD_LANE`**, exportada pelas lanes e pelo `manda run`. Sem ela o guard é inerte, então as sessões interativas do dono não mudam.
- **Sem instalar nada em `~`:** Pi carrega por `pi -e <arquivo-do-repo>`, opencode por `OPENCODE_CONFIG_DIR=<dir-do-repo>`, Hermes por plugin ativado numa ação do dono.
- **Falha fechada.** Erro interno bloqueia; guard ligado e ausente = a lane não inicia.
- **Honestidade sobre o limite:** é uma camada de **regra**. Ela pega o caminho óbvio (`cat .env`) e o formato conhecido de chave; **não** pega o modelo que monta o caminho dinamicamente em shell, nem script que ele mesmo escreve. Fechar isso exige isolamento de processo (§6–§7).

## 2. Como cada runtime deixa bloquear [verificado]

| Runtime | Ponto de bloqueio | Como bloqueia | Ponto de redação | Como a fonte chega ao runtime (sem editar `~`) |
|---|---|---|---|---|
| **Pi** 1.4.0 | `pi.on("tool_call", (event, ctx) => …)` com `event.toolName`, `event.input` (docs `extensions.md`; exemplos `protected-paths.ts`, `permission-gate.ts`) | retornar `{ block: true, reason }` | `pi.on("tool_result")` (substitui `content` e `structuredContent`) | `pi -e <repo>/contrib/guard/pi.ts` (`-e` carrega mesmo com `-ne`, `cli.md:197`). O `lane.sh` já usa `pi -p` |
| **opencode** 2.2.2 | plugin com `"tool.execute.before": (input, output)`; `input.tool`, `output.args` | `throw new Error(…)` | `"tool.execute.after"` (muta `output.output`) | `OPENCODE_CONFIG_DIR=<repo>/contrib/guard/opencode-config` **[inferência: não verifiquei que a 2.2.2 lê essa variável; o binário local é um wrapper]**. Plano B isolado numa função: `OPENCODE_CONFIG_CONTENT` com `plugin: ["file://…"]`. Só vale em `opencode run --standalone` (plugin dentro do processo da sessão) |
| **Hermes** | plugin Python, `register(ctx)`, `ctx.register_hook("pre_tool_call", fn)`; kwargs `tool_name`, `args` | retornar **dict** `{"action":"block","message":…}` (`hermes_cli/plugins.py:1964-1983`); `block` vence `approve`; timeout de 30 s do núcleo = bloqueio | `transform_tool_result` (retorna `str`; fail-open pelo núcleo, `model_tools.py:831-848`) | plugin precisa estar em `plugins.enabled` do `config.yaml` do perfil (hoje `pinga-harness`, `tuios-agent-state`). **Ação do dono**; o Hermes não é runtime de lane hoje (só gateway do Discord) |
| Claude Code | `PreToolUse` (exit 2) | — | — | `claude --settings <json>`; operador `claude/*` do `lane.sh` está fora de uso. Fora deste PLAN (§7) |

**Nomes de tool divergem** (nos `runs/` reais do opencode: `shell`, `read`, `edit`, `grep`, `glob`; no Pi: `bash`, `read`, `edit`, `write`, `grep`, `find`, `ls`; no Hermes: `terminal`, `read_file`, `write_file`, `patch`, `search_files`, `execute_code`). Por isso o casador olha as **chaves do `input`** (`path|filePath|file_path|…`, `command|cmd|script|code`, `content|newString|text|…`) e não o nome da tool.

**Achados de passagem:**
1. O `pre_tool_guard` do plugin `pinga-harness` do Hermes retorna `str`; o núcleo só considera `dict` (`plugins.py:1964-1983`), então o Payload Guard G2 **não bloqueia nada** hoje. [verificado no código; não executei o Hermes]. Fora deste PLAN.
2. `sandbox-run.sh` (PLAN-0007/0018) isola o `done_when` (HOME falso, sem `~/.ssh`, sem `~/.hermes`), **não o runtime do executor/operador**. O processo do Pi/opencode das lanes roda com o HOME real. O guard cobre essa lacuna só na camada de regra.
3. O PLAN-0030 TASK-01 prevê `mask()` de segredos no manda. Os formatos de chave do `deny.json` (`content`) são a lista natural dele; o manda não importa código do ginga (decisão 4 do revamp), então a ligação é por arquivo/CLI, em PLAN futuro.

## 3. Lista de bloqueio única (`deny.json`, versão 1)

Arquivo de dados em `ginga/src/guard/deny.json`; protótipo validado em [ref/ginga/src/guard/deny.json](../../plans/PLAN-0033-guard-de-segredos/ref/ginga/src/guard/deny.json). Cada família abaixo é uma chave do JSON.

### 3.1 Caminhos

| Chave | Conteúdo | Onde vale |
|---|---|---|
| `home_dirs` | `~/.pi`, `~/.hermes`, `~/.config`, `~/.ssh`, `~/.local/share/opencode`, `~/.aws` (lista do dono) **+** `~/.gnupg`, `~/.claude`, `~/.codex`, `~/.gemini`, `~/.docker`, `~/.kube` (acréscimos meus: guardam `auth.json`/credenciais de assinatura) | qualquer lugar; o caminho é resolvido (`~`, `$HOME`, `..`, symlink via `realpath`) |
| `home_files` | `~/.netrc`, `~/.git-credentials`, `~/.npmrc`, `~/.pypirc` | idem |
| `abs_globs` | `/proc/{self,thread-self,PID,*}/environ`, `/etc/shadow`, `/etc/gshadow` | idem |
| `basename_any` | `.env`, `.env.*`, `.envrc` (exceto `basename_allow`: `.env.example|sample|template|dist`) | **em qualquer lugar**, inclusive no projeto |
| `basename_outside_cwd` | `auth.json`, `credentials[.json]`, `*.pem`, `*.key`, `id_rsa|ed25519|ecdsa|dsa[.pub]`, `*.p12`, `*.pfx`, `service-account*.json` | **só fora do `cwd`**: dentro de uma worktree são conteúdo versionado (ex.: `ginga/tests/fixtures` tem `auth.json` de teste) e bloquear travaria TASKs legítimas |

Observação [verificado]: worktrees só têm arquivos versionados, então `.env` real não existe dentro delas; na raiz do workspace (cwd do operador) `find` não achou nenhum `.env`/`.pem`/`.key` hoje. O `.env` que importa está em `~/.hermes/**` e `~/.hermes/profiles/*/`, coberto por `home_dirs`.

### 3.2 Comandos (shell)

O comando é expandido (`~`, `$HOME`) e quebrado em tokens; **todo token que pareça caminho** passa pela mesma regra de §3.1. Isso cobre `cat`, `head`, `tail`, `less`, `rg`, `grep`, `sed`, `awk`, `cp`, `base64`, `xxd`, `tar`, `cd`, `ls` e `curl --data @arquivo` **sem lista de verbos**: o que conta é o caminho citado. (`curl -d @.env`, `--data-binary @$HOME/.ssh/id_ed25519` e `cat .env | curl -d @-` estão em `cases.json`.)

Regras próprias (`shell` no JSON):

| Regra | Barra | Deixa passar |
|---|---|---|
| `env_dump` | `env`, `env \| …`, `printenv [VAR]`, `export -p`, `declare -x/-p`, `typeset -x`, `compgen -e`, `set` **sem argumento**, `env -0` | `env FOO=1 cmd`, `set -e`, `set -euo pipefail` |
| `env_inline` | `python/node/bun/deno/ruby/perl/php` com `-c/-e/-p/--eval` **e** `os.environ`/`process.env`/`getenv`… | `rg "process.env" src/` |

### 3.3 Padrões de conteúdo (`content`)

Aplicados (a) ao **texto de entrada** (`content`, `newString`, `command`…) para barrar quem tenta escrever/enviar uma chave, e (b) ao **resultado da tool** para **redigir** (`[REDACTED:<regra>]`).

| Regra | Padrão (resumo) |
|---|---|
| `key_sk` | `sk-`, `sk-ant-`, `sk-or-v1-`, `sk-proj-` + ≥ 32 caracteres |
| `key_nvapi` | `nvapi-` + ≥ 32 |
| `key_github` | `ghp_/gho_/ghu_/ghs_/ghr_` + ≥ 36; `github_pat_` + ≥ 50 |
| `key_aws` | `AKIA`/`ASIA` + 16 maiúsculas/dígitos |
| `key_jwt` | `eyJ….eyJ….assinatura` |
| `key_google` | `AIza` + 35 |
| `key_slack` | `xox[abprs]-…` |
| `key_discord` | token de bot do Discord (`[MN]…\.…\.…`) |
| `key_pem` | `-----BEGIN … PRIVATE KEY-----` |

Além do formato, `guardResult` redige o **valor exato** de toda variável de ambiente cujo nome casa `KEY|TOKEN|SECRET|PASSWORD|CREDENTIAL` (≥ 12 caracteres). Sem falso positivo e pega chave em formato que a lista não conhece, desde que esteja no ambiente do runtime.

## 4. Desenho

```
lane.sh / dispatch-task.sh / manda run
   │  guard_require (guard ausente ⇒ lane não inicia)
   │  guard_export  ⇒ GINGA_GUARD_LANE, GINGA_GUARD(=enforce), GINGA_GUARD_LOG
   │  guard_pi_args ⇒ -e <ginga>/contrib/guard/pi.ts          (Pi)
   │  guard_opencode_env ⇒ OPENCODE_CONFIG_DIR=…/opencode-config (opencode, --standalone)
   ▼
runtime (Pi | opencode | Hermes)
   tool call ──► adaptador fino ──► guardCall(tool,input) ──► core.checkCall(deny.json)
                     │ bloqueio: reason fixo + regra, sem o trecho
   tool result ─► adaptador ─► guardResult(text) ─► core.redact(deny.json + valores do ambiente)
   eventos: guard.block | guard.redact | guard.error  ─► GINGA_GUARD_LOG (JSONL, sem segredo)
```

Decisões:
- **Escopo por ambiente, não por system prompt.** O `lane:<nome>` que o `lane.sh` põe no system prompt do Pi serve só ao Pi, o modelo o vê e pode repeti-lo, e o `tool_call` não o recebe. Uma variável vale igual nos três runtimes e o modelo não a altera no processo do host. O opencode e o Hermes não tinham marcador; este é um só para todos.
- **Falha fechada** (erro, timeout, `deny.json` ilegível ⇒ bloqueia). A doc do Pi manda gates falharem fechados; o núcleo do Hermes já bloqueia em timeout de `pre_tool_call`. O custo é uma lane parada por bug do guard; o vigia avisa. O PLAN-0032 faz o oposto (fail-open) de propósito: lá um bug custa uma tentativa, aqui custa um segredo num dataset público. **O dono pode vetar.**
- **Modos:** `enforce` (padrão), `shadow` (registra e libera, para calibrar), `off` (só o dono, em `lane.env`).
- **Eventos sem segredo:** `{ts, lane, event, tool, rule, mode, call=sha256[:12] do input}`. O trecho que casou nunca é gravado.
- **Onde cada arquivo fica no repo `ginga` (fonte) e como chega ao runtime:**

| Arquivo (fonte) | Runtime | Projeção / instalação |
|---|---|---|
| `src/guard/{core.ts,deny.json,run.ts,cli.ts,sweep.ts}` | todos | nenhuma: é lido do checkout da main do `ginga` (`GUARD_DIR`) |
| `contrib/guard/pi.ts` | Pi | `pi -e <GUARD_DIR>/contrib/guard/pi.ts`, montado por `guard_pi_args` (sem symlink, sem cópia) |
| `contrib/guard/opencode.ts` + `contrib/guard/opencode-config/plugins/ginga-guard.ts` | opencode | `OPENCODE_CONFIG_DIR=<GUARD_DIR>/contrib/guard/opencode-config`, por `guard_opencode_env` |
| `contrib/guard/hermes/guard_segredos/` | Hermes | symlink `~/.hermes/profiles/<perfil-de-lane>/plugins/guard-segredos` → fonte **+** `plugins.enabled` no `config.yaml`: duas edições em `~/.hermes`, portanto **ação do dono** (ou TASK de infra com OK), nunca do executor |
| `.ginga/bin/guard-env.sh` | lanes | `source` por `lane.sh` e `dispatch-task.sh` |

- **O guard carrega da main do `ginga`**, não de worktree: um executor edita a worktree dele, não o guard em execução. Quem escreve na main é o gate (`MERGE_GATE`, hooks git), e `ginga doctor`/hooks_drift é o lugar natural para acusar adulteração (§7).

## 5. Evidência medida (protótipo em `mktemp`, sem tocar nas chaves reais)

- **Testes RED/GREEN.** [verificado] No repo falso em `$CLAUDE_JOB_DIR/tmp/ginga-mock`: 93 testes TS (62 do core via `cases.json`: 38 de bloqueio, 20 de liberação, 4 de redação + escopo, modos, falha fechada, log sem segredo, CLI, Pi, opencode, sweep) e 9 de Hermes passam. Contra um stub que libera tudo o core dá 41 falhas de 62; sem implementação, todos os arquivos falham no import. A primeira rodada achou bugs meus: o caminho do CLI no plugin Hermes errava um `..` e os testes de bloqueio passavam só porque a falha fechada também "bloqueia" (os testes ficaram mais estritos: um bloqueio real tem que citar a regra, não `guard_error`); e `deny: null` caía no padrão em vez de simular o erro.
- **Falso positivo.** [verificado] Casador aplicado às 1716 tool calls dos 211 `plans/*/runs/*.log` (opencode `--format json`): **3 bloqueios (0,17%)**. Os três são o tipo que queremos barrar: `env | grep …`, um `python -c` lendo `os.environ` e um `find ~/.local/share ~/.config …`. Nenhum quebra o trabalho de TASK (todos eram exploração, não `done_when`).
- **Varredura de vazamento.** [verificado] `sweep` sobre `.ginga/` (1276 arquivos `.log/.md/.json/.jsonl/.tsv/.txt`): **0 ocorrências** de formato de chave. Não prova que nunca vazou (só os formatos da lista), mas nada conhecido está nos logs.
- **Latência.** [verificado] o CLI `bun` responde em ~12 ms por chamada (média de 20 execuções; suíte de Hermes: 9 testes com subprocessos em 0,15 s). Pi e opencode importam o casador em processo.

## 6. O que o guard **não** cobre (e o que cobriria)

| Brecha | Por quê | O que fecha |
|---|---|---|
| Caminho montado em tempo de execução: `cat ~/.p*/agent/au*`, `P=~/.p; cat ${P}i/agent/auth.json`, `eval`, `$(printf …)`, `find ~ -name auth.json -exec cat {} +` | o shell resolve depois do hook; nenhuma regra de string alcança todo `bash` | HOME restrito/sandbox do **processo** (tools sem `~` real), §7 |
| Script escrito e executado pelo próprio modelo (`python x.py` que abre `~/.pi/...`) | o hook vê o `python x.py`, não o que o script faz | idem; ou bloquear `execute_code` no Hermes e vigiar escrita de script que cita caminhos protegidos |
| `/proc/$PPID/environ`, `ps eww`, `strace`, `cat /proc/*/environ` por glob | o pai (o runtime) tem as chaves no ambiente e o filho enxerga o pai (mesmo uid) | **ambiente sem chaves** nos processos de tool (`env -i` + só o necessário) e `bwrap --unshare-pid` |
| Chave em formato que a lista não conhece, partida (`"sk-" + "…"`), em base64 ou hex | redação por padrão e por valor exato do ambiente só pega o que conhece | env sem chaves; ampliar a lista; scan de saída |
| Busca recursiva que lê `.env` dentro do projeto (`rg --hidden KEY .`) | o caminho do alvo é `.`; o `.env` aparece só no resultado | a redação do resultado pega o formato; fora disso, `ripgrep` ignora ocultos por padrão e worktrees não têm `.env` |
| `execute_code`/`browser_*`/MCP/`webfetch` com `file://` | tools fora do mapa de chaves do `input` | negar essas tools em lane, ou estender `PATH_KEYS` por tool |
| Segredo que o próprio runtime manda (credencial do provider em header) | o runtime precisa dela; o hook de tool não enxerga a requisição | scan de `before_provider_request` (Pi) como rede de segurança, §7 |
| Sessão que **não** carregou o guard (opencode sem `--standalone`, Pi sem `-e`, Hermes sem plugin habilitado) | o guard só existe onde é carregado | `guard_require` + teste da fiação + `guard.events` na Fase 2 (sem evento = guard não carregou) |
| Adulteração do guard por quem escreve na main | o guard é código | gate de merge + `ginga doctor` acusando drift de `src/guard` e `contrib/guard` (PLAN futuro) |

Regra prática para a conversa com o dono: **o guard reduz muito o vazamento acidental (o caso `cat .env`/`env`/`auth.json` e a chave que escapa na saída de uma tool); contra um modelo que "tenta" contornar, só isolamento de processo adianta.** Hoje o risco é acidental, mas o `OpenRouter :free` com "publish prompts" ligado faz o custo do acidente ser alto, então vale o guard já e o isolamento depois.

## 7. Follow-ups (fora do PLAN-0033)

1. **Lane com HOME restrito** (o fechamento real da §6): rodar `pi`/`opencode` com `HOME=$RUNDIR/home` contendo só a credencial do provider da vez (como o `sandbox-run.sh` já faz para o `done_when`), ou, no Pi, `createBashTool` com `spawnHook` que embrulha o comando em `bwrap` (exemplos `bash-spawn-hook.ts` e `sandbox/` do Pi). Exige decidir como a credencial chega ao runtime: ação do dono (não gero chave, não copio segredo).
2. **Ambiente mínimo por lane:** `env -i` + só `PATH`, `HOME`, `GINGA_*` e a chave do provider em uso; hoje a lane herda o ambiente do `systemd-run` (`vigia.sh`).
3. **Rede de segurança no provider:** Pi `before_provider_request` varrendo o payload serializado por formato de chave e valor de ambiente; opencode (hook de mensagens do plugin) **[inferência: nome do hook não verificado]**; Hermes `pre_api_request` é observador, sem garantia de poder alterar.
4. **Claude Code como runtime de lane:** `claude --settings <json>` com `PreToolUse` chamando `cli.ts check` (exit 2 bloqueia). Barato, mas o operador `claude/*` está fora de uso.
5. **Drift do guard:** `ginga doctor` conferindo hash de `src/guard/*` e `contrib/guard/*` contra a main (mesmo desenho do `hooks_drift`, PLAN-0024).
6. **Lista de `mask()` do PLAN-0030** passa a ler o mesmo `deny.json` (por arquivo/CLI).
7. **Varredor antes de publicar:** `guard-sweep.sh` (CLI `sweep` + `notify.sh` no Discord) e hook de `pre-push` em `.ginga/hooks/git`. A TASK-08 entrega só o verbo `sweep`; ligar no push mexe nos hooks de merge e pede OK.
8. **Os 3 bloqueios do `env | grep`** mostram que o operador/executor às vezes quer inspecionar o ambiente (`PINGA_EXEC_WRAPPER`). Se virar rotina, oferecer um verbo seguro (`ginga env-check`) em vez de afrouxar `env_dump`.

## 8. O que precisa do OK do dono antes de rodar

| # | Decisão | Recomendação |
|---|---|---|
| 1 | **Aprovar PLAN-0033** (`draft` → `approved`) e a SPEC-0005 | sim |
| 2 | **Falha fechada** (lane para se o guard falhar ou sumir) em vez de fail-open como no PLAN-0032 | fechada |
| 3 | **Acréscimos à lista do dono** (`~/.claude`, `~/.codex`, `~/.gemini`, `~/.gnupg`, `~/.docker`, `~/.kube`, `.npmrc`, `.netrc`, `.git-credentials`) | manter |
| 4 | **Bloquear `~/.config` inteiro** (lista do dono) significa que o executor não lê `~/.config/**` de nada; sem uso legítimo visto nos `runs/` | manter |
| 5 | **Rodar a Fase 2** (prova no runtime real): 1 chamada curta por runtime, com `.env` falso em `mktemp -d` e um modelo free já configurado (Pi/NVIDIA e opencode `glm-free` ou `iceman` só com texto sintético). Manda ~10 tokens sintéticos a um provider; sem custo | autorizar (ou dizer qual modelo) |
| 6 | **Calibração em `shadow` por ~10 TASKs** antes do `enforce` (custa 10 TASKs de proteção parcial) ou `enforce` direto | `enforce` direto nos caminhos e `env`; `shadow` não é necessário dado 0,17% de falso positivo; se o dono preferir cautela, `shadow` |
| 7 | **Hermes:** ativar o plugin num perfil de lane (symlink + `plugins.enabled`, duas edições em `~/.hermes`). Hoje o Hermes não é runtime de lane, então pode esperar | adiar até o Hermes entrar numa lane |
| 8 | **Aplicar a TASK-06 em `lane.sh`/`dispatch-task.sh` com lanes em curso** (editar script em uso). Aplicar na virada de rodada ou com as lanes paradas | quando as lanes estiverem entre rodadas |
| 9 | **Ligar o varredor ao push/PR** (hook git) | depois |
| 10 | **Não mexer em `handoffs/lane.env`:** o padrão é guard ligado; só `GINGA_GUARD=off` desliga, e isso é decisão do dono | ok |

Pré-requisitos de ordem para a TASK-07 (`manda run`): PLAN-0029 (cria `src/runtime/env.ts`) e PLAN-0032 TASK-04 (edita `src/runtime/pi.ts`) mergeados antes.

## 9. Riscos

| Risco | Gravidade | Mitigação |
|---|---|---|
| Falso positivo trava uma TASK legítima (ex.: fixture `auth.json` fora do `cwd`, `rg .env` num repo que lê dotenv) | média | medido 0,17%; `reason` diz a regra; `basename_outside_cwd` poupa fixtures dentro da worktree; ajuste é só edição de `deny.json` por TASK; `shadow` à disposição |
| Falso senso de segurança (dono acha que `enforce` = HOME protegido) | **alta** | §6 e o resumo; item 1 de §7 é o fechamento |
| `OPENCODE_CONFIG_DIR` não carregar o plugin na 2.2.2 | média | Fase 2 confirma antes de `enforce`; plano B isolado em `guard_opencode_env()`; sem evento `guard.*` no log = guard não carregou |
| Plugin do opencode inerte fora do `--standalone` | média | todos os chamadores atuais usam `--standalone`; teste de fiação confere; documentado na TASK-04 |
| Guard falha fechada e para as lanes por bug | média | testes de falha fechada; vigia avisa; `GINGA_GUARD=shadow` temporário por decisão do dono |
| Atraso de ~12 ms por chamada no Hermes (subprocesso) | baixa | Hermes não está em lane; se pesar, cache do `deny.json` num processo residente |
| `log` de eventos crescendo | baixa | só bloqueio/redação, JSONL pequeno; rotação junto dos `handoffs/*.log` |
| Dois PLANs (0032 e 0033) editando `lane.sh`/`pi.ts` do manda | média | TASK-06 e TASK-07 têm `depends_on` e checagem de merge; cada um usa seu `-e` |
| Hermes: `pre_tool_call` é a única parede e o `pinga-harness` G2 está inerte (§2, achado 1) | baixa para este PLAN | achado registrado; TASK própria se o dono quiser |
