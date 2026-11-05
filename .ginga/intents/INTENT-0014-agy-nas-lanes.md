---
type: intent
title: Usar a quota do agy (Antigravity) como operador e judge das lanes
source: discord
timestamp: 2026-10-30T17:00:00-03:00
status: open
---
## Pedido do dono

"No agy tem um pouco de quota, dá uma olhada lá também." Contexto: o opencode está fora (banco zerado às 15:09, ver `knowledge/research/problemas-harness-sessao-guard-2026-10-30.md`, N9) e os operadores Pi/NVIDIA free travam em ciclos de 15 min.

## Evidência (probes de 2026-10-30, `agy 1.4.8`)

- Modelos listados por `agy models`: `gemini-4-argon-{low,medium,high}`, `gemini-3.8-flash-{low,medium,high}`, `claude-opus-5-5-*`, `claude-sonnet-5-5-*`, `gpt-oss-120b-medium`.
- Respondem "ok" em 4 a 6 s: `gemini-3.8-flash-low|high`, `claude-sonnet-5-5-low`, `claude-opus-5-5-low`, `gpt-oss-120b-medium`. **Esgotado:** `gemini-4-argon-low|high` ("Individual quota reached", reseta em ~22 h). A quota é por modelo e não há leitura programática (`PROVIDER-gemini-pro.md`, `quota_check` manual).
- **Como operador** (repo git temporário, `agy -p ... --model gemini-3.8-flash-medium`): rodou o teste, achou e corrigiu o bug, rodou de novo e fez `git commit`, em 19 s. `--mode auto` não existe para esta conta (cai no modo padrão e, em `-p`, executou as ferramentas sem pedir).
- **Como judge** (`--mode plan`): não escreveu no repositório (só um `plan.md` no próprio diretório do agy, em `~/.gemini/antigravity-cli/brain/`), ou seja, passa na guarda de `judge-run.sh` (`git status` + HEAD iguais).

## Restrições

- Toda mudança passa pelo harness (TASK + RED + executor + verificação + judge). `lane.sh`, `dispatch-task.sh` e `judge-run.sh` ficam em `.ginga/bin/` (raiz sem git): trocar com `mv` atômico, nunca editar com a lane rodando.
- Judge de família diferente do executor: Gemini serve; Claude via agy **não** serve para julgar código escrito por Claude.
- Dado a terceiro: o `PROVIDER-gemini-pro.md` não diz se o plano Google AI Pro treina. Confirmar antes de mandar código do workspace; segredos nunca (guard do PLAN-0033).
- Sem gasto pago (`ALLOW_PAID=0`).

## Esboço (para o Planner virar SPEC/PLAN)

1. `lane.sh`: ramo `agy:*` no `case` do operador (`agy -p "$(cat prompt)" --model <m> --print-timeout 7200s < /dev/null`), com a mesma vigia de progresso e o mesmo `.op.lock`; `OP_MODELS` aceita `agy:gemini-3.8-flash-medium`.
2. `dispatch-task.sh`: ramo `agy:*` para executor (mesmos `restore`/`verify`).
3. `judge-run.sh`: fallback `agy -p ... --model gemini-3.8-flash-high --mode plan` antes do `opencode/gpt-6-luna`, com a mesma guarda de árvore.
4. Quota: ao ver "Individual quota reached" no log, pular o modelo e gravar `reset em` em `handoffs/.agy-quota` para o vigia não retentar antes.
5. `done_when` prováveis: teste de shell em `.ginga/bin/tests/` com `agy` falso que (a) escreve ok, (b) devolve quota esgotada, (c) tenta escrever em modo plan.
