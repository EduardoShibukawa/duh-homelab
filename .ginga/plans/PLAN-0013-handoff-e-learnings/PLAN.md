---
type: plan
title: Handoff determinístico e automático, log.md automático e learnings → lessons
spec: SPEC-0001-ginga-revamp
intent: INTENT-0005-handoff-e-learnings
kind: change
status: approved
repos: [ginga, manda, p-inga]
depends_on: [PLAN-0011-verbos-api-auth]
done_when: "cd ginga && bun test && cd ../manda && bun test tests/plan_lessons.test.ts && cd ../p-inga && bun test tests/learn_migrado.test.ts"
---
## Objetivo

Implementar o [06](../../knowledge/design/ginga-revamp/06-handoff-e-learnings.md): o handoff é renderizado sem LLM a partir de arquivos e git, todo PLAN tem `log.md` (sistema) e `LEARNINGS.md` (sessão), `kind: investigation` passa pelo mesmo verify, e learnings promovidos viram `LESSON-*.md` que o Planner encontra pelo `touch`. **Emenda (dono, 2026-10-29):** o handoff também é **automático**, disparado por ociosidade (cache prestes a expirar) **ou** por tamanho de contexto, e abre uma sessão nova com ele.

## Decisões

- **Lições migram para o ginga.** `pinga learn`/`lessons` (p-inga) e o `LESSONS.md` da raiz se sobrepõem a este PLAN. A fonte única passa a ser `.ginga/knowledge/lessons/LESSON-*.md`: o ginga importa o que existe (TASK-08) e o pinga passa a avisar que o comando migrou (TASK-09), sem perder o comportamento atual até o corte.
- **Formato do `log.md` = o que as lanes já escrevem:** `AAAA-MM-DD TASK-xx <runtime/modelo> tentativa N pass|fail` (com `: <motivo>` na falha). Os outros eventos usam `AAAA-MM-DD <kind> <resumo>`.
- **Handoff automático segue o [doc 11](../../knowledge/design/ginga-revamp/11-handoff-automatico.md)** (TASK-10 a 15 = as propostas TASK-08 a 13 de lá, renumeradas): gatilho `idle` (ociosidade desde a última chamada à API > `idle_min` 55, avaliado ao receber prompt) **ou** `context` (≥ 110000 no fim do turno); `mode = "suggest"` por padrão; anti-loop por `cooldown_min`/`max_chain`; decisão numa função pura única (`decideHandoff`); adaptadores finos. O A/B do PLAN-0014 ajusta os limiares.
- Neste PLAN entra só o adaptador do Claude; opencode, Pi, Codex e AGY ficam para o PLAN seguinte (doc 11 §6).
- Sem dependência do pi-harness: o `HANDOFF-0043.md` e o `task_resume.ts` eram só exemplo; o formato fica definido aqui (TASK-03).

## TASKs

1. [TASK-01](TASK-01-log-automatico.md): `log.md` automático pelo event router
2. [TASK-02](TASK-02-learnings-lint.md): formato do `LEARNINGS.md` e `kind` no lint
3. [TASK-03](TASK-03-handoff.md): `ginga handoff [<PLAN>]`
4. [TASK-04](TASK-04-e2e-investigation.md): e2e de PLAN `kind: investigation`
5. [TASK-05](TASK-05-learning-promote.md): `ginga learning promote` → `LESSON-*.md`
6. [TASK-06](TASK-06-lessons-find.md): `ginga lessons find --touch`
7. [TASK-07](TASK-07-manda-plan-lessons.md): o `manda plan` cita as lessons achadas
8. [TASK-08](TASK-08-lessons-import.md): `ginga lessons import` (LESSONS.md da raiz e propostas do pinga)
9. [TASK-09](TASK-09-pinga-learn-migrado.md): `pinga learn propose|promote` avisam que migraram
10. [TASK-10](TASK-10-handoff-politica.md): política `[handoff]` + `decideHandoff`
11. [TASK-11](TASK-11-handoff-sessao.md): `ginga handoff` em modo sessão (`--notes`, `--trigger`, filtro de segredos)
12. [TASK-12](TASK-12-handoff-hook.md): `ginga handoff hook --runtime`
13. [TASK-13](TASK-13-handoff-open.md): abertura da sessão nova (`--open`) no Claude
14. [TASK-14](TASK-14-skill-handoff.md): skill `handoff` na fonte única + projeção
15. [TASK-15](TASK-15-adapter-claude.md): adapter do Claude (hooks + mod opcional)
18. [TASK-18](TASK-18-handoff-cli-sessao-correcao.md): correção do judge na CLI de sessão (T308)
19. [TASK-19](TASK-19-handoff-hook-cli-correcao.md): correção do judge na CLI do hook (T309)
20. [TASK-20](TASK-20-handoff-cli-open.md): correção do judge — `--open` na CLI (openSession) + script da skill (T310)
23. [TASK-23](TASK-23-install-dryrun-guard-correcoes.md): correção do judge — dry-run/revert de skills idempotentes + guarda A2 sob append (T313)

## Ordem

ginga: (01, 02) → 03 → (04, 05, 10) → 06 → 08; 10 → 11 → (12, 13, 14) → 15. manda: 07 depois da 06 mergeada no ginga. p-inga: 09 independente.

## Interfaces (definidas no plano; mudar = replan)

```ts
// src/plan_log.ts (TASK-01)
export function formatLogLine(ev: EventV1): string | null; // null = evento que não vai para o log
export function appendPlanLog(root: string, ev: EventV1): { appended: boolean }; // idempotente por ev.id
// src/handoff.ts (TASK-03)
export function buildHandoff(root: string, o: { plan?: string; now: Date; git: (args: string[], cwd: string) => string }): { path: string; markdown: string; tokens: number };
// src/verbs/handoff.ts exporta HANDOFF_VERBS: Verb[]  (registry.ts faz ...HANDOFF_VERBS)
// src/lessons.ts (TASK-05/06/08); src/verbs/learning.ts exporta LEARNING_VERBS: Verb[]
export type Lesson = { id: string; title: string; path: string; scope: { repo?: string; files: string[]; tags: string[] }; evidence: string; from: string };
export function promote(root: string, ref: string /* PLAN-NNNN#L-NN */): Lesson;
export function findLessons(root: string, touch: string[], repo?: string): (Lesson & { why: string })[];
export function importLessons(root: string, file: string): { created: string[]; skipped: number }; // idempotente por hash do texto
// src/handoff/policy.ts (TASK-10)
export function decideHandoff(cfg: HandoffCfg, s: { now: Date; lastApiTs: Date; contextTokens: number; interactive: boolean; depth: number; lastHandoffTs: Date | null; event: "prompt" | "turn_end" }): { action: "none" | "prepare" | "redirect"; trigger: "idle" | "context" | null; reason: string };
// src/handoff/redact.ts (TASK-11): export function redact(text: string): string;
// src/handoff/transcript_usage.ts (TASK-12)
export function transcriptUsage(path: string): { contextTokens: number; lastApiTs: Date | null };
// src/handoff/open.ts (TASK-13)
export function openSession(runtime: string, o: { handoffPath: string; userPrompt: string; model: string; cwd: string; spawn: Spawn }): Promise<{ ok: boolean; sessionRef: string | null; attachCmd: string }>;
```

## ACs da SPEC cobertos

- `ginga handoff <PLAN>` gera o handoff sem LLM, só a partir dos arquivos e do git.
- Todo PLAN tem `log.md` (automático) e `LEARNINGS.md`; `kind: investigation` funciona com o mesmo verify.
- Learnings promovidos viram `LESSON-*.md` e o Planner os encontra pelo `touch`.
- Parte de "toda ação existe como verbo" (`handoff`, `learning promote`, `lessons import`).

## Riscos

- Riscos do handoff automático (perder decisões do chat, loop, redirecionar contra a vontade, privacidade, TTL errado): ver doc 11 §4; as mitigações estão nas TASK-10 a 15.
- Medir contexto depende de campo não documentado (`usage` no transcript do Claude): ausente → `-1`, e só a ociosidade vale.
- A skill `handoff` mora no repo ginga (`skills/handoff/`) e é projetada pelo `ginga install`; a fonte única das demais skills segue com a SPEC-0002.
