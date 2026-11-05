---
type: task
mode: padrao
goal: "ginga install --supervisor [--enable]: só a unit systemd do supervisor + link ~/.local/bin/ginga, sem tocar nos adaptadores"
title: lacuna do corte (f) — ginga install --supervisor
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-27-bin-ginga-executavel]
tier: free
pinga_task: T119
touch: [src/install/supervisor_unit.ts, src/cli.ts, tests/install/install_supervisor_flag.test.ts, tasks/T119/PLAN.md]
done_when: "bun test tests/install/install_supervisor_flag.test.ts tests/install/install_supervisor.test.ts tests/install/install_bin_link.test.ts tests/bin_executable.test.ts"
tests_frozen: [tests/install/install_supervisor_flag.test.ts]
---
## Fazer
- Novo `src/install/supervisor_unit.ts` exportando `installSupervisorCmd(opts: { home: string; env?: Record<string,string|undefined>; enable?: boolean; systemctl?: (args: string[]) => Promise<number> }): Promise<number>`:
  - copia `contrib/systemd/ginga-supervisor.service` (caminho relativo a `import.meta.dir`, como em `install.ts`) para `<home>/.config/systemd/user/ginga-supervisor.service` (mkdir -p);
  - `ensureBinLink(home, env?.PATH)` de `./binlink.ts`; se `!onPath`, aviso no stderr;
  - `systemctl(["--user","daemon-reload"])`; com `enable`, depois `systemctl(["--user","enable","--now","ginga-supervisor.service"])`. Retorna 0 se tudo 0, senão o primeiro código ≠ 0;
  - `systemctl` padrão: roda o binário em `env.GINGA_SYSTEMCTL ?? "systemctl"` com `Bun.spawn` e devolve o exit code.
  - Não lê nem grava manifest, nem toca adaptadores (claude/opencode/pi/hermes/tuios).
- `src/cli.ts` (bloco `args[0] === "install"`): aceitar `--supervisor` (e `--enable`, só válido com `--supervisor`). Com `--supervisor`, não exige modo (`--dry-run` etc.) e chama `installSupervisorCmd({ home, env: process.env, enable })`; `--home` continua valendo. Os demais usos de `install` ficam iguais.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs. Não refatorar `install.ts`.
