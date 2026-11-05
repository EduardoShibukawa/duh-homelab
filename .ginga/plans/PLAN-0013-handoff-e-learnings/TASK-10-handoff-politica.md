---
type: task
mode: mvp
goal: "decideHandoff devolve none/prepare/redirect e o gatilho para cada combinação de ociosidade, contexto, profundidade e cooldown; ginga lint valida [handoff]"
title: Política [handoff] + decideHandoff
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T149
depends_on: [TASK-03-handoff]
tier: free
touch: [src/handoff/policy.ts, src/lint/project_toml.ts, src/lint/index.ts, tests/handoff_policy.test.ts]
done_when: "bun test tests/handoff_policy.test.ts"
tests_frozen: [tests/handoff_policy.test.ts]
---
## Fazer
- `[handoff]` do `project.toml` (doc 11 §1): `mode` (`off|suggest|auto`, padrão `suggest`), `idle_min` 55, `context_tokens` 110000, `min_context_tokens` 30000, `cooldown_min` 30, `max_chain` 3, `summary` `off`; override por runtime em `[handoff.<runtime>]`.
- `idle`: avaliado ao receber prompt (`now − lastApiTs > idle_min` e contexto ≥ `min_context_tokens`) → `redirect`. `context`: fim de turno, contexto ≥ `context_tokens` → `prepare`. `idle_min = 0` desliga a ociosidade; `mode = suggest` nunca devolve `redirect`; `depth ≥ max_chain` ou dentro do `cooldown_min` → `none`; sessão não interativa → `none`.
## Interface
- `decideHandoff(cfg: HandoffCfg, s: { now: Date; lastApiTs: Date; contextTokens: number; interactive: boolean; depth: number; lastHandoffTs: Date | null; event: "prompt" | "turn_end" }): { action: "none" | "prepare" | "redirect"; trigger: "idle" | "context" | null; reason: string }`; `parseHandoffCfg(toml: object, runtime: string): HandoffCfg`. Teste: tabela com cada regra acima; `ginga lint` acusa `mode = "x"`.
## Não fazer
- Sem timer nem vigia (os gatilhos rodam nos eventos do runtime).
## Contexto
- `knowledge/design/ginga-revamp/11-handoff-automatico.md` §1 (fonte desta TASK, proposta TASK-08 de lá).
