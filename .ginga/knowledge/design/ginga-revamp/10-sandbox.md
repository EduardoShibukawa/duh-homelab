# 10 — Sandbox de execução isolada

Origem: [INTENT-0006](../../../intents/INTENT-0006-sandbox-e-code-mode.md), [sandbox-ai.md](../../research/sandbox-ai.md), [PLAN-0018](../../../plans/PLAN-0018-sandbox-done-when/PLAN.md). Complementa [02 §2 Portas](02-visao-atualizada.md#2-portas-e-adapters).

## 1. Fase 1 (feita): `sandbox-done-when.sh`

Arquivo: `.ginga/bin/sandbox-done-when.sh`. Wrapper do `done_when` do pinga (opção A aprovada pelo dono). Uso: `PINGA_EXEC_WRAPPER=.ginga/bin/sandbox-done-when.sh pinga verify ...`.

Características:
- `bwrap` com `--unshare-all --die-with-parent --new-session`, `/usr` e `/etc` mínimos somente leitura, bun do mise somente leitura, `ROOT` gravável, `.git` comum somente leitura, HOME falso vazio.
- `--unshare-net`: sem rede. O `done_when` não tem por que sair para a rede.
- Identidade git por variável (`GIT_AUTHOR_NAME`/`EMAIL`), sem `~/.gitconfig`.
- Fail-closed: sem bwrap, sem bun ou preflight falhando → exit 97 (o pinga grava `blocked/infra`).
- Repassa só variáveis de contrato (`PINGA_LEDGER`, `GINGA_EVENTS`, `CI`), nunca chaves de provider.

Isolamento de filesystem provado: `~/.hermes`, `~/.ssh`, `~/.codex` ausentes; `/usr` read-only; testes congelados read-only; `.git` mascarado.

## 2. Problemas reais observados por causa do isolamento

1. **Testes do p-inga que leem `~/.hermes` e o estado real** (T26, W12): falharam dentro da sandbox. Viraram TASK-03 do PLAN-0018 (isolar com HOME falso ou declarar `needs:` no perfil).
2. **Git sem identidade** quebrou commits dos testes do manda: resolvido por variável de ambiente no wrapper (acima).
3. **Serviço compartilhado do opencode na porta 49374** travou os clientes: o CLI do opencode sobe um "managed service" singleton. Compartilhar a netns expõe o serviço do host. Resolvido pelo `--standalone` (servidor privado, porta efêmera) — achado da pesquisa de 2026-10-27.
4. **O executor precisa alcançar o endpoint do provider**: com `--unshare-net` não há rota. Fase 1 usa `--share-net` para o executor (sandbox-run.sh), aceitando o risco do item 3.
5. **Modelos free só funcionam no opencode**: `*-free` do Zen dão 429 `FreeUsageLimitError` fora do opencode (Pi, manda adapter `pi`). Por isso o executor roda via `opencode run --standalone`, não via Pi.

## 3. A questão do dono: "devemos dar uma opção de networking ou pensar melhor?"

O dono pergunta se devemos oferecer uma opção de networking ou repensar. Análise das opções:

| Opção | Como | Prós | Contras | Quando usar |
|---|---|---|---|---|
| `net: none` | `--unshare-net`, sem rota | Isolamento real; padrão do `done_when` | O executor não alcança o provider; inútil para rodar modelo | **Padrão para gates e testes** (done_when, suíte) |
| `net: allowlist[domínios]` | `--unshare-net` + proxy HTTP CONNECT/SOCKS no host por socket Unix (modelo do Claude Code/srt/ai-jail) | Isolamento real + acesso só aos hosts do provider | Depende de o cliente honrar `HTTPS_PROXY`; precisa implementar/instalar proxy (`srt` Apache-2.0 ou desenho equivalente) | **Padrão para o executor** quando a fase 2 estiver pronta |
| `net: host` | `--share-net` | Simples; o executor funciona hoje | Loopback do host visível (serviço 49374); exfiltração possível; não é isolamento de verdade | **Só debug** / fase 1 provisória |
| Equivalente do `--network` do Docker | `--share-net` + filtro por IP/cgroup (`systemd-run IPAddressAllow`) | Familiar | IPs de CDN mudam; frágil | Não recomendado |

Recomendação: **não oferecer `net: host` como opção de produção**. O padrão para o executor deve ser `net: allowlist` (fase 2) e, até lá, `net: none` + `--standalone` não resolve a rede — por isso a fase 1 do executor usa `--share-net` de forma explícita e temporária, com aviso. A opção de networking "sim/não" do dono vira um **perfil declarativo** (`net: none | allowlist[...] | host-debug`), onde `host` é proibido em produção e só existe para debug.

Nota: `pasta` e `slirp4netns` não estão instalados no host. A fase 2 não precisa deles: o proxy fica no lado do host e atravessa por socket Unix. `srt` (Apache-2.0) ou desenho equivalente resolve.

## 4. Porta `Sandbox` (separada da porta de runtime)

INTENT-0006: `sandbox.run(profile, cmd, worktree) → {exit, outbox}`. Vale para qualquer runtime (Pi, Codex, OpenCode, AGY, Claude). Adapters: `bwrap` e `none`.

Perfil declarativo por runtime e por papel (INTENT-0006, INTENT-0008 `needs:`):

```toml
# .ginga/project.toml
[sandbox.opencode]
mounts = ["/usr", "mise/opencode", "mise/node"]
env = ["OPENCODE_API_KEY"]   # injetado, não montado
net = "allowlist[api.opencode.ai]"
needs = ["bun", "git-ro"]

[sandbox.claude]
mounts = ["~/.claude:minimal"]
net = "allowlist[api.anthropic.com, npm, github]"
```

Campos: `mounts`, `env`, `net`, `needs` (INTENT-0008), `flags`.

Particularidades por runtime (INTENT-0006):
- opencode: `--standalone` obrigatório (serviço compartilhado na 49374).
- claude: credencial em `~/.claude`, domínios da Anthropic; tem sandbox nativa.
- codex: tem sandbox nativa.
- agy: login Google, possível daemon.
- pi: config própria.

Sandbox dupla: claude e codex já têm sandbox própria. Bwrap dentro de bwrap pode falhar por user namespace aninhado. Decisão por runtime: nossa sandbox como fronteira externa e a nativa relaxada, ou o contrário (a verificar).

## 5. Matriz de validação e fail-closed

Matriz runtime × {responde "ok"; escreve na worktree; não lê `~/.ssh` nem `~/.hermes`; não alcança a 49374 nem a LAN}. Esse é o critério de "runtime suportado em sandbox".

Fail-closed: se o wrapper está configurado mas não existe/não é executável, o `done_when` não roda; se o wrapper sai com 97, o receipt fica `blocked` com `reason_code: infra`, nunca `pass` nem `fail`. O executor nunca cai para execução nua.

## 6. O que fica para a fase 2

- `--unshare-net` + proxy com allowlist de domínios para o executor (rede real isolada).
- Injeção de chave no proxy (modelo `mask` do ai-jail/srt), para o segredo não entrar na sandbox.
- `--mask` de `.env` na worktree.
- Limites de CPU/memória/tempo via `systemd-run` em volta do bwrap.
- Resolução da sandbox dupla para claude/codex.
- Validação da matriz completa para todos os runtimes (hoje só opencode foi testado).
- Outbox: validação, roteamento e commit pelo host (04 da sandbox-ai.md) — hoje o executor escreve direto na worktree.
path: .ginga/knowledge/design/ginga-revamp/10-sandbox.md