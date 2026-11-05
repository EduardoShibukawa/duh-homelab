---
type: plan
title: Guarda de escopo no Pi (tool_call bloqueia escrita fora do touch)
intent: INTENT-0012-jev-e-guarda-de-escopo
spec: SPEC-0004-jev-classificador-e-guarda-de-escopo
kind: change
status: approved
repos: [manda]
depends_on: [PLAN-0008-manda-routing-e-judge]
done_when: "cd manda && bun test"
---
## Objetivo

Hoje o `scope_drift` é descoberto **depois**: o executor escreve fora do `touch`, o `pinga verify` reprova, a tentativa é perdida (e consome cota de request em tier com teto). A guarda impede a causa: uma extensão do Pi no evento `tool_call` bloqueia `edit`/`write` cujo caminho está fora do `touch` da TASK ou dentro de `tests_frozen`, e devolve o motivo ao modelo (`{ block: true, reason }`), que corrige na mesma tentativa. É **determinística, sem Jev e sem terceiro**; não precisa de decisão do dono sobre dados ou dinheiro.

Dos ~171 registros de falha dos `log.md`: `scope_drift` 24, `tests_frozen_changed` 5. A meta (SPEC-0004) é cair à metade ou menos, medida depois de 20 TASKs pelo Pi.

## Decisões

- **Por execução, não global (ligação no PLAN-0034):** o runtime `pi` do manda passa `pi -p -e <guarda>` e as variáveis `MANDA_SCOPE_TOUCH` / `MANDA_SCOPE_FROZEN` (JSON). Nada em `~/.pi` muda; fora de uma TASK a guarda não existe.
- **Fail-open para bug próprio:** a doc do Pi diz que falha de handler de `tool_call` **bloqueia** a tool. Um bug na guarda travaria a lane (`infra_stuck` só após 15 min). Por isso o handler tem `try/catch` total: erro interno → libera, emite `scope.guard_error` e segue. Bloqueio só por regra explícita.
- Só `edit` e `write` (têm `path`). `bash` pode escrever em qualquer lugar; a defesa dele continua sendo o `pinga verify` e o `restore` do `dispatch-task.sh`. Além disso, a guarda recusa no `bash` os padrões de risco que a SPEC-0002 já lista (`git add -A`, `--no-verify`, `push --force`).
- Cobre o Pi. opencode e Claude ficam fora (plugin deles, PLAN futuro).

## TASKs

1. [TASK-01](TASK-01-decisao-de-escopo.md): `decideToolCall` (função pura)
2. [TASK-02](TASK-02-casamento-de-caminho.md): caminho seguro (`..`, symlink, glob)
3. [TASK-03](TASK-03-extensao-pi.md): extensão `tool_call` com fail-open
4. [TASK-05](TASK-05-evento-scope-block.md): eventos `scope.block` e `scope.guard_error`
5. [TASK-04](TASK-04-guarda-usa-resolve-e-matches.md): `decideToolCall` usa `resolvePath`/`matchesAny` (correção do achado do judge na TASK-01)

(A antiga TASK-04, runtime `pi` passa `-e` e as variáveis, foi movida em 2026-10-30 para o [PLAN-0034](../PLAN-0034-pi-liga-guarda-de-escopo/PLAN.md): depende do PLAN-0029 e editava o mesmo arquivo; dentro deste PLAN travava o merge. **Este PLAN entrega os blocos (decisão, caminho, extensão, eventos); a ligação ao `pi -p` é do 0034.**)

Ordem: (01, 02) → 03 → 05; 06 depois de 01 e 02 (pode ir junto de 03/05).

## Interface (definida no plano; mudar = replan)

```ts
// src/runtime/scope_guard.ts (TASK-01, 02)
export type Scope = { touch: string[]; frozen: string[]; root: string };
export type ToolCall = { tool: string; input: Record<string, unknown> };
export type Decision = { allow: true } | { allow: false; rule: "outside_touch" | "frozen" | "bash_refused" | "path_escape"; reason: string };
export function decideToolCall(call: ToolCall, scope: Scope): Decision;
// src/runtime/pi_scope_guard.ts (TASK-03): export default function (pi: ExtensionAPI): void
```

## Riscos

- Falso positivo (TASK legítima precisa de arquivo que o `touch` esqueceu): vira `outside_touch` e o executor para; o motivo cita o `touch` e orienta a emitir `BLOCKED:` pedindo ajuste. Pior que antes? Não: antes dava `scope_drift` no verify; agora falha mais cedo e com a mensagem certa.
- `touch` com diretórios e globs: o teste cobre `tests/fixtures/x/` (prefixo) e `src/**`.
- Arquivos que a ferramenta gera por si (`bun.lock`, `__pycache__`): lista pequena de ignorados em dados (`scope_ignore.json`), não no código.
- A API de extensão do Pi (`tool_call` → `{block, reason}`) é a de 1.4.0; o teste usa um `pi` falso, e a TASK-03 faz uma checagem de tipo contra o pacote instalado.
