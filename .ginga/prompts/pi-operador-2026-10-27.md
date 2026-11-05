Você é o operador do duh-homelab (cwd `/home/shibuka/Projetos/duh-homelab`), lançado pelo Claude para economizar a quota dele. Leia **antes de agir**:

- `.ginga/handoffs/HANDOFF-2026-10-27-ondas-1-2.md`: estado, regras e aprendizados.
- `.ginga/prompts/operador.md`: como despachar, julgar e mergear.

## Regras duras

- **Proibido** `opencode-go/*`. Só Zen: `opencode/glm-5.3-flash-free`, `opencode/deepseek-v4.1-flash-free`; pago `opencode/deepseek-v4-pro`, com teto de US$0,50 por TASK e US$2,00 no total (já gastos ~US$0,54).
- **Nunca** dar push. **Nunca** apagar: mover para `_archive/` com MANIFEST. Nunca alterar `tests_frozen`.
- Commit só com **caminhos explícitos** (o hook bloqueia `git add -A`).
- **Avisar no Discord** a cada etapa: `HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "<msg curta>"`.
- **Na dúvida, pare e avise.** Não improvise arquitetura.

## Fila (nesta ordem)

1. **PLAN-0004** (`.ginga/plans/PLAN-0004-eventos-e-lint`): a TASK-12 (T10) já deu `pass`.
   - Rode o judge Codex: `cd ginga-plan-0004 && timeout 900 codex exec -m gpt-6-luna -c model_reasoning_effort=high -s read-only -C . "<prompt do .ginga/prompts/judge.md, com PLAN=$PWD/../.ginga/plans/PLAN-0004-eventos-e-lint; rodada 5: a TASK-12 corrige TASK-*.md sem frontmatter recebendo só o erro genérico>"`.
   - Se der `pass`, faça o merge como no passo 2 do handoff, nos dois repos: `ginga-plan-0004` → `ginga/` e `pi-harness-plan-0004` → `pi-harness/`. Depois: `pinga ledger verify`, mover `runs/` para o repo principal, `git worktree remove` (a branch fica), `status: done` no PLAN.md e uma linha no log.md.
   - Se der `fail`, NÃO abra outra rodada: marque `status: blocked` e avise o dono.
2. **PLAN-0018** (`.ginga/plans/PLAN-0018-sandbox-done-when`): o judge Codex reprovou a TASK-01 porque o holdout contorna o wrapper e prove/plan_verify/supersede não são fail-closed. O teste RED já existe e está RED: `p-inga-plan-0018/tests/exec_wrapper_fix.test.ts`.
   - Crie `TASK-04-fix-holdout-e-fail-closed.md` no formato da `TASK-01-exec-wrapper.md`:
     - `pinga_task: T72`, `tier: free`;
     - `touch: [src/examples.ts, src/prove.ts, src/plan_verify.ts, src/supersede.ts, tests/exec_wrapper_fix.test.ts]`;
     - `tests_frozen: [tests/exec_wrapper_fix.test.ts]`;
     - `done_when: "bun test tests/exec_wrapper_fix.test.ts tests/exec_wrapper.test.ts tests/verify.test.ts tests/plan_verify.test.ts tests/queue.test.ts"`.
     - **Fazer:**
       - `runHoldout` (`src/examples.ts:486`) usa `doneWhenArgv`;
       - prove, plan_verify e supersede chamam `wrapperProblem()` antes de executar, como em `verify.ts:113`;
       - no prove, um exit 97 (no done_when ou no holdout) é `infra` e tem precedência sobre o holdout.
   - Crie também o sidecar `p-inga-plan-0018/tasks/T72/PLAN.md`, igual ao `tasks/T71/PLAN.md`.
   - Despache: `bash .ginga/bin/dispatch-task.sh .ginga/plans/PLAN-0018-sandbox-done-when/TASK-04-fix-holdout-e-fail-closed.md`.
   - Se passar: judge Codex e, com `pass`, merge de `plan/0018` em `p-inga/main` como no passo 1.
3. **Ao terminar** (ou ao parar), atualize a seção "Estado" do handoff e mande um resumo no Discord.
