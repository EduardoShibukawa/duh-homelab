---
type: handoff
plan: [PLAN-0006, PLAN-0008, PLAN-0010, PLAN-0018]
timestamp: 2026-10-28T00:55:00-03:00
---
## Estado

| Item | Status |
|---|---|
| pi-run.sh (TASK-06 do PLAN-0018) | **done**: `.ginga/bin/pi-run.sh` + teste RED `tests/pi-run.test.sh`; teste real deepseek-v4-pro US$0.00899 |
| Passada RED 0006/0008/0010 | **done**: 14 RED (prove-red), 1 replan. Ledger ok 361 |
| Dogfood `manda run` (PLAN-0010) | **defeito registrado** no LEARNINGS do 0007: pi.ts:148 usava `opencode-go`/`qwen3.8-flash` padrão |
| 0008 TASK-01 (T9, pi.ts fail-closed) | **done**: despachada via dispatch-task.sh, pass 1 tentativa (glm-5.3-flash-free, US$0) |

- **Custo pago:** US$0,00899 (só o teste do pi-run.sh). Teto da onda US$2,00.
- **TASK-01 do 0008** (pi.ts fail-closed) foi adicionada e as demais renumeradas (TASK-02..08). `pinga_task`: manda T9–T14, ginga T11–T17, p-inga T74.

## Pendências (bloqueios)

1. **ginga (0006 e 0010) depende do PLAN-0004**, que está `blocked` e **não commitado** (`ginga-plan-0004` tem o código, mas `git ls-files` = 0). As worktrees `ginga-plan-0006`/`ginga-plan-0010` nasceram de `chore: init` (vazio). O executor precisa rebasear sobre o 0004 antes de rodar.
2. **0010 TASK-06 (p-inga) replan**: o `done_when` roda `tests/discord.test.ts` (caso 1 exige canal fixo + `~/.hermes`), que contradiz o goal e não está no `touch`. Opções: incluir no `touch` ou tirar do `done_when`. `tests/discord_events.test.ts` já escrito (RED), sem `pinga_task`.
3. **`manda run` precisa de `.ginga/project.toml`** com `[runtimes]` (senão cai no `pi`, que agora falha fechado). Isso é o routing do 0008 (TASK-02/03).

## Próximo passo

1. Despachar o resto do **PLAN-0008** (TASK-02..08) via `dispatch-task.sh` (manda + p-inga, sem depender do 0004).
2. Resolver o replan da 0010 TASK-06 (Planner) e o destino do PLAN-0004 (dono).
3. Depois: 0006 e 0010 (ginga) após o 0004; judge Codex + merge.

## Aprendizados

- `claude -p` não-interativo nega o Bash; usar `--allowedTools=Bash,Read,Write,Edit` + prompt via stdin.
- Claude Pro bateu o limite de 5h (resetou 00:30); a passada RED agrupou os 3 PLANs numa sessão só.
- O `manda run` em falha deixa a worktree `.worktrees/wt-<id>` para trás (só remove no `passed`).
