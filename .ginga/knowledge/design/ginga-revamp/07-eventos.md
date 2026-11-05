# 07 — Schema de eventos

Este é o contrato entre as ferramentas e o ginga. É uma spec em documento, não uma lib compartilhada: cada ferramenta implementa por conta própria.

## Transporte

- Se `$GINGA_EVENTS` estiver definido, a ferramenta faz **append** de uma linha JSON por evento nesse caminho (JSONL, UTF-8, `\n` no fim).
- Se não estiver definido, nada é emitido e a ferramenta funciona igual.
- Escrita com `O_APPEND` e uma linha por `write()`, abaixo de 4 KiB, para ser atômica entre processos.
- O ginga consome a partir de um offset salvo no `state.db` e nunca reescreve o arquivo.

## Envelope (todos os eventos)

```json
{
  "v": 1,
  "ts": "2026-10-27T14:02:11.204Z",
  "source": "pinga | manda | ginga | gira | <outro>",
  "kind": "attempt",
  "id": "01JBX…",
  "repo": "pi-harness",
  "intent": "INTENT-0005",
  "spec": "SPEC-0005",
  "plan": "PLAN-0005",
  "task": "TASK-03",
  "data": { }
}
```

- `v`, `ts`, `source`, `kind` e `id` (ULID) são obrigatórios.
- `repo`, `intent`, `spec`, `plan` e `task` são opcionais: preencha os que existirem. São o que permite agregar custo e falhas por SPEC, PLAN e TASK.
- Campos desconhecidos são ignorados por quem lê. Mudanças incompatíveis sobem o `v`.

## Tipos (`kind`) e `data`

| kind | Emissor | `data` |
|---|---|---|
| `attempt` | manda | `runtime`, `provider`, `model`, `family`, `tier`, `attempt_n`, `passed`, `failure` (`done_when`, `quota_exhausted`, `timeout`, `infra`, `judge`), `duration_ms`, `tokens_in`, `tokens_out`, `cost_usd`, `cost_source` |
| `receipt` | pinga (e pi-harness, `check: bdd`) | `ledger_n` e `hash` (opcionais só com `check: bdd`, que não tem ledger), `status` (`pass`, `fail`, `blocked`, `not run`), `reason_code`, `check` (`prove-red`, `verify`, `judge`, `bdd`, `plan`) |
| `transition` | ginga / manda | `entity` (`spec`, `plan`, `task`), `from`, `to`, `by` (`owner`, `system`, `<papel>`), `via` (`web`, `discord`, `telegram`, `cli`, `tui`) |
| `blocker` | manda / papéis | `blocker_id`, `question`, `options[]`, `raised_by` |
| `answer` | ginga | `blocker_id`, `answer`, `by`, `via` |
| `budget` | manda / ginga | `scope` (`task`, `plan`, `month`), `spent_usd`, `cap_usd`, `level` (`warn`, `cap`) |
| `quota` | ginga | `provider`, `used_pct`, `window_minutes`, `resets_at`, `source` |
| `handoff` | ginga | `trigger` (`boundary`, `context`, `cache`), `context_tokens`, `handoff_tokens`, `est_saved_usd`, `file` |
| `learning` | sessão / ginga | `learning_id`, `status` (`confirmada`, `descartada`, `fato`, `armadilha`), `promoted` (bool) |

## Regras

- Eventos são **fatos**, nunca comandos. Uma superfície não age lendo eventos; ela age chamando verbos.
- O event router do ginga decide as notificações a partir das regras de [05 §6](05-interface.md#6-regras-de-notificação-padrão).
- O `events.jsonl` atual do pi-harness (`kind: attempt`) é migrado mapeando `specId` → `spec`, `taskId` → `task`, `passed` e `failure` como estão. O `kind: verify` (BDD) dele vira `receipt` com `check: bdd`.

## Tipos propostos (SPEC-0003 — observabilidade operacional)

Status: proposto (SPEC-0003 `draft`). Ainda não selados no schema v1; entram via PLAN-0004. Não alteram os tipos acima.

| kind | Emissor | `data` |
|---|---|---|
| `heartbeat` | manda / executor / ginga | `runtime`, `pid`, `cpu_pct`, `alive`, `last_event_at`, `attempt_n` (opt) |
| `cost` | manda / ginga | `runtime`, `provider`, `model`, `amount_usd`, `tokens_in`, `tokens_out`, `cost_source`, `scope` |
| `judge.verdict` | manda | `verdict`, `round`, `new`, `regression`, `model`, `family`, `follow_up` |
| `sandbox.run` | manda / ginga | `profile`, `exit`, `duration_ms`, `net`, `runtime` |
| `sandbox.violation` | manda / ginga | `path`, `access`, `inside_only`, `profile`, `runtime` |
| `gate.fail` | pinga / manda | `gate`, `classification`, `reason`, `file`, `task` |
| `alert` | ginga (vigia) | `rule_id`, `severity`, `entity`, `summary`, `dedupe_key`, `actions` |
