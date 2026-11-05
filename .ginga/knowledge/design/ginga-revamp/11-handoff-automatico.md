---
type: design
title: Handoff automático (cache expirando ou contexto grande → sessão nova)
status: proposta
date: 2026-10-29
---

# 11 — Handoff automático

> Origem: ideia do dono ([cobertura da visão, decisões](../../research/cobertura-visao-02-2026-10-29.md)), números em [eficiência das conversas](../../research/eficiencia-conversas-dono-2026-10-29.md). Estende o [06 §4](06-handoff-e-learnings.md) (o handoff determinístico) com **gatilho automático e abertura da sessão nova**; emenda o PLAN-0013.

## 0. Ideia e por que compensa

Um mod percebe que a conversa ficou cara (cache frio ou contexto grande), gera o handoff e **redireciona** a conversa para uma sessão nova. Números do dono–Claude (26–29/10): contexto mediano 150–185k por chamada (US$ 0,045–0,073 cada), 10 recargas de cache frio ≈ US$ 11, retomar fork de 250k ≈ US$ 1,25 contra ~US$ 0,2 para começar limpo. Meta: parte dos US$ 15–25 da recomendação 3 do estudo.

**Princípio:** nada de timer nem de vigia. Os gatilhos são avaliados nos eventos que já existem (fim de turno e envio de prompt). O handoff em si é grátis (arquivos + git); a sessão nova só é aberta quando o dono volta, porque abrir antes paga cache write à toa.

## 1. Gatilhos

Configuração em `project.toml` (validada pelo `ginga lint`):

```toml
[handoff]
mode = "suggest"          # off | suggest (avisa, dono decide) | auto (redireciona)
idle_min = 55             # = TTL do cache (60 min nesta conta) − margem de 5
context_tokens = 110000   # limiar de contexto (faixa 100–120k)
min_context_tokens = 30000  # abaixo disso não vale (a sessão nova já nasce com ~40k)
cooldown_min = 30         # anti-loop (§4)
max_chain = 3             # cadeia máxima de handoffs sem o dono pedir
summary = "off"           # off | same_provider | <rota do ROUTING> (§2)
[handoff.opencode]        # override por runtime; cache_ttl vem de models/PROVIDER-*.md
idle_min = 0              # 0 = desliga o gatilho de ociosidade (provider sem cache)
```

| Gatilho | Regra (avaliada em…) | Ação |
|---|---|---|
| `idle` | ao **receber um prompt**: `agora − timestamp da última chamada à API > idle_min` **e** contexto ≥ `min_context_tokens` | cache frio: continuar custaria `contexto × write`; redireciona |
| `context` | no **fim do turno**: contexto ≥ `context_tokens` | prepara o handoff, avisa; redireciona no próximo prompt |
| `boundary` | TASK fechou ou PLAN mudou de fase (já no 06) | só grava o handoff, não redireciona |
| `manual` | `/handoff` (skill) ou `ginga handoff --open` | gera e abre na hora |

- "Ociosidade" é desde a **última chamada à API**, não o relógio da conversa: cada leitura renova o cache.
- Com cache quente e contexto < limiar, nada acontece: uma chamada a 150k quente custa ~US$ 0,03 (leitura), e o trigger de contexto existe pelo acúmulo (100 chamadas × 180k ≈ US$ 3,6), não por um turno.
- Só sessões **interativas** do dono. Fora: `claude -p`/`pi -p`/`opencode run`/`codex exec`, subagentes e lanes do manda (já são "um processo = uma tentativa").
- A decisão é uma função pura, `decideHandoff(cfg, estado) → {action, trigger, reason}`, uma só para todos os runtimes (§3).

## 2. Núcleo agnóstico: `ginga handoff`

Já planejado na TASK-03 (por PLAN, `trigger: boundary`). Aqui ganha o modo **sessão**:

```
ginga handoff [<PLAN>] --trigger idle|context|manual|boundary --runtime claude|opencode|pi|codex|agy
              [--from-session <id>] [--transcript <path>] [--notes <arquivo>|-] [--open] [--json]
```

Sem `<PLAN>`: infere o PLAN ativo (worktree/branch, `state.db`, `log.md` mais recente); sem PLAN nenhum, cai em `git status` + `index.md` "Pendências agora" + últimos eventos. **Zero LLM**; mesma entrada = mesmos bytes.

Formato (`.ginga/handoffs/HANDOFF-<data>-<PLAN|sessao>.md`, `type: handoff`, ≤ ~4k tokens, truncado por prioridade na ordem abaixo):

| # | Seção | Fonte |
|---|---|---|
| fm | `plan`, `trigger`, `runtime`, `from_session`, `transcript`, `parent_handoff`, `depth`, `handoff_tokens` | args + eventos |
| 1 | Objetivo e SPEC | PLAN |
| 2 | TASKs com estado e última tentativa | `state.db`, `pinga queue --json` |
| 3 | Learnings (`descartada`/`armadilha` primeiro) | `LEARNINGS.md` |
| 4 | **Próximo passo** (uma TASK aberta) e blockers/perguntas ao dono | PLAN, Inbox |
| 5 | Working tree | `git status --short`, `git diff --stat` dos `repos` |
| 6 | **Do chat** (opcional) | `--notes` |
| 7 | **Como retomar**: prompt de abertura de ≤ 15 linhas e caminho do `transcript` | gerado |

**Seção "Do chat" (o que só está na conversa):** decisões do dono, preferências, hipóteses em curso, coisas prometidas. Ordem de preferência, da melhor/mais barata para a pior:

1. **O próprio modelo, com cache quente** (`context` e `manual`): a skill (§3) manda ele escrever `notes` antes do corte. Um turno extra a preço de leitura (~US$ 0,03 + ~1k de saída) e com o melhor conhecimento do que importa. O hook de fim de turno só pede isso, sem LLM próprio.
2. **Resumo barato do texto da conversa** (`idle`, cache frio): o adapter extrai só as falas do dono e as respostas finais do assistente (sem `tool_result`, ~algumas k) e manda a um modelo barato (`summary`), ~US$ 0,01–0,03. **Padrão `off`**: com `same_provider` os dados já estão com o provedor; outra rota (ex. Zen free) é dado a terceiro e exige aprovação do dono.
3. **Nada**: o `transcript` fica referenciado no handoff e a sessão nova pode dar `rg` nele sob demanda.

Vale o resumo LLM quando há **decisão sem rastro em arquivo**: ≥ 3 turnos do dono desde o último `Write/Edit` em `.ginga/` ou `LEARNINGS.md` (heurística determinística sobre o transcript). Sessão de operação ("ok/bora/foi?") não precisa.

## 3. Adapters por runtime

Cada adapter é fino (≤ ~50 linhas): coleta `{lastApiTs, contextTokens, sessionId, transcript, interactive}`, chama `ginga handoff hook --runtime <r>` (que roda `decideHandoff`, gera o arquivo e devolve a ação) e executa a ação no formato do runtime.

| Runtime | Detecção (contexto / cache) | Geração e redirecionamento | Abertura da sessão nova | Limitações |
|---|---|---|---|---|
| **Claude Code 2.1.312** | **Mod** (`claude-code`): `session.measure` (push de `context.tokens/percent`, `rateLimits`, `cost`), `$.session.usage()`, `turn.complete`, `prompt.submit`. **Sem mod**: hooks de settings `Stop` + `UserPromptSubmit` (stdin com `session_id`, `transcript_path`) e `usage` da última mensagem no transcript (`input + cache_read + cache_creation`); `statusLine` também recebe `context_window` e `rate_limits` por stdin (schema exato a confirmar) | `prompt.submit` / `UserPromptSubmit`: `ginga handoff hook`; no `redirect` bloqueia o prompt (`{deny}` / `decision: block`) com a mensagem "sessão nova `<id>`: `claude attach <id>`". No `context`, o `Stop` pede o turno extra (§2.1) | `claude --bg -n "handoff:<plano>" --model <ROUTING> "<prompt de abertura + pedido original do dono>"` imprime o id; `claude attach/logs/stop`, `claude agents --json` lista. **Não** usar `--resume`/`--fork-session` (reescreve o cache) | `--bg` é sem TTY: o dono entra com `attach`. `--autocompact <100k–1M>` serve de rede de segurança se o mod não carregar (compactação continua caixa-preta). O mod exige o "Turn on the mods" do dono; o caminho por hooks funciona sempre |
| **opencode 2.2.2** | Plugin TS em `~/.config/opencode/plugins/` (já há `tuios-agent-state` e `pi-harness.ts`). Eventos `message.updated` (assistente: `modelID`, `cost`; `tokens{input,output,cache{read,write}}` a confirmar no SDK), `session.idle`/`session.status`, `chat.message` | `chat.message` decide como o `prompt.submit`; `experimental.session.compacting` pode injetar o handoff no auto-compact como plano B | `client.session.create()` + `session.prompt()` pelo SDK do plugin, ou `opencode run -s <id> "<prompt>"`; o dono entra com `opencode -s <id>` | Sem cache em vários providers (Zen free, Go): `idle_min=0`, vale só o gatilho de contexto. Free só roda no opencode (regra de rota) |
| **Pi 1.4.0** | Extensão (`pi.on`): `turn_end`, `before_agent_start`, `session_start`, `session_shutdown`; `pi.registerCommand("handoff")`. Contexto: usage por mensagem no JSONL de `~/.pi/agent/sessions/--<cwd>--/*.jsonl` (campo a confirmar); `ctx.ui.setStatus` para o aviso | `before_agent_start` (próximo prompt) chama `ginga handoff hook`. Base já existe: `task_checkpoint`/`task_resume` do pi-harness (`buildResumeBriefing`) | `pi --name "handoff:<plano>" "@HANDOFF.md <pedido>"` em painel novo (tuios); `--session-id`/`--fork` não servem | Janelas e modelos baratos: contexto é o gatilho principal. Se a API de extensão não abrir sessão sozinha, só imprime o comando |
| **Codex 0.165** | `~/.codex/hooks.json` já tem `SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop, SessionEnd` (feature `hooks = true`): mesmo caminho dos hooks do Claude. Tokens: rollout JSONL em `~/.codex/sessions` | `UserPromptSubmit` → `ginga handoff hook` | `codex "<prompt>"` em painel novo; `codex exec` se headless | Só judge, sem cota até 25/11: **prioridade baixa**, fora do MVP |
| **AGY / Hermes** | Sem hooks conhecidos | Wrapper: `ginga handoff --runtime agy --open` imprime o prompt de abertura | Manual | Só gatilho `manual` |

**Skill única:** `.ginga/skills/handoff/` (`SKILL.md` com `name`/`description`, `scripts/handoff.ts` que chama a CLI e imprime JSON, `references/formato.md`). O `ginga install` projeta para `.claude/skills`, opencode e Pi como qualquer skill do [SPEC-0002](../../../specs/SPEC-0002-skills-e-hooks.md) (dry-run por padrão, idempotente, mount ro na sandbox). A skill instrui o modelo a (1) escrever `notes` com decisões/preferências/hipóteses, (2) rodar `ginga handoff --open`, (3) encerrar o turno. Vira o slash `/handoff` e é o que o `Stop` aciona no gatilho `context`. O mod/plugin/extensão entra como **hook do host** (conveniência, não gate de segurança), também projetado pelo `ginga install`.

## 4. Riscos e mitigação

| Risco | Mitigação |
|---|---|
| **Perder decisões que só estavam no chat** | Seção "Do chat" escrita pelo próprio modelo (§2.1); `transcript` referenciado para `rg` sob demanda; sessão antiga nunca é apagada (`claude --resume` continua); regra do 06 "gravou um check, escreveu o learning"; métrica "tokens de redescoberta" nos primeiros turnos (A/B do PLAN-0014) |
| **Loop de handoff** (sessão nova já nasce grande ou ociosa) | `min_context_tokens` e `context_tokens` medidos **desde o início da sessão nova** (ela nasce com ~45k, longe de 110k); `cooldown_min`; `depth`/`max_chain` no frontmatter e em `GINGA_HANDOFF_DEPTH` (acima de 3 exige o dono); um redirect por sessão antiga (`state/handoff-<session>.json`); sessões `-p`/subagentes nunca disparam |
| **Redirecionar quando o dono queria continuar** | `mode = "suggest"` por padrão na primeira semana (só avisa e deixa o handoff pronto); prefixo `!!` no prompt ignora o gatilho; toda decisão vira evento `handoff` com `trigger`, `saved_usd` estimado e vira métrica |
| **Privacidade** | O handoff só tem o que já está em arquivos do workspace e `git`; passa por filtro de segredos (padrões de chave/token e `.env`) antes de gravar; o transcript **nunca** é copiado inteiro; resumo por modelo fora do provedor atual só com aprovação do dono (`summary = "off"` por padrão); Discord recebe só o caminho |
| **Medir errado o TTL** (relógio, `--bg`, cache de 5 min em outro provider) | `cache_ttl` por provider em `models/PROVIDER-*.md`; margem de 5 min; sem `cache_ttl` conhecido o gatilho `idle` fica desligado |
| **Mod não carrega** (o dono não habilitou) | O caminho por hooks de settings é equivalente; `--autocompact` como rede de segurança |

## 5. TASKs para emendar o PLAN-0013

Seguem o formato das TASK-01..07 (todas `repo: ginga`, `mode: mvp`, `tier: free`, `tests_frozen` no teste). Ordem: 08 → 09 → (10, 11, 12) → 13. Dependem da TASK-03 (handoff). Atualizar a linha "Gatilhos … ficam fora" da Abordagem do PLAN-0013 para "gatilhos automáticos: TASK-08..13".

**TASK-08 · Política `[handoff]` + `decideHandoff`**
- goal: "decideHandoff devolve none/prepare/redirect e o gatilho para cada combinação de ociosidade, contexto, profundidade e cooldown; `ginga lint` valida `[handoff]`"
- done_when: `bun test tests/handoff_policy.test.ts`
- touch: `src/handoff/policy.ts`, `src/lint/project_toml.ts` (ou o validador existente do `project.toml`), `tests/handoff_policy.test.ts`
- interfaces: `decideHandoff(cfg: HandoffCfg, s: {now, lastApiTs, contextTokens, interactive, depth, lastHandoffTs}) → {action: "none"|"prepare"|"redirect", trigger: "idle"|"context"|null, reason: string}`; `idle_min=0` desliga; `mode=suggest` nunca devolve `redirect`

**TASK-09 · `ginga handoff` em modo sessão (sem PLAN, `--notes`, `--trigger`)**
- goal: "Sem `<PLAN>`, `ginga handoff --trigger idle` infere o PLAN ou cai em git + pendências, aceita `--notes`, grava as 7 seções, filtra segredos e fica ≤ 4k tokens, bytes idênticos para a mesma entrada"
- done_when: `bun test tests/handoff_session.test.ts`
- touch: `src/handoff.ts`, `src/handoff/redact.ts`, `src/verbs/handoff.ts`, `tests/handoff_session.test.ts`, `tests/fixtures/handoff-session/`
- interfaces: flags da §2; `redact(text) → text` com `[REDACTED]`; frontmatter `trigger`, `runtime`, `from_session`, `transcript`, `parent_handoff`, `depth`

**TASK-10 · `ginga handoff hook --runtime` (entrada/saída por runtime)**
- goal: "O hook lê o JSON do runtime em stdin, roda `decideHandoff`, grava o handoff quando `prepare`/`redirect` e imprime a resposta no formato do Claude (`decision: block` + motivo) e do Codex; o uso de contexto sai do `usage` do transcript"
- done_when: `bun test tests/handoff_hook.test.ts`
- touch: `src/handoff/hook.ts`, `src/handoff/transcript_usage.ts`, `src/verbs/handoff.ts`, `tests/handoff_hook.test.ts`, `tests/fixtures/transcripts/`
- interfaces: stdin `{session_id, transcript_path, cwd, prompt?, hook_event_name}`; `transcriptUsage(path) → {contextTokens, lastApiTs}`; saída `{decision?: "block", reason?: string}`; estado em `.ginga/state/handoff-<session>.json`; ignora sessão não interativa e `!!`

**TASK-11 · Abertura da sessão nova (`--open`) no Claude**
- goal: "`ginga handoff --open --runtime claude` monta o prompt de abertura e chama `claude --bg -n … --model …`, devolve o id em JSON e registra o evento `handoff` com `trigger` e `depth`"
- done_when: `bun test tests/handoff_open.test.ts` (spawn de `claude` mockado; assert sobre o argv: `--bg`, sem `--resume`/`--fork-session`)
- touch: `src/handoff/open.ts`, `src/handoff/open_claude.ts`, `tests/handoff_open.test.ts`
- interfaces: `openSession(runtime, {handoffPath, userPrompt, model, cwd}) → {ok, sessionRef, attachCmd}`; interface de adapter para opencode/Pi/Codex devolve `attachCmd` impresso quando não abre sozinho

**TASK-12 · Skill `handoff` na fonte única + projeção**
- goal: "`.ginga/skills/handoff/` passa no `ginga lint` e o `ginga install --dry-run` lista a projeção para Claude, opencode e Pi sem tocar entrada alheia"
- done_when: `bun test tests/skill_handoff.test.ts`
- touch: `skills/handoff/SKILL.md`, `skills/handoff/scripts/handoff.ts`, `skills/handoff/references/formato.md`, `tests/skill_handoff.test.ts` (em `.ginga/` do workspace; teste no ginga)
- interfaces: `SKILL.md` com `name: handoff` e `description`; `scripts/handoff.ts` imprime JSON `{path, tokens, open}`; depende do projetor de skills do PLAN-0006

**TASK-13 · Adapter Claude (hooks de settings + mod opcional) e A/B de gatilho**
- goal: "`ginga install` projeta as entradas `Stop` e `UserPromptSubmit` (Claude) que chamam `ginga handoff hook --runtime claude`, idempotente e em dry-run por padrão; o mod `ginga-handoff` usa `session.measure`/`prompt.submit` e chama o mesmo comando"
- done_when: `bun test tests/install_handoff_claude.test.ts && claude plugin validate contrib/claude-mod-handoff`
- touch: `src/install/adapters/claude.ts`, `contrib/claude-mod-handoff/{.claude-plugin/plugin.json,hooks/hooks.json,hooks/register.ts}`, `tests/install_handoff_claude.test.ts`
- interfaces: o adapter só repassa JSON ao comando e executa a ação; zero lógica de decisão; opencode, Pi e Codex ficam para o PLAN seguinte (mesmo `hook`, adapters de ≤ 50 linhas)

## 6. Fora do escopo e perguntas abertas

- Adapters opencode, Pi, Codex e AGY (depois da 13, na ordem opencode → Pi); confirmar `tokens` em `message.updated` e o usage no JSONL do Pi antes.
- Os limiares reais (`idle_min`, `context_tokens`) saem do A/B do PLAN-0014; os valores acima são os de partida do dono.
- Confirmar o schema exato do stdin do `statusLine` e se o `PreCompact` do Claude pode substituir o auto-compact (já pendente no 06).
