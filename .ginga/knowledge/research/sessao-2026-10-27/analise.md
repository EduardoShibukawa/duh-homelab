---
type: analysis
title: Retrospectiva da sessão 2026-10-27 (ondas 1–2)
source: transcript-condensado.md
timestamp: 2026-10-28
---

# Retrospectiva — sessão 2026-10-27 (ondas 1–2)

## 1. Problemas da sessão

### 1.1 Infra travada (serviço da porta 49374)
- **Evidência:** "os 3 clientes do opencode ficaram presos no serviço compartilhado da porta 49374, com 0% de CPU por 8 minutos"; "Os fixes estavam travados havia 1h30".
- **Causa raiz:** o opencode 2.1 abre um serviço compartilhado na porta fixa 49374; com `--share-net`, a sandbox fala com o serviço do host e os clientes travam sem saída.
- **Custo:** ~1h30 parado, 3 fixes, intervenção do operador (kill + restore + patch). Resolvido com `--standalone` + `timeout 1200s`.

### 1.2 Contrato/teste contraditório
- **Evidência:** 0005 TASK-09: "o teste congelado `supersede aceita o caminho de uma TASK-*.md` só passa mexendo em `src/cl…`" (6 tentativas); "`receipt_events.test.ts:86` (`expect(ev.data.reason_code).toBeNull()`) conflita com o [v1]".
- **Causa raiz:** teste antigo (TASK-07) exigia `reason_code === null`; o contrato novo (`07-eventos.md`) exige chave ausente. Nenhum código passa nos dois.
- **Custo:** 6 tentativas BLOCKED, 1 tentativa paga (~US$0,11), Planner (Claude) alinhou a linha 86.

### 1.3 Colisão de id (`pinga_task`)
- **Evidência:** "o `pi-harness-plan-0007` tem um `tasks/T58/`, e o fix do 0004 no pi-harness também usou T58" → renumerado para T59.
- **Causa raiz:** dois PLANs usaram T58 no mesmo repo; sem checagem de unicidade no ledger antes de atribuir.
- **Custo:** renumeração + re-selo, intervenção do operador.

### 1.4 Falso positivo de gate (AC-SEC)
- **Evidência:** "o pre-commit barrou o commit"; "a string do alfabeto Crockford tem entropia alta" (alfabeto ULID).
- **Causa raiz:** detector de entropia dispara em strings de alfabeto base32.
- **Custo:** 1 commit bloqueado; fix de 1 linha (concatenar dígitos+letras) + re-selo do T70.

### 1.5 Judge (formato, cota, rodadas)
- **Evidência:** "Error: -p took '--model' as its prompt" (sintaxe do AGY); "Individual quota reached… Resets in 90h" (argon sem cota); 0004 precisou de 4–5 rodadas de fix.
- **Causa raiz:** (a) runbook com `-p` do AGY na posição errada; (b) cota do `gemini-4-argon` esgotada; (c) testes congelados fracos na passada RED (só checavam tamanho do id, não formato).
- **Custo:** rodadas repetidas de judge, 3+ TASKs de fix, fallback para flash+Codex.

### 1.6 Claude fazendo trabalho do Pi/executor (quota)
- **Evidência:** "pq vc ta fazendo tudo em vez de usar subagents ta acabando a quota =(" / "de usar pi quer dizer".
- **Causa raiz:** o Claude escreveu testes RED, TASKs, scripts e prompts de judge direto, quando o operador barato devia ser o Pi.
- **Custo:** quota do Claude Pro (79%+), intervenção do dono para redirecionar.

### 1.7 Erro de entendimento da arquitetura
- **Evidência:** "como nao olhe o revamp a arquitetura" (sobre aposentar o pi-harness).
- **Causa raiz:** o Claude respondeu com `grep` por palavra-chave, sem ler a decisão 2 do revamp (que diz que o pi-harness sai).
- **Custo:** 1 correção do dono + retrabalho.

### 1.8 Outros (menores)
- **`restore()` apagava código de TASKs já pass** (nada commitado): "a restore() antiga apagou o código das TASKs já pass" → snapshot da árvore inteira.
- **`prove-red` "sem base"** quando o teste frozen não está commitado (demonstrar RED à mão).
- **Custo pago medido como US$0** para sessões pagas (medição não captou a sessão).
- **Teto US$0,25 furado** (guard só mede depois da chamada): TASK-03 gastou 0,2723.

## 2. Correções do dono

| # | O dono pediu | O Claude tinha feito | Regra do harness que evita |
|---|---|---|---|
| 1 | "qualquer pessoa pode usar as ferramentas separadas" | acoplou ginga→pi-harness→pinga | camadas sem ciclo (decisão 2) |
| 2 | "tirar o pi-harness" | discordou, depois concordou | leitura da arquitetura antes de opinar |
| 3 | "olhe o revamp a arquitetura" | respondeu com grep | skill gira-context / impact briefing |
| 4 | "de usar pi quer dizer" (não gastar quota) | fez tudo pelo Claude | enforcement de papéis (Claude ≠ executor) |
| 5 | "podemos usar opencode zen em vez de go" | usou Go até esgotar | ROUTING.md como fonte única + `~/.pi` default correto |
| 6 | "eu liberei limite de saldo no zen" | parou por `BudgetLimitError` | detecção de quota + aviso, não parada cega |
| 7 | "boraa" (rodada 3 de fix) | parou no limite de 2 rodadas | limite de rodadas configurável, não hardcoded |
| 8 | "quero que chame g-inga" / "Manda-CARU" | propôs outros nomes | decisão de nome registrada (DECISION-0001/0004) |
| 9 | "não quero precificar, tudo open source" | considerou Phoenix (ELv2) | DECISION-0003 (licença OSI) |
| 10 | "não queremos somente opencode" | amarrou sandbox ao opencode | porta Sandbox agnóstica de runtime (INTENT-0006) |

## 3. Melhorias no harness (impacto/esforço)

| # | Melhoria | Onde mora | Cobertura |
|---|---|---|---|
| 1 | **Setup gerador** (skills, hooks, prompts, perfis, config por projeto/agente) | ginga (`init`/`install`) | PLAN-0006 + PLAN-0015 (parcial; ver §4) |
| 2 | **Classificar `BLOCKED:` e gerar TASK de desbloqueio automática** | manda (rota de falhas) | INTENT-0008 (nova) |
| 3 | **Sandbox do `done_when` (opção A)** | pinga (`PINGA_EXEC_WRAPPER`) | PLAN-0018 (em andamento) |
| 4 | **`--standalone` + timeout no executor** | `.ginga/bin/dispatch-task.sh` → perfil de runtime | aplicado; formalizar no PLAN-0007/0008 |
| 5 | **Unicidade do `pinga_task` no ledger antes de despachar** | Planner / manda | INTENT-0008 §4 (prevenção) |
| 6 | **Rodar todos os testes do `done_when` contra o contrato antes de despachar** | Planner | INTENT-0008 §4 |
| 7 | **`judge.sh` (sintaxe do `-p` do AGY + fallback de cota)** | `.ginga/bin/` | novo (hoje é doc, já errou 1×) |
| 8 | **Medição de custo confiável (antes/depois)** | manda / PLAN-0014 | PLAN-0014 (métricas e quota) |
| 9 | **Handoff determinístico (`ginga handoff`)** | ginga | PLAN-0013 + doc 06 |
| 10 | **Enforcement de papéis (Claude não executa TASK)** | hook/gate | novo (hoje é só doc, foi violado) |

Prioridade sugerida: 2, 5, 6 (barato, elimina 4 intervenções manuais) → 4, 7 (barato, elimina travamento e erro de sintaxe) → 1, 3, 8, 9, 10.

## 4. Setup gerador

### O que hoje está espalhado e foi feito à mão
- **Hooks do Claude:** `~/.claude/settings.json` (tuios agent-hook, herdr-agent-state) e `~/.claude/hooks/herdr-agent-state.sh`.
- **Prompts:** `.ginga/prompts/` (executor, judge, operador, hermes-controle, planner-red, replan, pi-operador).
- **`~/.pi/agent/settings.json`:** `defaultProvider: opencode-go` (proibido) — precisa ser Zen; `models.json` (local-llama), `mcp.json`.
- **`HERMES_HOME=/home/shibuka/.hermes/profiles/pinga`** (obrigatório para `hermes send`).
- **`SANDBOX_REPOS="ginga manda"`** hardcoded no `dispatch-task.sh`.
- **`~/.claude/settings.json`:** plugin `pi-harness@pi-harness-local`.
- **`.ginga/bin/`:** dispatch-task, run-plan, sandbox-run, sandbox-done-when, status.

### O que deveria ser gerado e de qual fonte única
- **Fonte única:** `.ginga/project.toml` (stack, `[commands]`, context provider, runtimes, canais Hermes, perfis de sandbox, routing, tetos).
- **Por projeto:** layout `.ginga/`, `project.toml`, `index.md`, `log.md`.
- **Por agente (idempotente, nunca sobrescreve):** hooks/settings do Claude, config do Pi (`defaultProvider` correto), config do Codex/AGY, perfil do Hermes, prompts e skills, perfis de sandbox por runtime.

### Encaixe em PLAN-0006/0015 (sem duplicar)
- **PLAN-0006** (install/adopt sai do pinga → ginga): o "adopt" já instala hooks/plugins; o gerador é a casa natural.
- **PLAN-0015** (`ginga init` cria `.ginga/` + `project.toml`): o gerador estende o `init` para emitir a config por agente a partir do `project.toml`.

### Recomendação
**Sim, parcial.** Não criar um pacote "setup" separado: dobrar o gerador no `ginga init`/`install` (PLAN-0006/0015), com `project.toml` como fonte única e geração idempotente por agente. Motivo: elimina a deriva manual (o `~/.pi` com `opencode-go` proibido é o sintoma mais caro) sem criar mais um componente para manter.
