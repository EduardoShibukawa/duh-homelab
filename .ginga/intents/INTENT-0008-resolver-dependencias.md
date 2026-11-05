---
type: intent
title: Quando algo depende de outra coisa, o harness cria a TASK que resolve
source: cli
timestamp: 2026-10-27T23:59:00-03:00
status: open
---
## Pedido do dono

"Poderíamos criar uma forma de, se dependerem de algo, resolver algo."

## Evidência (ondas 1–2, 2026-10-27)

Quatro bloqueios precisaram do operador (Claude), embora tivessem uma resolução mecânica:

| Bloqueio | Como apareceu | Resolução feita à mão |
|---|---|---|
| Teste antigo contradiz o contrato novo (0005 TASK-09: `toBeNull` × chave ausente) | 6 tentativas com `BLOCKED:` de motivo idêntico | O Planner alinhou o teste e o congelou |
| `pinga_task` repetido entre PLANs (T58 no pi-harness) | Visto só no merge | Renumerado para T59 e selado de novo |
| Falso positivo de gate (AC-SEC: o alfabeto ULID parecia segredo) | O pre-commit barrou o commit | Fix de 1 linha dentro do `touch` e novo selo |
| Teste dependente da máquina (T26 lê o `~/.hermes`, T52 lê o estado real) | Falhou dentro da sandbox | Virou TASK-03 do PLAN-0018 |

## Hipóteses

1. **`BLOCKED:` estruturado.** O executor já escreve `BLOCKED: <motivo>`. O passo novo é classificar o motivo, com regra simples ou um modelo free: `contract_conflict`, `missing_dep`, `id_collision`, `gate_false_positive`, `env_dependency` e `other`.
2. **Resolver por classe.** Para cada classe conhecida, o harness gera uma **TASK de desbloqueio**, com `depends_on` invertido (a TASK original passa a depender dela), e roda de novo. Exemplos:
   - `contract_conflict`: a TASK do Planner alinha os testes (exige um Planner, que não pode ser o executor);
   - `id_collision`: renumerar, de forma determinística, sem LLM;
   - `env_dependency`: a TASK isola o teste com HOME falso, ou o perfil da sandbox declara o mount/fixture necessário (`needs:` no perfil, INTENT-0006).
3. **Limites:**
   - no máximo 1 desbloqueio automático por TASK e 2 por PLAN;
   - `other` e qualquer mudança de abordagem continuam indo para o humano (decisão 8 do revamp);
   - o desbloqueio nunca pode afrouxar `tests_frozen` que não são dele.
4. **Prevenção no Planner:** antes de despachar, rodar todos os testes do `done_when` contra o contrato e checar a unicidade do `pinga_task` no ledger. Isso já está nos aprendizados do handoff.

## Onde encaixa

- Na rota de falhas do **manda** (PLAN-0008: routing, escalada e judge). É uma emenda ou uma TASK nova lá.
- Os perfis de sandbox com `needs:` ficam no INTENT-0006.

## Princípio relacionado (dono, 2026-10-28)

"O harness deveria saber como chamar cada coisa, não? E sobre os modelos."

- **Nenhum padrão implícito de ferramenta ou provider.** O manda resolve runtime, provider e modelo pela config do projeto (`[runtimes]` no `.ginga/project.toml` + `models/ROUTING.md`). Ele sempre passa `--provider/--model` explicitamente e falha (fail-closed) quando não há rota. O `~/.pi` do dono não é editado.
- **Achado:** `manda/src/runtime/pi.ts:148` usa `opencode-go`/`qwen3.8-flash` como padrão, e esse provider é proibido. É a primeira TASK da onda 3 (PLAN-0008).
- **Teto de custo rígido para qualquer runtime pago** (Pi incluso), contabilizado no `paid-spend.tsv`. Hoje só o `dispatch-task.sh` mede.
