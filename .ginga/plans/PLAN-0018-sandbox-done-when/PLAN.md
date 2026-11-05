---
type: plan
title: done_when do pinga roda em sandbox via PINGA_EXEC_WRAPPER (opção A)
intent: INTENT-0006-sandbox-e-code-mode
kind: change
status: done
repos: [p-inga, duh-homelab]
depends_on: [PLAN-0005-pinga-task-e-plan]
done_when: "cd p-inga && bun test"
---
## Objetivo

Opção A aprovada pelo dono (INTENT-0006): o `done_when` passa a rodar dentro de um wrapper (bwrap). Assim, o código que o executor escreveu é testado sem acesso a `~`, segredos e outros repos. O pinga fica **fora** da sandbox, porque precisa do git e do ledger.

## Abordagem

- **`src/exec.ts` → `doneWhenArgv(cmd, root, env)`:** sem `PINGA_EXEC_WRAPPER`, devolve `sh -c <cmd>`; com ele, devolve `<wrapper> <root> sh -c <cmd>`. Os quatro lugares que executam `done_when` (verify, prove, plan_verify, supersede) passam a usá-lo.
- **Fail-closed:** se o wrapper está configurado mas não existe ou não é executável, o `done_when` não roda. Se o wrapper sai com 97 (sandbox indisponível), o receipt fica `blocked` com `reason_code: infra`, nunca `pass` nem `fail`.
- **O wrapper concreto** (`.ginga/bin/sandbox-done-when.sh`) reaproveita o `sandbox-run.sh`, com rede desligada. O `dispatch-task.sh` exporta a variável.

## TASKs

1. [TASK-01](TASK-01-exec-wrapper.md): `doneWhenArgv` + fail-closed + 97→infra no pinga (T71)
2. TASK-02 (operador, bash no duh-homelab): `sandbox-done-when.sh` + matriz de validação (não lê `~/.ssh` nem `~/.hermes`; sem rede) + `dispatch-task.sh` usando o wrapper

## Riscos

- `bun test` dentro do bwrap precisa da toolchain do mise em modo somente leitura. O `sandbox-run.sh` já monta isso para o opencode e o node; falta incluir o bun.
- O holdout (I13/I14) e o baseline também executam o `done_when` e precisam passar pelo mesmo caminho.

## Estado da TASK-02 (operador, 2026-10-27)

`.ginga/bin/sandbox-done-when.sh` passou na matriz:

- responde ok;
- `~/.ssh`, `~/.hermes` e outros repos ausentes;
- sem rede (inclusive a porta 49374);
- `.git` somente leitura, também dentro da raiz;
- identidade do git só por variáveis.

Suítes dentro da sandbox: ginga 98/0 e manda 74/0. O p-inga ficou em 432/2: o T26 lê o `~/.hermes` real e o T52 lê o estado real da máquina. Por isso o `dispatch-task.sh` só exporta o `PINGA_EXEC_WRAPPER` para `SANDBOX_REPOS="ginga manda"`.

3. **TASK-03 (a criar):** desacoplar `tests/discord.test.ts` (T26) e `tests/ux_t52_hardening.test.ts` (W12) do HOME real, usando HOME falso como no `tests/helpers/home.ts`. Depois, incluir o p-inga em `SANDBOX_REPOS`.
