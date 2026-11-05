---
type: task
mode: padrao
goal: "ginga serve vira supervisor: agenda e (re)inicia as lanes (uma por repo, com o manda pipeline do PLAN-0022), reinicia com backoff e para quando não há pendência; e ginga install passa a incluir a unidade systemd do supervisor"
title: supervisor no ginga serve + unit systemd no install
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-02-watch-rules]
tier: medium
pinga_task: T30
touch: [src/serve.ts, src/install/, contrib/systemd/, tests/serve_supervisor.test.ts, tasks/T30/PLAN.md]
done_when: "bun test tests/serve_supervisor.test.ts"
tests_frozen: [tests/serve.test.ts, contrib/systemd/]
---
## Fazer
- Supervisor no `ginga serve` (nada depende de uma sessão de agente estar aberta): lista de lanes (repo + comando), reinício com backoff em falha e parada quando o repo não tem pendência no pinga; heartbeat/lane.round emitidos em $GINGA_EVENTS quando definida.
- Unit `ginga-supervisor` (service + timer quando fizer sentido) instalada pelo `ginga install` (padrão do ginga-tick do PLAN-0010); arquivos em contrib/systemd/.
- Teste novo `tests/serve_supervisor.test.ts` sem processos reais: fixture de comandos falsos (exit/saída controlada) cobre restart em falha, backoff crescente e parada sem pendência.
## Não fazer
- Não tocar tests_frozen `tests/serve.test.ts`; sem redes, sem repos reais, sem systemd real no teste (só os arquivos gerados); sem executar regras do vigia (TASK-02 já cobre).
## Contexto
- PLAN-0023 §Desenho (camada 2); o supervisor sobrevive a qualquer sessão (unidade systemd via ginga install).
