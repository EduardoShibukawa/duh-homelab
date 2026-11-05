# Operador — lane manda, rodada 3 (2026-10-31 ~21:40) — conflito do gate em plan/0029

Escopo: só repo `manda`. Achado do gate primeiro: `2026-10-31T21:40:47-03:00 merge-gate manda plan/0029: exit 2 (conflito no merge)`.

## Fatos

- Causa: `plan/0029` (HEAD 2ee2fbd) divergiu da `main` (4435c91, PLAN-0028 mergeado) antes do merge; conflito em `src/cli.ts`, `src/run.ts` e add/add em `tasks/T167..T172/PLAN.md` (colisão de ids de task entre PLAN-0028 e PLAN-0029).
- Resolução (worktree `manda-plan-0029`, branch `plan/0029`): `git merge main` + commit `0451609`.
  - `src/cli.ts` / `src/run.ts`: resolução como união — mantidos os dois lados (PLAN-0028: replan/red/cost_cap; PLAN-0029: breaker_cli, watchAttempt ao vivo, probe, procSampler, killByPid).
  - `tasks/T167..T172/PLAN.md`: ficamos com o lado da `main` (já mergeado; receipts T167–T172 `done/pass` no ledger global).
- Verificações após o commit:
  - `git -C manda merge-tree --write-tree main plan/0029`: limpo (merge sem conflito).
  - `bun test` na worktree: **379 pass / 4 fail** — as mesmas 4 falhas preexistentes da main (`manda judge (CLI)` x2, `manda pipeline/lane` x2); nenhuma falha nova.
  - `pinga queue --json --root manda-plan-0029`: ids de task restantes no diff (`T173 T174 T306 T307 T308 T309`) todos `done` com receipt `pass`.
  - `pinga ledger verify`: ok (seq 1513).
- Receipts: nenhuma TASK nova nesta rodada; T309 (receipt pass seq 1508) segue `done`. `ready/manda.json` do PLAN-0029 continua `{"branch":"plan/0029"}` (regravado na rodada 2).
- Pendente para a lane: judge deve rodar de novo no HEAD `0451609` (o veredito atual `judge/manda.json` é do HEAD antigo 2ee2fbd, verdict pass) antes do merge-gate.

## Backlog restante (bloqueado nesta rodada)

- PLAN-0013 TASK-07: exige `PLAN-0013` no `ginga log main` → ausente.
- PLAN-0033 TASK-07: exige PLAN-0029+0032 no manda main (PLAN-0029 ainda não mergeado) e `contrib/guard/pi.ts` no ginga main → ausente.
- PLAN-0034 TASK-01: exige PLAN-0029+0032+0033-T07 no manda main → PLAN-0029 ausente.
