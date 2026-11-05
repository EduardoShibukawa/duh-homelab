# Log — PLAN-0006

## 2026-10-27

- PLAN criado em draft pelo Planner a partir da SPEC-0001.

## 2026-10-28

- passada RED: TASK-02 → T11 (ginga), prove-red RED; TASK-03 → T12 (ginga), prove-red RED. TASK-01 e TASK-04 não têm `tests_frozen` (sem T<N> nesta passada).
- Nota do Planner: `ginga-plan-0006` nasceu do commit `chore: init` (sem `bin/ginga.ts` nem o código do PLAN-0004, que ainda não foi mergeado). Hoje o RED vem de "bin/src inexistentes"; para o RED ser pelo motivo certo, o executor deve rebasear `plan/0006` sobre o PLAN-0004 e rodar a TASK-01 (cópia do install) antes. Os testes só usam a CLI (`bin/ginga.ts`).
- Contrato escolhido nos testes (a TASK não definia): `[install] plugin` e `[install] source` vivem em `.ginga/project.toml` do cwd; marketplace = `<plugin>-local`; sem fonte ou sem `plugin` → exit 2 citando `GINGA_PLUGIN_SOURCE`/`[install]`; `ginga doctor` não leva as checagens `manifest`/`llm` (os testes não exigem nem proíbem).
2026-10-28 TASK-02 opencode/deepseek-v4.1-flash-free quota/rate limit (Free usage limit); pula para o próximo modelo, não conta como tentativa
2026-10-28 TASK-02 opencode/nemotron-3-ultra-free tentativa 1 fail "reason_code":"command_failed"
2026-10-28 TASK-02 opencode/nemotron-3-ultra-free tentativa 2 fail "reason_code":"command_failed"
2026-10-28 TASK-02 opencode/deepseek-v4-pro pago NÃO tentado (paid_tries=0, estimativa=2.0166, gasto TASK=0.000000, total=3.526930, folga=-1.5269)
2026-10-28 TASK-02 opencode/glm-5.3-flash-free quota/rate limit (Free usage limit); pula para o próximo modelo, não conta como tentativa
2026-10-28 TASK-01 opencode/glm-5.3-flash-free quota/rate limit (Free usage limit); pula para o próximo modelo, não conta como tentativa
2026-10-28 TASK-01 opencode/glm-5.3-flash-free quota/rate limit (Free usage limit); pula para o próximo modelo, não conta como tentativa
2026-10-28 TASK-01 opencode/glm-5.3-flash-free quota/rate limit (Free usage limit); pula para o próximo modelo, não conta como tentativa
2026-10-28 TASK-01 opencode-go/beam-free tentativa 1 pass
2026-10-28 TASK-02 opencode/glm-5.3-flash-free quota/rate limit (Free usage limit); pula para o próximo modelo, não conta como tentativa
2026-10-28 TASK-01 opencode-go/beam-free tentativa 1 pass
2026-10-28 TASK-02 opencode-go/beam-free tentativa 1 pass
2026-10-28 TASK-03 opencode/glm-5.3-flash-free tentativa 1 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode/glm-5.3-flash-free tentativa 2 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode-go/beam-free tentativa 3 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode-go/beam-free tentativa 4 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode-go/iceman-contributor-free tentativa 5 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode-go/iceman-contributor-free tentativa 6 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode/deepseek-v4.1-flash-free tentativa 7 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode/deepseek-v4.1-flash-free tentativa 8 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode/glm-5.3-flash-free tentativa 1 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode/glm-5.3-flash-free tentativa 2 fail "reason_code":"scope_drift"
2026-10-28 TASK-03 opencode-go/beam-free tentativa 3 fail "reason_code":"scope_drift"
- 2026-10-28T14:27:00-03:00 merge-gate ginga plan/0006: exit 0 (mergeado 0563295)
- 2026-10-29 reaberto (done → approved) pelo Claude: a TASK-04 nunca rodou (achado da análise de cobertura da visão 02). Na lane p-inga.
2026-10-29 TASK-04 opencode/qwen3.8-flash tentativa paga 1: US$0 (custo medido; sessão ses_e789559aaffevrk8pApEP5bE7r; TASK acumulado US$0.000000; total das TASKs US$0.034100)
2026-10-29 TASK-04 opencode/qwen3.8-flash tentativa 1 fail "reason_code":"scope_drift"
- 2026-10-29 09:0x lane p-inga r2 (operador): tentativas 1–2 do dispatch (qwen3.8-flash) morrem em scope_drift estrutural (o guard não aceita touch de diretório; restore não limpa índice) e o done_when de suíte inteira não passa o wrapper bwrap nem na base (root_flag/ux_t52 pré-existentes); operador matou a escada e implementou como executor dentro da TASK (regra 'se o executor não resolver'). RED materializado b0b5c39 (prove-red exit 8 not run/infra — aceito, precedente T04 gira-g); touch exato 05120f2; merge main bf1bc35 (autostash; main havia absorvido T77/T79 às 08:56); `pinga verify tasks/T78/PLAN.md --base HEAD` = pass (receipt 6dc8018b, attempts 6); suíte 437/0; `rg pi-harness src bin web` = 0; commit feat b6b7541; `ready/p-inga.json` gravado (plan/0006)
- 2026-10-29T09:17:30-03:00 merge-gate p-inga plan/0006: exit 0 (mergeado d65549d)
- 2026-10-29 status: done (todas as TASKs mergeadas pelo merge-gate).
