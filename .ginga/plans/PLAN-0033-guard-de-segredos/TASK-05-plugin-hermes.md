---
type: task
mode: padrao
goal: "o plugin Hermes registra pre_tool_call (retorna {action:block,message} para cat .env e cat ~/.pi/agent/auth.json, None para cat README.md) e transform_tool_result (redige chave), via bun src/guard/cli.ts, com falha fechada"
title: Plugin Hermes do guard
plan: PLAN-0033-guard-de-segredos
repo: ginga
pinga_task: T304
depends_on: [TASK-02-run-e-cli]
tier: free
touch: [contrib/guard/hermes/guard_segredos/__init__.py, contrib/guard/hermes/guard_segredos/plugin.yaml, contrib/guard/hermes/test_guard.py]
done_when: "python3 -B -I -m unittest discover -s contrib/guard/hermes -p 'test_*.py'"
tests_frozen: [contrib/guard/hermes/test_guard.py]
---
## Fazer
- `plugin.yaml` + `register(ctx)` com `ctx.register_hook("pre_tool_call", …)` e `("transform_tool_result", …)`. O casador é o CLI (`bun <repo>/src/guard/cli.ts check|redact`, caminho resolvido por `realpath` do próprio arquivo; sobrescreve por `GINGA_GUARD_CLI`/`GINGA_GUARD_BUN`).
- `pre_tool_call(tool_name, args, **kw)`: inerte sem `GINGA_GUARD_LANE` ou com `GINGA_GUARD=off`; exit 0 → `None`; exit ≠ 0 ou exceção/timeout (5 s) → `{"action":"block","message":"guard-segredos: …"}`.
- `transform_tool_result(tool_name, args, result, **kw)`: devolve `str` redigida só se mudou, senão `None`.
## Interface
- Protótipo: [ref/ginga/contrib/guard/hermes/guard_segredos/__init__.py](../ref/ginga/contrib/guard/hermes/guard_segredos/__init__.py).
- **Retorno do bloqueio é `dict` com `message`** (`hermes_cli/plugins.py:1964-1983`). Uma `str` é ignorada pelo núcleo.
## Não fazer
- Não tocar tests_frozen. Não reimplementar as regras em Python. Não editar `~/.hermes/**` nem `config.yaml` de perfil: ativar o plugin é ação do dono (`plugins.enabled`).
## Contexto
- `-B` no `python3` do `done_when`: a sandbox usa `--clearenv` e perde o `PYTHONDONTWRITEBYTECODE`; sem ele o `__pycache__` vira `scope_drift`.
- Achado de passagem: o `pre_tool_guard` do plugin `pinga-harness` retorna `str`; pelo código acima ele é ignorado, então o Payload Guard G2 do Hermes não bloqueia nada hoje. Fora deste PLAN; vira TASK própria no p-inga se o dono quiser.
