---
type: plan
title: Rota de falhas e disjuntor por modelo (lacuna 2)
intent: INTENT-0008-resolver-dependencias
spec: SPEC-0003-observabilidade-operacional
kind: change
status: approved
repos: [manda]
depends_on: [PLAN-0008-manda-routing-e-judge]
done_when: "cd manda && bun test"
---
## Objetivo

Uma tentativa que não anda é **classificada pelo código**, não por um LLM nem por um timeout: *devagar* (há eventos → esperar), *na fila* (conexão aberta, zero bytes, probe ok → esperar até a paciência), *travado* (sem eventos, CPU nem arquivos e o probe falha → matar, abrir o disjuntor, trocar de provider) ou *recusado* (ECONNRESET, 5xx, quota → abrir o disjuntor, próximo). Nenhum modelo é repetido às cegas: só volta depois de um **probe** barato passar. O `BLOCKED:` do executor e do gate é classificado e vira a ação certa. Tempo não é restrição: mede-se **progresso**, não relógio.

## Decisões do dono (2026-10-29) que este PLAN implementa

- `[routing] patience` e `no_progress_min` são parâmetros; sem teto de execução.
- **Disjuntor por modelo no `state.db`** (tabela `model_breaker`), compartilhado entre lanes: aberto 10 min → 30 min → 2 h; meio-aberto = probe. Implementa o `breaker` do frontmatter do ROUTING.
- **Escada por custo:** free saudável de qualquer provider (opencode free, `iceman` só em TASK de repo MIT, `pi:nvidia/...` quando a fila andar) → pago só com todos os free de disjuntor aberto, `ALLOW_PAID=1` e teto ok. Provider novo entra pela porta de runtime + ROUTING, sem fork.
- **`free_retry` com espera:** cota free esgotada não encerra a lane (exit 4); espera com backoff (15 → 30 → 60 min) e tenta de novo só depois do probe.
- `PYTHONDONTWRITEBYTECODE=1` e stdin `/dev/null` em todo runtime (causas reais de `scope_drift` e de "travamento" falso).
- **Pré-checagem de cota do judge:** antes de chamar o judge, escolhe um de família diferente com cota (probe ou `ginga quota --json`), em vez de gastar uma tentativa para descobrir que o Codex está sem cota.

## TASKs

1. [TASK-01](TASK-01-classificar-tentativa.md): os quatro estados
2. [TASK-02](TASK-02-probe.md): probe barato por modelo
3. [TASK-03](TASK-03-disjuntor.md): disjuntor por modelo no `state.db`
4. [TASK-04](TASK-04-escada-por-custo.md): escada por custo free → pago
5. [TASK-05](TASK-05-env-runtime.md): `PYTHONDONTWRITEBYTECODE` e stdin fechado em todo runtime
6. [TASK-06](TASK-06-free-retry.md): `free_retry` com espera
7. [TASK-07](TASK-07-classificar-blocked.md): classificador de `BLOCKED:`
8. [TASK-08](TASK-08-judge-cota.md): pré-checagem de cota do judge
9. [TASK-09](TASK-09-vigiar-tentativa.md): o `manda run` vigia a tentativa e troca de modelo
10. [TASK-10](TASK-10-verbos-disjuntor.md): `manda breaker status|reset`
11. [TASK-11](TASK-11-integrar-vigia-run.md): correção do judge — liga a vigia ao `manda run` real
12. [TASK-12](TASK-12-ligar-vigia-ao-vivo-no-run.md): correção do judge (gate 20:20) — `watchAttempt` durante a tentativa viva (sample /proc+worktree, probe, kill pelo pid) e `breakerOf` no laço de `attemptSpecs`
13. [TASK-13](TASK-13-corrigir-vigia-ao-vivo-real.md): correção do judge (gate 23:20) — sampler real com probe (`na_fila` alcançável), probe ok não mata, stop pós-kill não aborta o `waitForFree`, stream da própria tentativa (`logPath`), não o `$GINGA_EVENTS`

Ordem: (01, 02, 03, 05, 07) → 04 → (06, 08, 10) → 09 → 11 → 12.

## Interfaces (definidas no plano; mudar = replan)

```ts
// src/run_state.ts (TASK-01)
export type RunState = "ok" | "devagar" | "na_fila" | "travado" | "recusado";
export type RunObs = { since_last_event_s: number; stream_bytes: number; cpu_pct: number; files_changed: boolean; probe_ok: boolean | null; exit: number | null; stderr_tail: string };
export function classifyRun(o: RunObs, cfg: { patience_min: number; no_progress_min: number }): { state: RunState; reason: string };
// src/probe.ts (TASK-02)
export function probeArgv(model: string): string[]; // "responda só: ok", stdin /dev/null
export async function probe(model: string, run: Runner, timeout_ms?: number): Promise<{ ok: boolean; ms: number }>;
// src/breaker.ts (TASK-03)
export type BreakerState = "closed" | "open" | "half_open";
export function breakerOf(db: Database, model: string, now: Date): { state: BreakerState; until: string | null; level: number };
export function recordFailure(db: Database, model: string, reason: string, now: Date): void; // 10 → 30 → 120 min
export function recordSuccess(db: Database, model: string): void;
// src/ladder.ts (TASK-04)
export function pickModel(o: { tier: string; pools: Record<string, string[]>; free: string[]; allowPaid: boolean; capOk: boolean; mitRepo: boolean; breaker: (m: string) => BreakerState }): { model: string | null; reason: string };
// src/blocked.ts (TASK-07)
export type BlockedClass = "contract_conflict" | "missing_dep" | "env_dependency" | "id_collision" | "gate_false_positive" | "scope_drift" | "quota" | "other";
export function classifyBlocked(text: string): { class: BlockedClass; action: "auto_unblock" | "retry_clean" | "skip_tier" | "replan" | "notify"; evidence: string };
```

## Riscos

- Os padrões de stderr dos providers mudam: as regras de `classifyBlocked` e de `recusado` ficam num arquivo de dados (`src/failure_rules.json`), testado por fixture, para trocar sem código.
- O probe gasta (pouco) em modelo pago: em pago, o probe só roda no meio-aberto, nunca em laço.
- O classificador Jev (ROUTING) fica fora: só entra depois do experimento de acurácia; aqui é regex determinístico.
- `fail_triage` do Judge e TASK de desbloqueio com `depends_on` invertido ficam com o replan do PLAN-0028.
