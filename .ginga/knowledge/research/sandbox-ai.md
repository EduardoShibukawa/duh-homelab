---
type: research
title: Sandbox para o executor e code mode (INTENT-0006)
timestamp: 2026-10-27
---
# Sandbox para agentes de IA, outbox e code mode

Legenda: **[testado]** rodei aqui; **[fonte]** vem de página aberta ou resultado de busca; **[inferência]** deduzi, não verifiquei.

## 1. Resumo (10 linhas) e recomendação

1. [testado] `bwrap` isola o `opencode run` sem Docker. Montando só `/usr`, o runtime do opencode, o node e um HOME falso, o modelo free respondeu "ok". Boot desprezível (ms).
2. [testado] Dentro da sandbox não existem `~/.hermes`, `~/.codex` nem `~/Projetos`. `/usr` é somente leitura. Só o diretório da worktree e o HOME falso aceitam escrita.
3. [testado] Achado importante: o opencode 2.1 sobe um "managed service" na porta fixa 49374. Com `--share-net` a sandbox enxerga o serviço do host em `127.0.0.1:49374` (respondeu HTTP 200) e o serviço filho da sandbox vaza na rede do host. A rede compartilhada não é isolamento de verdade.
4. Para rede só do provider, o desenho certo é o do Claude Code [fonte]: `--unshare-net` e um proxy com allowlist de domínios fora da sandbox, alcançado por socket Unix montado (socat dentro da sandbox).
5. Para entregar tools: monte runtimes em `--ro-bind` e ponha shims no PATH que falam com um broker no host. Não monte `~/.local/share/mise` inteiro.
6. Para comunicação, o outbox (pasta que o executor escreve e o host valida) é o padrão mais simples e durável para o seu caso. Broker em socket Unix só se precisar de resposta síncrona.
7. Quem commita é sempre o host. Eventos e receipts são escritos pelo host depois de validar o outbox; o executor nunca recebe o ledger.
8. `tests_frozen` vira `--ro-bind` por cima da worktree. Isso fecha na origem o buraco que o gate só corrigia depois.
9. Code mode: há evidência pública de economia grande de tokens com muitas tools, e pequena com poucas. Em modelos pequenos não achei evidência controlada, então meça no seu bench antes de adotar.
10. Docker/gVisor/microVM: desnecessários agora. Firecracker só se um dia houver código de terceiros não confiável.

**Agora, no `dispatch-task.sh`:** trocar `opencode run ...` por um wrapper `sandbox-run.sh` (comando na seção 5) com `--unshare-all`, HOME falso por TASK, `tests_frozen` ro, `.git` oculto, e `OPENCODE` com porta de serviço própria. Fase 1 aceita `--share-net` (explicitando o risco do item 3); fase 2 troca por proxy em socket Unix.
**No manda (runtime port, PLAN-0007/0008):** definir uma porta `Sandbox` (`run(task, mounts, env, netPolicy) -> {exit, outboxDir}`) com adaptadores `bwrap` e `none`, e mover para o manda a validação do outbox e o commit (seção 4). O gate do 0007 passa a assumir que `tests_frozen` já chegou intacto, e o restore vira só defesa em profundidade.

## 2. Comparação de sandboxes

| Opção | Isolamento | Boot | Arquivos / rede / segredos | Homelab |
|---|---|---|---|---|
| bubblewrap | namespaces (mount, pid, net, user); kernel compartilhado | ms [testado] | mounts explícitos, `--unshare-net`, `--clearenv`; segredos = o que você não monta | Ótimo. Já instalado. Base do Claude Code no Linux [fonte] |
| Docker / rootless | namespaces + cgroups + seccomp; kernel compartilhado | ~0,3 a 1 s [inferência] | imagem + volumes + redes docker; fácil, mas exige manter imagem com opencode e runtimes | Bom, mais pesado. Docker (não rootless) dá root ao daemon |
| gVisor | kernel em userspace (syscalls interceptadas); Modal usa [fonte] | ~100 ms a 1 s | via OCI; I/O mais lento | Funciona com `runsc` no Docker; exagero aqui |
| Firecracker / microVM | kernel próprio via KVM; E2B e Docker Sandboxes [fonte] | 150 a 800 ms (números de vendor divergem) [fonte] | disco virtual + rede tap; isolamento mais forte | Precisa KVM e orquestração; só para código hostil |
| nsjail | namespaces + cgroups + seccomp-bpf configurável | ms | config declarativa; mais controle de limites que bwrap | Não instalado; ganho marginal sobre bwrap [inferência] |
| Landlock / seccomp | LSM de arquivos e filtro de syscalls, sem namespace | ~0 | Landlock restringe caminhos; seccomp barra sockets. Codex usa [fonte] | Bom como camada extra; sozinho não esconde arquivos nem cria rede privada |
| `systemd-run --user` com propriedades | cgroup + `ProtectHome`, `InaccessiblePaths`, `PrivateNetwork`, `IPAddressAllow` | ~0 | bom para limites (CPU, memória, tempo) e filtro IP por cgroup | Complemento: use para `MemoryMax`/`RuntimeMaxSec` em volta do bwrap [inferência] |

Harnesses e plataformas [fonte, resultados de busca, não abri tudo]:
- **Claude Code:** `/sandbox` com bubblewrap (Linux) e Seatbelt (macOS); rede por proxy com `allowedDomains` (vazia por padrão); `filesystem.denyRead/allowRead/allowWrite`; `credentials.deny|mask` com injeção da chave real no proxy. Só isola Bash, não Read/Edit/MCP. Por padrão lê quase tudo, inclusive `~/.ssh`. Lição: negar leitura de `~/` explicitamente.
- **Codex CLI:** `read-only` / `workspace-write` / `danger-full-access`; rede desligada por padrão no `workspace-write`; Linux usa Landlock+seccomp e, segundo fontes de terceiros, bwrap em versões recentes (divergência; não confirmei).
- **OpenCode:** não tem sandbox própria; só permissões por ferramenta [inferência, não verifiquei]. Daí a necessidade do bwrap por fora.
- **E2B, Daytona, Modal:** nuvem, microVM ou gVisor, boot de ~100 ms a 1 s por vendor. Inadequados para um homelab que quer manter chaves e repos locais. **Harbor** (dos criadores do Terminal-Bench) roda agentes em Docker local ou em Daytona/Modal/E2B/Runloop/GKE [fonte]. A palestra da Arize usa isso com rede desligada; não consegui abrir o vídeo, então esse detalhe vem do seu INTENT.

## 3. Entregar tools dentro da sandbox

- **Binários e runtimes:** `--ro-bind` do mínimo: `/usr`, `~/.local/share/mise/installs/opencode/<ver>`, `.../node/<ver>`, `.../bun/<ver>`. Não monte `mise` inteiro nem `~/.local/share/opencode` real. [testado: opencode + node bastaram.]
- **Estado do opencode:** HOME falso por TASK (`$RUN/home`), com `.local/share/opencode/opencode.db`, `.cache` e `.config`. O db cresce (14 MB após 2 execuções), então use um HOME descartável e leve o que importar pelo outbox. Modelos free não exigiram `auth.json` [testado]. Para o pago, passar só `OPENCODE_API_KEY`-equivalente via `--setenv` (não verifiquei o nome da variável).
- **Porta do managed service:** configurar porta própria por TASK em `$HOME/.config/opencode/service.json` (`{"port":N}`) [testado: sem isso falha com "port 49374 already in use"]. Alternativa melhor: `--unshare-net`, que esconde o serviço do host e dá uma loopback própria.
- **CLIs selecionadas (pinga, git, gira):** shims em `/shim/bin` no PATH que enviam a chamada por socket Unix montado a um broker no host, o qual executa só verbos da allowlist (`pinga verify`, `git diff`), com cwd fixo na worktree. Sem `.git` dentro: `--ro-bind /dev/null $WT/.git` (a worktree tem `.git` como arquivo) [inferência, não testei]. O executor não precisa de git porque o snapshot e o commit são do host.
- **MCP de dentro para fora:** stdio com processo dentro da sandbox (só se o servidor couber nos mounts) ou socket Unix montado para um MCP do host. O MCP `tuios` do config do usuário não deve existir na sandbox: o HOME falso já o elimina.
- **Rede só do provider:** (a) `--unshare-net` + `socat` ligando um socket Unix a um proxy HTTP CONNECT no host com allowlist (modelo do Claude Code [fonte]); (b) `--unshare-net` + `pasta`/`slirp4netns` + nftables no host por cgroup/IP (não instalados aqui; [inferência]); (c) `systemd-run -p IPAddressDeny=any -p IPAddressAllow=<ips>`, frágil porque IPs de CDN mudam. Recomendo (a). Ressalva: ferramentas que ignoram `HTTP_PROXY` não passam [fonte].

## 4. Comunicação e persistência: outbox

```
 HOST (dispatch/manda)                         SANDBOX (executor)
 ─────────────────────                         ──────────────────
 1 snapshot da árvore
 2 monta: worktree rw, tests_frozen ro,
   $RUN/outbox rw, $RUN/home rw
 3 inicia bwrap ───────────────────────────►  4 edita só a worktree
                                               5 escreve em outbox/:
                                                  learnings.md
                                                  events.jsonl (propostas)
                                                  artifacts/*
                                               6 sai (exit code)
 7 valida o outbox (schema, tamanho, só texto)
 8 pinga verify na worktree (host)  ──► ledger (só o host escreve)
 9 roteia (host escreve):
     learnings.md  ─► .ginga/plans/<plan>/LEARNINGS.md
     events.jsonl  ─► $GINGA_EVENTS (host reescreve campos de identidade: task, run_id, ts, ator)
     artifacts/*   ─► runs/ (copia, nunca executa)
 10 pass ─► host faz git commit; fail ─► restore + log
```
Quem escreve o quê: executor = worktree + `outbox/`; host = LEARNINGS, `$GINGA_EVENTS`, ledger, receipts, commit, log.

- **Forjar eventos e receipts:** o ledger e `$GINGA_EVENTS` não estão montados; o host só aceita do outbox o que passa no schema e reescreve identidade e timestamp. O receipt nasce do `pinga verify` rodado pelo host sobre a árvore resultante, nunca de arquivo enviado pelo executor.
- **Alternativas:** socket Unix com broker de verbos dá resposta síncrona (ex.: "rode `pinga verify` agora"), mas exige daemon, protocolo e tratamento de queda. HTTP local é igual com mais superfície. MCP serve se o próprio modelo precisar chamar a ponte como ferramenta. Para o fluxo atual, onde o host só age no fim da tentativa, o outbox ganha em simplicidade. Híbrido razoável: outbox para dados e um único verbo `verify` por socket.
- **Durabilidade e retomada:** o outbox vive em `$RUN` no host (fora da worktree), com escrita append-only e arquivos numerados. Se o executor cair, o host lê o que existir; a retomada reaproveita o snapshot e o HOME falso (db do opencode guarda a sessão). Cuidado: `$RUN` precisa de cota de tamanho, senão o executor enche o disco [inferência].

## 5. Comando bwrap (testado, com adições marcadas)

Testado com sucesso (modelo free, "responda ok", resposta "ok"), script em `/tmp/claude-1000/-home-shibuka-Projetos-duh-homelab/0bb025c1-089f-4828-98fb-955d026a67de/scratchpad/sb.sh`:

```bash
M=$HOME/.local/share/mise/installs
bwrap --unshare-all --share-net --die-with-parent --new-session \
 --ro-bind /usr /usr --symlink usr/bin /bin --symlink usr/lib /lib --symlink usr/lib /lib64 \
 --ro-bind /etc/resolv.conf /etc/resolv.conf --ro-bind /etc/ssl /etc/ssl \
 --ro-bind /etc/ca-certificates /etc/ca-certificates --ro-bind /etc/passwd /etc/passwd \
 --ro-bind /etc/hosts /etc/hosts --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf \
 --proc /proc --dev /dev --tmpfs /tmp \
 --bind "$WT" "$WT" --bind "$RUN/home" /home/shibuka \
 --ro-bind $M/opencode/2.1.4 $M/opencode/2.1.4 --ro-bind $M/node/26.8.2 $M/node/26.8.2 \
 --chdir "$WT" --clearenv --setenv HOME /home/shibuka --setenv TERM dumb \
 --setenv PATH $M/node/26.8.2/bin:$M/opencode/2.1.4/node_modules/.bin:/usr/bin \
 opencode run -m opencode/glm-5.3-flash-free "responda ok"
```
Mounts necessários, na prática: `/usr` + symlinks, `/etc/{resolv.conf,ssl,ca-certificates,passwd,hosts,nsswitch.conf}`, o diretório de instalação do opencode (o shim em `.bin` aponta para `.mise/@opencode+cli@.../bin/opencode.exe`, tudo dentro dele), o node, e um HOME gravável. `/etc/resolv.conf` pode ser symlink para systemd-resolved; funcionou aqui, mas confira em outras máquinas.
Armadilhas encontradas: (1) ordem dos mounts: o `--bind` do HOME cobre mounts feitos antes dentro de `~`, então monte o HOME primeiro e os installs depois; (2) a porta 49374 do service (acima); (3) `timeout` externo pode ficar pendurado porque o service filho mantém o pipe aberto: use `timeout` dentro da sandbox e `--die-with-parent`.
Verificado dentro da sandbox: sem `~/.hermes`, sem `~/Projetos`, `touch /usr/x` falha (read-only), apenas 6 variáveis de ambiente, internet funcionando (HTTP 200) e, com `--share-net`, também o service do host em 127.0.0.1:49374 (HTTP 200).

Adições propostas, **não testadas**:
```
 --ro-bind "$WT/tests_frozen" "$WT/tests_frozen"   # depois do bind da worktree
 --ro-bind /dev/null "$WT/.git"                    # worktree tem .git como arquivo
 --bind "$RUN/outbox" "$WT/../outbox"              # ou /outbox, fora da worktree
 # fase 2: trocar --share-net por --unshare-net e montar o socket do proxy:
 --ro-bind "$RUN/proxy.sock" /run/proxy.sock       # socat dentro -> HTTPS_PROXY
```
Envolver em `systemd-run --user --scope -p MemoryMax=4G -p RuntimeMaxSec=1800` para limites [inferência].

## 6. Code mode: evidência

- **Palestra da Arize (−43% medido):** não consegui abrir o vídeo; o número vem do INTENT.
- **Anthropic, "Code execution with MCP":** descreve apresentar servidores MCP como APIs de código e filtrar dados no ambiente de execução antes de chegar ao modelo; recomenda sandbox, limites de recurso e monitoramento [fonte, página aparece na busca; o número de 98,7% não confirmei na página]. Simon Willison nota que não há código de referência.
- **Cloudflare Code Mode:** relato de 32% (tarefa simples) a 81% (fluxo complexo) menos tokens (WorkOS); API com 2.500+ endpoints em ~1.000 tokens (InfoQ) [fonte, via busca].
- **Teste independente (AIMultiple):** −78,5% de tokens de entrada (165K vs 771K) com GPT-4.1, mas ~2,2x mais tokens de saída [fonte, via busca]. Números de gateways/vendors (58 a 93%) devem ser lidos com cautela.
- **Programmatic tool calling vs JSON:** em 14 modelos (BFCL v4) iguala ou supera JSON em 11, mas a viabilidade varia por geração de modelo [fonte, resultado de busca de um preprint; não abri].
- **Modelos pequenos:** não achei estudo controlado. Opiniões de praticantes dizem que abaixo de ~32B o formato duplo (raciocinar e gerar código correto) piora [fonte, opinião]. Risco: código com erro silencioso, ou código que lê demais, vira turno extra e anula a economia. Mitigação: começar pelo lado do orquestrador (Claude), não do executor barato, e fazer o A/B do INTENT com FTPR por PLAN.

## 7. Riscos e questões em aberto

- `--share-net` permite alcançar serviços em loopback do host (visto com o service do opencode) e exfiltrar tudo que está na worktree. Só `--unshare-net` + proxy resolve.
- Segredo do provider pago dentro da sandbox pode ser exfiltrado pelo próprio executor. Mitigar com chave de baixo limite (já há teto de US$0,50/2,00) ou com injeção no proxy (modelo `mask` do Claude Code [fonte]).
- bwrap não protege contra bug de kernel. Para executor confiável o suficiente (modelos do Zen), tudo bem; para código de terceiros, microVM.
- O executor ainda enxerga o conteúdo da worktree inteira, incluindo possíveis segredos commitados.
- Em aberto: o opencode funciona com `--unshare-net` + proxy (respeita `HTTPS_PROXY`?). Não testei. O pago funciona sem `auth.json` real? Como o `pinga verify` do host vê arquivos que o executor criou com outro uid (mesmo uid via userns, deve ser ok, não testei)? Qual a cota do outbox e quem limpa `$RUN`?
- Não toquei em worktrees `*-plan-*` nem em `.ginga/plans/`. O teste usou worktree e HOME descartáveis no scratchpad.

## 8. Fontes (links; marcação do que abri)

Abri de fato (WebFetch): https://code.claude.com/docs/en/sandboxing
Vistas só como resultado de busca (não abri a página): 
- https://developers.openai.com/codex/security e https://codex.danielvaughan.com/2026/05/03/codex-cli-sandbox-internals-seatbelt-bubblewrap-landlock-windows-dacl/ (Codex)
- https://www.anthropic.com/engineering/code-execution-with-mcp e https://simonwillison.net/2025/Nov/4/code-execution-with-mcp/ (Anthropic)
- https://workos.com/blog/cloudflare-code-mode-cuts-token-usage-by-81 e https://infoq.com/news/2026/04/cloudflare-code-mode-mcp-server (Cloudflare)
- https://aimultiple.com/code-execution-with-mcp (teste independente)
- https://arxiv.org/pdf/2608.06370 (tool calling programático vs JSON)
- https://blog.logrocket.com/comparing-ai-agent-sandbox-platforms-e2b-modal-daytona-and-more/ (E2B, Modal, Daytona)
- https://infoq.com/news/2026/10/ai-agents-harbor-docker e https://www.langchain.com/blog/evaluating-deepagents-cli-on-terminal-bench-2-0 (Harbor)
Palestra Arize (https://www.youtube.com/watch?v=dAoOYFx7ZYw): não consegui abrir.

---

## 6. Validação no host real (2026-10-27, 21:xx -03) — a fase 1 NÃO roda

Medido com `.ginga/bin/sandbox-run.sh` (fase 1, `--share-net`, fail-closed 97):

**O que está provado (isolamento de filesystem):**
- `~/.hermes`, `~/.ssh`, `~/.codex` **ausentes** dentro da sandbox.
- `$HOME` falso contém só `.cache .config .local Projetos`; `/home/shibuka/Projetos` mostra **apenas a worktree montada**.
- `/usr` read-only (escrita falha), testes congelados read-only, `.git` mascarado (`git status` falha).

**O que está provado (exposição):**
- `curl http://127.0.0.1:49374/` → **HTTP 200** de dentro da sandbox. O serviço é o do host
  (pid 23206, `opencode.exe serve`, 4d de uptime), loopback — não escuta em LAN.

**O que está quebrado (opencode não executa na sandbox):**
1. Sem `service.json`: `Error: Failed to start server. Is port 49374 in use?` (rc 1, ~20 s).
   O CLI **não** descobre o serviço por arquivo: calcula a porta pelo canal do build
   — `latest`→49374, `local`→49375, senão `10000+hash(canal)`. Com backlog falso não encontra
   serviço, tenta subir o próprio e colide com o do host.
2. Montando `~/.config/opencode/service.json` (só senha): mesma colisão.
3. Montando o *runtime* `~/.local/state/opencode/service.json`: conecta e **trava 90 s sem saída**.
4. `opencode serve --port P` + `opencode run --server http://127.0.0.1:P` com `OPENCODE_PASSWORD`:
   servidor sobe em 2 s (health 200) mas o `run` **trava 120 s**; no **host, sem bwrap**, o mesmo
   caminho trava 60 s → o defeito é do modo `--server`, não da sandbox.

**Fase 2 também não é implementável como escrita:** `pasta` e `slirp4netns` **não existem** no host.
Sem netns com NAT não há rota para a API do Zen sob `--unshare-net`, e `HTTPS_PROXY` não atravessa
unix socket. Fase 2 exige instalar um desses (ou equivalente).

**Consequência de governança:** ligar a fase 1 no `dispatch-task.sh` hoje faz **toda TASK falhar**
com `Failed to start server` (rc 1). Não é ganho parcial, é queda de pipeline.

**Achado colateral (produção):** todos os dispatches compartilham o **único** serviço da 49374
(pid 23206) — inclusive `opencode session export`, que o `dispatch-task.sh` usa para medir custo.
É um ponto único de falha para concorrência e contabilização.

**Caminhos para destravar (ordem de custo):**
- **A. Sandbox onde ele já funciona:** aplicar `sandbox-run.sh` nos *gates* (`pinga verify`, suíte de
  testes, scripts), que não usam opencode. Isolamento de FS provado, zero dependência do serviço.
- **B. Serviço dentro da sandbox:** rodar `opencode serve` *dentro* do bwrap em porta própria
  (canal `local` → 49375, ou hash por run) para que a execução de ferramentas aconteça contida.
  Requer resolver o modo `--server` (hoje travado) ou fixar o canal.
- **C. Fase 2 de verdade:** instalar `slirp4netns`/`pasta` e dar NAT à netns; proxy só se o cliente
  honrar `HTTPS_PROXY`.

## 7. Como a comunidade resolve (GitHub)

Pesquisa de 2026-10-27. [fonte] = li no repositório, na issue, na API do GitHub (`gh api`) ou rodei aqui; [inferência] = conclusão minha. Onde a licença está em branco, a API não detectou licença: sem licença explícita não vale como OSI (DECISION-0003).

### 7.1 Tabela

| Projeto | Licença | Mecanismo | Arquivos / mounts | Rede | Segredos | Agentes | Atividade |
|---|---|---|---|---|---|---|---|
| [anthropics/claude-code `.devcontainer`](https://github.com/anthropics/claude-code/tree/main/.devcontainer) | (repo proprietário; ver LICENSE, não confirmei OSI) | devcontainer + Dockerfile | `Dockerfile`, `devcontainer.json`, `init-firewall.sh` [fonte] | iptables + ipset com allowlist: GitHub (api.github.com/meta), npm, api.anthropic.com, sentry, statsig, domínios do VS Code, /24 do gateway; política DROP, teste de que example.com é bloqueado [fonte] | tokens no env do container | Claude Code | oficial, ativo |
| [anthropic-experimental/sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime) (`srt`, base do `/sandbox`) | Apache-2.0 [fonte, API] | bwrap (Linux), sandbox-exec (macOS) + proxy de domínios fora da sandbox | cwd gravável; leitura ampla com deny-list | `--unshare-net` + proxy HTTP/SOCKS por socket Unix com allowlist de domínios | env | Qualquer comando (Claude Code, opencode) | push 2026-10-27, 6,7k estrelas [fonte] |
| [akitaonrails/ai-jail](https://github.com/akitaonrails/ai-jail) | GPL-3.0 (OSI) [fonte] | bwrap + Landlock + seccomp + rlimits | projeto rw; HOME tmpfs novo; dirs de estado do agente rw (desligável com `--no-agent-state`); `--map` ro, `--rw-map` rw; `/tmp` descartado | desligada por padrão; `--allow-host` = proxy CONNECT só para hosts listados; `--forward-port` | env em allowlist mínima; `--env-from-file`; `--secret KEY=host` injeta a chave no proxy, fora da sandbox; `--mask` para `.env` | claude, codex, gemini, grok, devin, agy; opencode só em troubleshooting [fonte] | 563 commits, 1,4k estrelas, push 2026-10-28 |
| [always-further/nono](https://github.com/always-further/nono) | Apache-2.0 [fonte, API] | Landlock (Linux) / Seatbelt (macOS), perfis por agente | perfis declarativos | por perfil | perfis | há perfil de opencode (`nono-opencode-tinfoil`, outro repo, li só o snippet) | 4,7k estrelas, push 2026-10-27 |
| [numtide/claudebox](https://github.com/numtide/claudebox) | sem licença detectada | bwrap via Nix | n/d | n/d | n/d | Claude Code | push 2026-10-13; um usuário relatou que não subiu (Discourse NixOS) |
| [ribomo/opencode-sandbox](https://github.com/ribomo/opencode-sandbox) | sem licença na página | bwrap, script Bash | cwd rw; `/usr`, `/etc`, `/run` ro; config do opencode ro; **`~/.local/share/opencode` rw** (credenciais e sessões) | **compartilhada** | chaves SSH nunca montadas; ssh-agent temporário | opencode | 19 commits, 0 estrelas, push 2026-09-27 |
| [dontdrinkandroot/opencode-bubblewrap](https://github.com/dontdrinkandroot/opencode-bubblewrap) | sem licença detectada | bwrap, para ACP em IDE JetBrains | avisa: lançar em `$HOME` monta tudo rw | n/d | n/d | opencode | push 2026-08-04 |
| [gstamp/jail](https://github.com/gstamp/jail) | MIT [fonte] | docker, script | projeto em `/workspace` rw; `~/.config/opencode` e `~/.local/share/opencode` rw; `.gitconfig` ro; permissões liberadas via `OPENCODE_CONFIG` | sem restrição | repassa `OPENROUTER_API_KEY` etc. | opencode | 21 commits, parado desde 2026-01 |
| [ruifm/aibox](https://github.com/ruifm/aibox) | MIT [fonte, API] | bwrap, "segurança contra acidente" | n/d | total | n/d | vários | push 2026-09-29, 1 estrela |
| [CaptainMcCrank/SandboxedClaudeCode](https://github.com/CaptainMcCrank/SandboxedClaudeCode) | sem licença detectada | bwrap, firejail, Apple Container (scripts) | n/d | n/d | n/d | Claude Code | 60 estrelas, push 2026-03 |

Não abri o código de ribomo, dontdrinkandroot, claudebox, aibox e SandboxedClaudeCode; as colunas deles vêm do README/snippet de busca.

### 7.2 O que a comunidade faz de comum [inferência a partir da tabela]

- Quase todos montam o **projeto rw, `/usr` ro e um HOME novo**. É o que o nosso `sandbox-run.sh` já faz.
- Para opencode, **ninguém isola rede de verdade**: ribomo e jail deixam a rede aberta e ainda montam `~/.local/share/opencode` rw (credenciais e sessões). Nosso desenho é mais restritivo.
- Rede restrita só aparece em três formas: iptables+ipset num container (Anthropic), proxy de domínios fora da sandbox (srt, ai-jail), ou perfil Landlock (nono). Nenhuma exige `slirp4netns` porque o proxy fica no lado do host.
- Segredo bom é o do ai-jail: `--secret KEY=host` mantém a chave **fora** da sandbox e o proxy a injeta. Isso é melhor que montar `auth.json`.

### 7.3 O que dá para copiar e o que não serve

Copiar:
- **Proxy com allowlist e injeção de chave** (ideia do ai-jail e do srt) para a fase 2: `--unshare-net` e socket Unix para um proxy no host. Resolve a falta de `pasta`/`slirp4netns`. Código GPL (ai-jail) e Apache (srt): usar `srt` como dependência ou reimplementar o desenho, sem copiar código GPL.
- **Lista de domínios do devcontainer da Anthropic** como ponto de partida para o operador Claude (api.anthropic.com, npm, GitHub). Para o executor, a lista é só o host do Zen/provider.
- **HOME tmpfs + dirs de estado do agente explícitos** (ai-jail), com opção de não montar estado.
- **`--mask` de `.env`** na worktree.

Não serve:
- **Devcontainer/Docker**: o usuário não acessa o socket do docker. Além disso, ai-jail avisa que quem tem docker contorna o bwrap.
- **Wrappers opencode (ribomo, jail, dontdrinkandroot)**: rede aberta, estado rw, sem licença (exceto jail, MIT, mas parado). Nenhum trata o serviço gerenciado.
- **`/sandbox` nativo do Claude Code** para o operador: cobre só o Bash (seção 2). Para isolar a sessão inteira, usar `srt` ou ai-jail em volta do `claude`.

### 7.4 opencode: o que as issues dizem

- [fonte] A porta 49374 fixa e o serviço único por usuário são problema conhecido e aberto em `anomalyco/opencode`: #50672 (porta global trava segundo cliente), #41696 e #52234 (TUI trava sem mostrar o erro real), #54267 (cliente acha que não há serviço e sobe outro na mesma porta), #56708 (outro `XDG_STATE_HOME` quebra a descoberta e dá conflito de porta), #58141 (serviço singleton; o env da primeira execução vale para todos os perfis).
- [fonte] Um mantenedor-bot confirma em #58141 que o desenho v2 é "um servidor compartilhado por conta, dono de config, integrações e credenciais", e que o primeiro env vence. Isso explica por que a chave injetada por wrapper é ignorada.
- [fonte] Não achei ninguém rodando opencode em bwrap/container com sucesso e resolvendo isso nas issues; os wrappers só ignoram o problema (provavelmente porque o serviço do host fica visível pela rede compartilhada) [inferência].
- **[fonte, testado aqui] O CLI já tem a saída: `opencode run --standalone`** ("Run with a private server instead of the background service"; `--print-logs` mostra logs de servidor só com ele). Em `opencode --help` 2.1. Medi:
  - no host: `opencode run --standalone "responda apenas: ok"` → `ok` em 4,7 s;
  - dentro do `.ginga/bin/sandbox-run.sh` atual (fase 1): mesmo comando → `ok`, rc 0, 3,6 s, sem tocar a 49374.
  - A seção 6 testou `opencode serve` + `run --server` (que trava) e nunca `--standalone`. Daí o beco sem saída.

### 7.5 Recomendação concreta

1. **Destravar já:** em `dispatch-task.sh`/`sandbox-run.sh`, trocar `opencode run ...` por `opencode run --standalone ...`. Remover `--server`, `serve` e qualquer montagem de `service.json`. O serviço do host deixa de ser relevante para a execução, e a colisão de porta some porque o servidor privado usa porta efêmera [inferência: não confirmei que é efêmera; verificar com `ss -tlnp` durante um run].
2. **Antes de ligar no pipeline**, validar numa TASK real (tool calls, escrita na worktree, `--auto` para permissões) e conferir que a chave do provider chega pelo env/auth do HOME falso, sem montar `~/.local/share/opencode` inteiro.
3. **Fase 2 (rede):** `--unshare-net` + proxy de domínios no host por socket Unix, via `srt` (Apache-2.0) ou desenho equivalente. Ressalva: o cliente do opencode precisa honrar `HTTPS_PROXY` por um ponte `socat` dentro da sandbox; testar. Se não honrar, ficar na fase 1 com `--standalone` e `--share-net` já é um ganho real: o executor não alcança mais o serviço do host como cliente, embora o loopback ainda esteja visível.
4. **Operador Claude:** rodar `claude` sob `srt` ou ai-jail (GPL, usar como ferramenta, não como biblioteca) com projeto rw, `~/.claude` mínimo e allowlist de domínios do devcontainer. Em alternativa, `/sandbox` nativo + deny-list, sabendo que só cobre Bash.
