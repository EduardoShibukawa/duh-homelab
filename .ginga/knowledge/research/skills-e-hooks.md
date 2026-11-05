---
type: research
title: Skills e hooks no harness, entregues por sandbox (INTENT-0009)
timestamp: 2026-10-28
status: draft
---

# Skills e hooks no harness, entregues por sandbox

Legenda: **[verificado]** abri a fonte ou li no repo; **[inferência]** dedução minha, não verifiquei.

## 1. Estado da arte (out/2026)

**Agent Skills** é um padrão aberto (agentskills.io, spec publicada em 18/12/2025 pela Anthropic, adotado por 26+ plataformas). Uma skill é uma pasta com `SKILL.md` (+ `scripts/`, `references/`, `assets/`). Só `name` e `description` do frontmatter são carregados no startup (~100 tokens/skill); o corpo completo só quando ativada; scripts/recursos só quando usados (progressive disclosure). `allowed-tools` (experimental) pré-aprova ferramentas. Scripts podem ser Python/Bash/JS/TS, depende do runtime.

### Tabela de compatibilidade

| Runtime | Skills (formato/local) | Hooks/plugins (eventos) | Pode bloquear? |
|---|---|---|---|
| **Claude Code** | `SKILL.md` em `~/.claude/skills/` e `.claude/skills/`; plugins via marketplace | `settings.json` → `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `UserPromptSubmit`, `Notification`, `PreCompact`, `SessionStart/End`, `ConfigChange`. Exit 2 bloqueia; JSON `permissionDecision: deny` | Sim (PreToolUse) |
| **Codex CLI** | `SKILL.md` em `~/.agents/skills/` e `$CWD/../.agents/skills`; plugins | Hooks em `~/.codex/hooks.json`/`config.toml`: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`, `Stop`. Exit 2 ou `permissionDecision: deny` | Sim (PreToolUse) |
| **OpenCode** | `SKILL.md` em `.opencode/skills/`, `~/.config/opencode/skills/`, `.claude/skills/`, `.agents/skills/` (mesmo formato) | Plugins TS/JS em `.opencode/plugins/` e `~/.config/opencode/plugins/`: `tool.execute.before/after`, `session.*`, `tui.*`. Antes da tool pode `throw` para bloquear | Sim (throw em `before`) |
| **Pi** | `SKILL.md` em `~/.pi/agent/skills/` e `.agents/skills/`; pacotes `pi install` | Extensões TS: `pi.on("tool_call")` pode `throw` para bloquear; também `registerCommand`, `registerTool` | Sim (throw) |
| **Gemini/AGY** | `SKILL.md` em `~/.gemini/antigravity-cli/plugins/<name>/skills/` e extensões; `agy plugin` | Hooks (pre/post tool, session) via plugins; Antigravity mantém "critical features" incluindo hooks | Sim (pre_tool) |
| **Hermes** | `SKILL.md` em `~/.hermes/skills/` e `<projeto>/.hermes/skills/` + `.agents/skills/`; `/learn` cria skills | Plugins Python: `pre_tool_call` (pode retornar `{"action":"block"}`), `post_tool_call`, e hooks shell em `hooks:` do config. Fail-closed em timeout | Sim (block) |

Conclusão: **o formato SKILL.md é o denominador comum** (mesmo arquivo roda em todos). Hooks existem em todos os runtimes com capacidade de bloqueio em `pre tool`. A diferença é o mecanismo (JSON/exit code vs. throw vs. return block) e a granularidade dos eventos.

## 2. O que já temos

### Skills

| Local | Conteúdo | Status |
|---|---|---|
| `p-inga/.agents/skills` + `p-inga/skills` | `pinga`, `red-audit` (duplicados nas duas pastas) | útil, mas duplicado |
| `gira-g/.agents/skills` + `internal/skills/catalog` | `work` (com variantes heavy/standard) + 6 skills gira-* | útil; catálogo interno é a fonte do gira |
| `pi-harness/.pi/skills` | `sdlc-task-executor`, `spec-authoring` | morto com o pi-harness (decisão 2 do revamp) |
| `_preservacao/G-Inga-archived/skills` | `drive`, `orchestrate`, `sharpen`, `validator-flow`, `work` | morto (arquivado, 2026-10-16) |
| `.agents/skills` / `.claude/skills` (raiz) | 6 skills gira-* (projeção) | útil, projeção do gira-g |
| `pi-harness/src/skill_catalog.ts` + `skill_projection.ts` | catálogo por realpath + projeção para 4 hosts via symlink | útil, mas acoplado ao pi-harness (sai no PLAN-0006) |

### Hooks

| Hook | Onde | O que faz | Status |
|---|---|---|---|
| Claude `PreToolUse` (tuios) | `~/.claude/settings.json` | rastreia estado do agente (não bloqueia) | útil |
| `herdr-agent-state.sh` | `~/.claude/hooks/` | estado de pane | útil |
| `p-inga/src/hooks.ts` | p-inga | payload guard (bloqueia write >100 linhas/1500 chars), type-check pós-escrita, disjuntor de inércia | útil (mas só vale dentro do p-inga) |
| `bashRefusal` (pi-harness) | `claude-plugin/hooks/policy.ts` | bloqueia `git add -A/.`, `--no-verify`, push force, `.git`/`.env` | útil, mas morto com pi-harness |
| `hk` pre-commit | `hk.pkl` em cada repo | roda `mise run pre-commit` | útil |
| `pinga install`/`precommit` | pinga | instalação e gates | migra para ginga (PLAN-0006) |
| G-Inga archived hooks | `_preservacao/.../hooks` | `session-start.mjs`, `g-inga-guard.ts` (OMP) | morto (arquivado) |

**Duplicado:** skills pinga/red-audit em duas pastas no p-inga; gira-* em `.agents` e `.claude` (projeção, esperado); skills do gira-g catalog e archived `work`. **Morto:** tudo sob pi-harness (sai) e archived. **Útil e a salvar:** `bashRefusal`/policy, payload guard, disjuntor de inércia, `skill_catalog`/`skill_projection` (mover para ginga no PLAN-0006).

## 3. Skills + sandbox

- **Entrega por papel/TASK:** a skill entra na sandbox como mount somente leitura da sua pasta (`--ro-bind .ginga/skills/<nome> /skills/<nome>`). Cada papel (Planner, Executor, Judge, Orquestrador) recebe só as skills da sua lista; rede `none` ou allowlist por perfil (sandbox-ai.md §3, §5). Menos contexto (progressive disclosure já reduz) e menos superfície (sem rede, sem `~`).
- **Scripts TS dentro da sandbox:** o script roda com `bun` (toolchain em `--ro-bind` do mise) e imprime JSON no stdout. O modelo chama via Bash/`execute`, lê o JSON, decide. Determinístico: o script faz o que não pode errar; o modelo só decide quando chamá-lo (H3 do PLAN-0016). Ex.: `bun run /skills/pinga/scripts/validate-frontmatter.ts --file X` → `{ok, errors}`.
- **Hook fora vs. dentro da sandbox:**
  - **Fora (host):** aplicado pelo host antes/depois da sandbox. O modelo não contorna porque não está na sandbox e não tem o código do hook. Ex.: teto de custo, `tests_frozen` ro-bind, `git add -A`, provider proibido, unicidade do `pinga_task`. É a camada de enforcement real.
  - **Dentro:** hook do runtime dentro da sandbox (ex.: plugin OpenCode). Útil para formatação/lint, mas o modelo pode tentar contornar (ele roda na mesma sandbox). Serve como conveniência, não como gate de segurança.
- **Riscos:** injeção via SKILL.md (um skill malicioso pode instruir exfiltração) → tratar skill como código não confiável, revisar antes de montar, allowlist de skills por papel; script com rede → sandbox `--unshare-net` + allowlist de domínios; segredos → não montar `~/.claude`/`auth.json` inteiros, injetar chave só no provider (modelo `mask` do ai-jail/srt); script que lê demais → limites de CPU/memória/tempo via `systemd-run`.

## 4. Determinismo

Regra: **o que não pode errar vira script; o que exige julgamento vira prompt.**

| Caso | Script (determinístico) | Prompt (modelo) |
|---|---|---|
| Validar frontmatter do PLAN/SPEC/TASK | `validate-frontmatter.ts` checa campos, tipos, unicidade | decidir se o conteúdo é suficiente |
| Unicidade do `pinga_task` no ledger | `check-task-id.ts` consulta `ledger.db` e falha se duplicado (INTENT-0008 §4) | escolher o próximo id |
| `tokens.sh` / medição de custo | script conta tokens/custo antes/depois (PLAN-0014) | interpretar e agir |
| Classificar `BLOCKED:` | regex/parse do outbox → gera TASK de desbloqueio (INTENT-0008) | decidir a correção |
| Teto de custo | guard mede e bloqueia antes da chamada (corrigir o bug do guard que mede depois) | decidir se vale pagar |
| `git add -A` / `--no-verify` | `bashRefusal` (já existe) | — |

**Relação com H3 do PLAN-0016:** a H3 diz "CLI + skill ≈ code mode, já que bash já compõe; se C ≈ X2, não criar o tool `execute`". Se os scripts determinísticos da skill cobrem os casos acima, a skill (C) pode substituir o `execute` (X) para o orquestrador — e o experimento do PLAN-0016 deve medir isso explicitamente. **Isso não muda o desenho do experimento** (as variantes M/C/X1/X2 continuam), mas adiciona uma célula: **C com skill determinística** (scripts TS) vs. C sem scripts. Se C+scripts ≈ X2, descartamos o `execute` e economizamos a complexidade do bwrap no lado das tools. A H3 vira o critério de decisão principal para o orquestrador.

## 5. Uma fonte, vários runtimes

**Fonte única:** `.ginga/skills/<nome>/{SKILL.md, scripts/*.ts, references/, assets/}` + `hooks.toml` (eventos, matchers, ações) + perfis de sandbox em `project.toml` (`[sandbox.<runtime>]`: mounts, env, domains, flags). Uma skill, um lugar.

**Gerador:** `ginga install`/`init` projeta a fonte para o formato de cada runtime:
- Claude: `.claude/skills/<nome>` (symlink ou cópia) + trecho em `.claude/settings.json` (hooks).
- Codex: `.agents/skills/<nome>` + `.codex/hooks.json`.
- OpenCode: `.opencode/skills/<nome>` + `.opencode/plugins/*.ts`.
- Pi: `.pi/skills/<nome>` + extensão em `.pi/extensions/`.
- AGY: plugin em `~/.gemini/.../plugins/ginga/`.
- Hermes: `.hermes/skills/<nome>` + plugin Python.

Idempotente, nunca sobrescreve entrada alheia (regra herdada de `skill_projection.ts`), dry-run por padrão.

**Dono:** **ginga** é o dono. Racional: PLAN-0006 já tira install/adopt do pinga para o ginga; PLAN-0015 faz o `ginga init` gerar config por agente a partir do `project.toml`. O gerador de skills/hooks é a mesma casa (install/adopt + perfis de sandbox). O pinga fica só com o gate; o manda orquestra. Assim não duplica: o `skill_catalog`/`skill_projection` do pi-harness migram para o ginga no PLAN-0006 (TASK-01/02), e o `init` do PLAN-0015 ganha a projeção de skills/hooks como extensão. O manda consome via CLI/JSON (decisão 4 do revamp), nunca importa o ginga.

## 6. Recomendação

**Parcial — sim para skills+scripts determinísticos e hooks do lado do host; não para hooks dentro da sandbox como gate.**

Motivo: o formato SKILL.md já é o padrão comum e a infraestrutura (catálogo, projeção, hooks de policy) já existe, só está espalhada/morta. O ganho real é (a) determinismo via scripts TS e (b) enforcement fora da sandbox, que o modelo não contorna. Hooks dentro da sandbox são conveniência, não segurança.

**MVP (pagam o custo já):**
- Skills: `pinga` (validar frontmatter + unicidade de task id), `red-audit` (já existe), `gira-context` (já existe).
- Hooks do host: `bashRefusal` (git add -A/--no-verify/push force) migrado para ginga; teto de custo pré-chamada; `tests_frozen` ro-bind (já no sandbox-done-when.sh).

**Fica para depois:** hooks dentro da sandbox, marketplace de skills, skill-creator, projeção automática para todos os 6 runtimes (primeiro Claude+OpenCode+Pi, depois Codex+AGY+Hermes), scripts em Python (manter TS/bun por causa do toolchain já montado).

## Fontes

- [verificado] agentskills.io/specification (spec SKILL.md, progressive disclosure, scripts/)
- [verificado] code.claude.com/docs/en/hooks (eventos, exit 2, JSON)
- [verificado] opencode.ai/docs/plugins (tool.execute.before/after, eventos)
- [verificado] opencode.ai/docs/skills (paths, frontmatter, permissões)
- [verificado] learn.chatgpt.com/docs/hooks + agenticcontrolplane.com (Codex hooks, PreToolUse deny)
- [verificado] antigravity.google/docs/skills + geminicli.com/docs/cli/skills (AGY/Gemini)
- [verificado] hermes-agent.nousresearch.com/docs/user-guide/features/skills + hooks + plugins (Hermes)
- [verificado] INTENT-0009, INTENT-0006, PLAN-0016, PLAN-0006, PLAN-0015, sandbox-ai.md, sessao-2026-10-27/analise.md, sandbox-done-when.sh, design/ginga-revamp/README.md
- [verificado] inventário local: `ls`/`rg` em p-inga, gira-g, pi-harness, _preservacao/G-Inga-archived, ~/.claude
- [inferência] tabelas de compatibilidade consolidadas a partir das fontes acima; "morto" classificado pelo revamp (decisão 2) e pela data de arquivo (2026-10-16)
