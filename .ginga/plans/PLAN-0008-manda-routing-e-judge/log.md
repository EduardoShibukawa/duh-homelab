# Log — PLAN-0008

## 2026-10-27

- PLAN criado em draft pelo Planner a partir da SPEC-0001.

## 2026-10-28

- Emenda (INTENT-0008): seção "desbloqueio automático" adicionada ao PLAN.md (classes de `BLOCKED:`, TASKs de desbloqueio e limites).

## 2026-10-28 (passada RED)

- passada RED: TASK-01 → T9 (manda, teste RED acrescentado a `tests/runtime_pi_opencode.test.ts`), prove-red RED. TASK-03 → T10, TASK-04 → T11, TASK-05 → T12 (manda; escritos e provados por passada anterior no mesmo dia, só faltavam as linhas `pinga_task:`), RED. TASK-06 → T74 (p-inga), RED. TASK-07 → T13 e TASK-08 → T14 (manda), RED. TASK-02 sem `tests_frozen`.
- Os ids T9–T12 do manda já estavam no ledger (passada anterior) e foram reaproveitados; T13+ são novos. Os testes antigos do `done_when` do T74 (`tests/judge.test.ts`) passam hoje e não contradizem o contrato novo.
- Contrato escolhido nos testes (a TASK não definia):
  - TASK-07: `judgePlan` de `src/judge.ts`; bundle = `SPEC.md?`, `PLAN.md`, `diff.patch`, `receipts.json` (`[commands].receipts`, padrão `pinga queue --json`), `metrics.json` (dos `attempt` do PLAN em `$GINGA_EVENTS`); famílias dos executores vêm dos `attempt`, a do Planner de `[runtimes].planner`; selo por `[commands].judge_seal` com `{plan} {file} {model} {planner}`.
  - TASK-08: `planFromArtifact` de `src/plan.ts`; resposta do Planner em blocos `=== FILE: <nome> ===`; pasta `PLAN-<N+1>-<slug>`; `ginga lint <pasta>` roda numa cópia de staging; `status: draft` forçado.
2026-10-28 TASK-01 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-28 TASK-01 (T9) opencode/glm-5.3-flash-free tentativa 1 pass (pi.ts fail-closed: sem provider/modelo → infra com mensagem citando [runtimes]). Custo US$0.
- 2026-10-28 TASK-04 precisa de replan: ROUTING 2026-10-28 proíbe escalada automática para strong e tira o nemotron (PLAN-0019).
- 2026-10-28 (Claude, auditoria): merge b91c772 revertido em 3c89e10. Foi mergeado sem judge e quebrou tests/e2e/two_runtimes.test.ts (4 fail; passava em 0473083). O trabalho segue em plan/0008 (61caffa). Próximo: TASK de correção (rotas explícitas no e2e sem alterar o teste congelado, ou ajuste do run.ts) + judge Codex + merge.
- 2026-10-28T08:44:05-03:00 merge-gate manda plan/0008: exit 10 (sem veredito em /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0008-manda-routing-e-judge/judge/manda.json)
- 2026-10-28T08:44:06-03:00 merge-gate manda plan/0008: exit 11 (1 item(ns) com regression=true)
- 2026-10-28T08:44:09-03:00 merge-gate manda plan/0008: exit 13 (falha nova na branch: (fail) um PLAN, dois runtimes, fora do Pi > a ordem do DAG vale: TASK-02 só roda depois da TASK-01 (fail) um PLAN, dois runtimes, fora do Pi > cada runtime é subprocesso no worktree da TASK; o pi roda como runtime (--mode json -p), nunca como host (fail) um PLAN, dois runtimes, fora do Pi > dois attempt com runtime diferente e passed true )
- (as 3 linhas merge-gate acima são o teste do gate com veredito falso; o exit 13 confirma a regressão do e2e)
- 2026-10-28T08:53:14-03:00 merge-gate manda plan/0008: exit 2 (conflito no merge)
- 2026-10-28T08:54:52-03:00 Claude: merge -s ours main em plan/0008 (árvore inalterada), para o diff main...HEAD voltar a conter o PLAN-0008 inteiro depois do revert 3c89e10. Judge e gate rodam de novo.
- 2026-10-28T09:24:55-03:00 merge-gate manda plan/0008: exit 12 (sem receipt done: T11 T13)
- 2026-10-28T09:34:15-03:00 merge-gate manda plan/0008: exit 11 (1 item(ns) com regression=true)
- 2026-10-28T09:49:00-03:00 merge-gate manda plan/0008: exit 0 (mergeado 01ac573)
- 2026-10-28T22:47:30-03:00 merge-gate manda plan/0008: exit 2 (main com mudancas nao commitadas)
- 2026-10-28T22:48:16-03:00 merge-gate manda plan/0008: exit 0 (mergeado 42f4057)

- 2026-10-28 (rodada 2): TASK-09 mergeado via merge-gate (gate 0, HEAD 42f4057). bun test main verde. Worktree removida. Judge verdict fail com 1 achado novo (TASK-09 padrão implícito no run.ts) sem regressão; follow-up.
