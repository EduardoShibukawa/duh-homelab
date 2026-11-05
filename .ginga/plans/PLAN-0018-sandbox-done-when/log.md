- 2026-10-27 PLAN criado (opção A aprovada no INTENT-0006). Teste RED tests/exec_wrapper.test.ts: 6/6 fail; baseline sem wrapper passa e com wrapper inexistente hoje roda nu (exit 0).
2026-10-27 TASK-01 opencode/glm-5.3-flash-free tentativa 1 pass
- 2026-10-27 TASK-02 (operador): sandbox-done-when.sh validado; ginga 98/0, manda 74/0, p-inga 432/2 (T26 lê ~/.hermes real, T52 estado real) → TASK-03. dispatch exporta o wrapper para ginga e manda.
2026-10-28 TASK-04 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-28 TASK-05 opencode/glm-5.3-flash-free tentativa 1 pass
- 2026-10-27 TASK-04 (T72) opencode/glm-5.3-flash-free tentativa 1 pass (holdout via doneWhenArgv + wrapperProblem em prove/plan_verify/supersede + precedência do infra no prove).
- 2026-10-27 judge Codex rodada 2: fail simples — supersede não selava receipt blocked/infra no exit 97; sidecars tasks/T<N>/PLAN.md marcados como "fora do touch" (falso positivo, artefato do operador); teste frozen fraco (regex). → TASK-05 (T73).
- 2026-10-27 TASK-05 (T73) opencode/glm-5.3-flash-free tentativa 1 pass (supersede sela blocked/infra no exit 97).
- 2026-10-27 judge Codex rodada 3: fail simples — (1) verify.ts holdout com exit 97 cai em overfit_holdout/fail, não blocked/infra; (2) prove.ts sela "not run" (não "blocked") no exit 97. Limite de 2 rodadas de fix atingido → status: blocked, aguardando dono.
2026-10-28 TASK-06 (operador, bash no duh-homelab): pi-run.sh <teto> <pi args...> com teto rígido de custo (soma message.usage.cost.total, dedupe por responseId, mata no teto → exit 124) + grava paid-spend.tsv. Teste RED em tests/pi-run.test.sh (mock pi via PATH). Teste real: pi-run.sh 0.01 --provider opencode --model deepseek-v4-pro -p "responda ok" → custo US$0.00899232 (abaixo do teto).
- 2026-10-28 passada RED (Planner Pi, rodada 3 fix): TASK-07 → T75 (p-inga). RED demonstrado à mão: exec_wrapper_fix3 2 fail (prove-red wrapper 97 → "not run" em vez de blocked; verify.ts holdout sem tratamento de exit 97).
2026-10-28 TASK-07 opencode/deepseek-v4-pro tentativa paga 1: US$0.24168951 (custo medido; sessão ses_e7e0cecbdffejAPiUCnHVolNGx); pass (free esgotado, despacho manual)
- 2026-10-28T08:53:50-03:00 merge-gate p-inga plan/0018: exit 11 (2 item(ns) com regression=true)
- 2026-10-28T09:35:03-03:00 merge-gate p-inga plan/0018: exit 11 (1 item(ns) com regression=true)
- 2026-10-28T09:50:36-03:00 merge-gate p-inga plan/0018: exit 11 (1 item(ns) com regression=true)
- 2026-10-28T09:57:27-03:00 merge-gate p-inga plan/0018: exit 0 (mergeado 6eb9c7e)
