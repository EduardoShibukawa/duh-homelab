# Log — PLAN-0015

## 2026-10-27

- PLAN criado em draft pelo Planner a partir da SPEC-0001.
- 2026-10-29 aprovado pelo dono após revisão com Claude (status: approved).
- 2026-10-29 revisão: instalação já decidida (~/.local/bin); ginga web repassa ao dashboard atual até o PLAN-0012.
2026-10-29 TASK-01 opencode/qwen3.8-flash tentativa paga 1: US$0 (custo medido; sessão ses_e775de297ffebayW0dN36GPCmP; TASK acumulado US$0.000000; total das TASKs US$0.093241)
2026-10-29 TASK-01 opencode/qwen3.8-flash tentativa 1 fail BLOCKED BLOCKED: <motivo>` classificado (`contract_conflict`, `missing_dep`, `id_collision`, `gate_false_pos
2026-10-29 TASK-06 opencode/qwen3.8-flash tentativa paga 1: US$0.01508445 (custo medido; sessão ses_e7737cf94ffeT9bTO0FCWB3GuJ; TASK acumulado US$0.015084; total das TASKs US$0.108326)
2026-10-29 TASK-06 opencode/qwen3.8-flash tentativa 1 fail "reason_code":"tests_frozen_changed"
2026-10-29 TASK-06 opencode/qwen3.8-flash tentativa paga 2: US$0.02108674 (custo medido; sessão ses_e77355920ffeyi3usxPn7JUUnM; TASK acumulado US$0.036171; total das TASKs US$0.129412)
2026-10-29 TASK-06 opencode/qwen3.8-flash tentativa 2 fail BLOCKED BLOCKED: o `done_when` só passa adicionando `\"init\"` ao `CASES` de `tests/cli_verbs.test.ts` (test
2026-10-29 1509 r1 | T127 (TASK-01): verify pass seq 731 (takeover do trabalho do executor; 2 despachos blocked por __pycache__ fora do touch); feat ac32128
2026-10-29 1509 r1 | TASK-06 criada (T128, fix cli_verbs frozen T121/T123 via TASK nova): RED re-selado f8b09fc com caso init no CASES; 2 despachos qwen3.8-flash blocked (US$0,036 total); operador fechou o delta em src/verbs/init.ts dentro da TASK; verify pass seq 736; feat 72222e8; bun test 431/0; ledger ok 736
2026-10-29 TASK-03 opencode/qwen3.8-flash tentativa paga 1: US$0 (custo medido; sessão ses_e770a5982ffeuToEdeFpdzeJ2V; TASK acumulado US$0.000000; total das TASKs US$0.129412)
2026-10-29 TASK-03 opencode/qwen3.8-flash tentativa 1 pass
2026-10-29 TASK-07 opencode/qwen3.8-flash tentativa paga 1: US$0.01272915 (custo medido; sessão ses_e76ee89f7ffe0uxsrFQZZV9sYB; TASK acumulado US$0.012729; total das TASKs US$0.142142)
2026-10-29 TASK-07 opencode/qwen3.8-flash tentativa 1 fail "reason_code":"scope_drift"
2026-10-29 TASK-07 opencode/qwen3.8-flash tentativa paga 2: US$0.010879579999999998 (custo medido; sessão ses_e76ed0032ffeJOYDzolZmsSpDb; TASK acumulado US$0.023609; total das TASKs US$0.153021)
2026-10-29 TASK-07 opencode/qwen3.8-flash tentativa 2 pass
2026-10-29 TASK-05 opencode/qwen3.8-flash tentativa paga 1: US$0.020874069999999998 (custo medido; sessão ses_e76e331bbffezPvitSWEKTfUmS; TASK acumulado US$0.020874; total das TASKs US$0.173895)
2026-10-29 TASK-05 opencode/qwen3.8-flash tentativa 1 fail "reason_code":"scope_drift"
2026-10-29 TASK-05 opencode/qwen3.8-flash tentativa paga 2: US$0.024093770000000004 (custo medido; sessão ses_e76df31a8ffe55zYDAqRXX41XG; TASK acumulado US$0.044968; total das TASKs US$0.197989)
2026-10-29 TASK-05 opencode/qwen3.8-flash tentativa 2 pass
2026-10-29 1636 r5 | T129 (TASK-02): cadeia já verde no base (T127+PLAN-0010/0011) — prove-red `test_passed_on_base` (blocked) → verify pass sem despacho (cobertura; precedente T76); selada em worktree temporária no base c860608 (evitou scope_drift de commits posteriores), removida em seguida
2026-10-29 1636 r5 | T130 (TASK-03): 1ª prova `inconclusive` (RED por import); frozen reescrito como falha de asserção; RED selado c7dd289; despacho qwen3.8-flash 1ª tentativa pass US$0; verify pass (8/8, paridade com o bin/homelab real); feat 7b16d86; suíte: 9 fail em cli_verbs (colateral → TASK-07)
2026-10-29 1636 r5 | T131 (TASK-07, correção nova): CASES dos 8 verbos ops + stubBin PATH + via/bin no comparador; RED verdadeiro achou bug real: Bun.which sem 2º argumento usa o PATH do boot (in-process resolvia binário real); despacho 2ª tentativa pass US$0,024 (1ª fail scope_drift); verify pass; feat ab0b823
2026-10-29 1636 r5 | T132 (TASK-05): RED selado 5862a17 (gingaCompat entra no commit base); despacho 2ª tentativa pass US$0,045; verify pass: doctor --json → {schema_version, records}, probes `--version --json` por bin, obrigatório fora da faixa broken/exit 1, ausente unverified, gira opcional degraded; pinga real não tem --version → unverified na máquina; feat c99270a; suíte: 8 fail nos frozen doctor (colateral → TASK-08)
2026-10-29 1636 r5 | T133 (TASK-08, correção nova): doctor.test.ts e doctor_hooks_drift.test.ts adaptados ao wrapper + --only não roda probes de versão (semântica selada da T132); prove-red `test_passed_on_base` → verify pass (1ª tentativa scope_drift por __pycache__ do teste hermes; limpo); commit 73a860c
2026-10-29 1636 r5 | fim: bun test 456/0 (1846 expects); ledger ok 763; fila T127–T133 done/pass; ready/ginga.json gravado (branch plan/0015); backlog [x]; worktree limpa. TASK-04 (raiz, sem git) segue com o Claude
- 2026-10-29T16:42:12-03:00 judge-run ginga: Codex sem cota, fallback opencode/gpt-6-luna (Zen)
- 2026-10-29T16:43:10-03:00 merge-gate ginga plan/0015: exit 0 (mergeado c854c0d)
- 2026-10-29 TASK-01/02/03/05 (+07/08) mergeadas (c854c0d). Falta a TASK-04 (bin/homelab vira shim, raiz sem git): fica para uma sessão do Claude.
