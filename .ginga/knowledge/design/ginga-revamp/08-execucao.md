# 08 — Como executar a SPEC-0001 com a quota que existe

> Status: proposta (2026-10-27). Os prompts ficam em [`.ginga/prompts/`](../../../prompts/).

## 1. O problema

São 12 PLANs e 78 TASKs: 33 `free`, 43 `medium` e 2 `strong`. O orquestrador que despacharia essas TASKs (manda + ginga tick) é **justamente o que estamos construindo**, então o começo precisa ser manual. Por isso a execução tem três fases: o dono despacha no começo, o manda despacha a partir do PLAN-0007 e o `ginga tick` a partir do PLAN-0010.

## 2. Quem gasta o quê

O recurso escasso é o **Claude Pro**. O resto tem folga ou é grátis.

| Recurso | Papel nesta SPEC | Volume estimado |
|---|---|---|
| **Claude Pro** | Planner: a passada RED de cada PLAN (escreve os `tests_frozen`), replan quando bloqueia e, por último, fallback do `strong` | ~12 passadas + replans |
| **OpenCode Go** | Executor `medium` e `strong` | ~45 TASKs |
| **Zen `-free`** | Executor `free`; se falhar, opencode-go cheap | ~33 TASKs |
| **AGY (Gemini)** | Verifier Judge, **1 vez por PLAN** (não por TASK) | 12 |
| **Codex (Go)** | Judge reserva; segunda opinião no PLAN-0005 (pinga) e no 0008 (judge) | 2–4 |
| **Zen pago** | Só se o Go esgotar; teto do ROUTING | ~0 |
| **local-llama** | Último recurso para `free` | ~0 |

**Regra de família, para nunca violar o judge cego:** os executores usam só as famílias **kimi, glm, qwen, deepseek e mimo**. Nada de `gemini-*`, `gpt-*` ou `claude-*` via opencode-go. Assim o AGY (google) e o Codex (openai) são sempre de outra família, e o Planner (anthropic) também.

### Modelos por tier (fase 0)

| Tier | 1ª | 2ª (2 falhas) | 3ª |
|---|---|---|---|
| `free` | `opencode/glm-5.3-flash-free` | `opencode-go/qwen3.8-flash` | `opencode-go/kimi-k3` (sobe para medium) |
| `medium` | `opencode-go/kimi-k3` | `opencode-go/glm-5.3` | `opencode-go/qwen3.8-max` |
| `strong` | `opencode-go/kimi-k3.1-pro` | `opencode-go/deepseek-v4-pro` | Claude (pede OK) |

## 3. Ondas

Cada onda tem lanes paralelas **por repo**. No `p-inga/`, uma TASK de cada vez (o `src/cli.ts` é tocado por 0005, 0006, 0008 e 0010).

| Onda | PLANs | Quem despacha | Pré-requisito |
|---|---|---|---|
| 1 | 0004 (ginga: eventos + lint) | dono (manual) | aprovar 0004; `git init ginga/` |
| 2 | 0005 (p-inga) ‖ 0007 (manda) | dono (manual) | 0004 |
| 3 | 0006 → 0008 (p-inga em série) ‖ 0010 (ginga) | **manda** (dogfood) | 0005, 0007; **aprovada pelo dono em 2026-10-28** |
| 4 | 0009 ‖ 0011 | manda | 0008, 0010; PLAN-0003 decide `gira-g-ux` |
| 5 | 0012 ‖ 0013 | **ginga tick** | 0011 |
| 6 | 0014 ‖ 0015 | ginga tick | 0012, 0013 |
| 7 | 0017 (pi-harness sai) | ginga tick | 0014, 0015; 0003 decidido; emendas no 0006 e no 0014 |

Uma onda só começa com o judge `pass` dos PLANs de que ela depende.

## 4. O ciclo de um PLAN (fase 0, manual)

```
1. Aprovar o PLAN               status: approved no PLAN.md
2. Worktree                     git -C <repo> worktree add ../<repo>-plan-NNNN -b plan/NNNN
                                (repo novo, como ginga/ no 0004: git init + 1º commit antes)
3. Passada RED (Claude)         prompts/planner-red.md      → tests_frozen escritos, prove-red RED
4. Para cada TASK, em ordem do depends_on:
     materializar                tasks/T<N>/PLAN.md (≤25 linhas, do frontmatter da TASK)
     executar (opencode)         prompts/executor.md
     verificar                   pinga verify tasks/T<N>/PLAN.md   → pass? próxima : retry pela tabela §2
     3 falhas pelo mesmo motivo  prompts/replan.md (Claude)
5. Judge do PLAN (AGY)          prompts/judge.md            → pass: merge; fail: TASK de fix
6. Fechar                       log.md + index.md; learnings no LEARNINGS.md
```

**Onde rodar:** no homelab, uma pane do tuios por lane (worktree). Sessões **novas por TASK**: o contexto é o arquivo da TASK, não a conversa, e isso já economiza o cache. O Claude só abre para o passo 3 e o replan.

## 5. Gastando bem o Claude Pro

- **Uma passada RED por janela de 5 h**, agrupando os PLANs da mesma onda (por exemplo, a onda 2 = 0005 + 0007 numa sessão só).
- A passada RED não implementa nada: escreve testes e sai. Saída curta = menos tokens.
- O prompt é o arquivo; nada de conversa exploratória. Abra com `claude -p` quando não precisar de interação.
- Meça a primeira passada (`/usage` antes e depois) e corrija esta estimativa.

## 6. Medição desde o primeiro dia

Cada tentativa vira uma linha no `log.md` do PLAN: `TASK, modelo, tentativa, pass/fail, motivo`. Quando o 0004 fechar, o `ginga events migrate` converte isso em eventos v1, e o FTPR por modelo da fase 0 vira o primeiro dado do dashboard (0014) e a base para ajustar a tabela de §2.
