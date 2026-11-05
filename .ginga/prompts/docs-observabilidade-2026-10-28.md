Você é o redator de arquitetura do duh-homelab (cwd `/home/shibuka/Projetos/duh-homelab`). Edite **somente**:

- `.ginga/specs/SPEC-0003-observabilidade-operacional.md` (novo);
- `.ginga/knowledge/design/ginga-revamp/09-observabilidade.md`;
- `.ginga/knowledge/design/ginga-revamp/07-eventos.md` (só acrescentar);
- `.ginga/knowledge/research/situacao-vs-visao-2026-10-28.md`.

Sem commits. Não toque em código, `.ginga/plans/` nem `index.md`: outro agente está operando.

## Leia antes

- `.ginga/intents/INTENT-0010-observabilidade-operacional.md` (o pedido do dono e a tabela de evidências);
- `.ginga/intents/INTENT-0008-resolver-dependencias.md`;
- `design/ginga-revamp/02`, `07`, `08`, `09` e `10`;
- `.ginga/models/ROUTING.md`;
- `PLAN-0004`, `0008`, `0010`, `0012` e `0014` (frontmatter + Objetivo + TASKs);
- `.ginga/knowledge/research/sessao-2026-10-27/analise.md`.

## Tarefas

1. **SPEC-0003** (`status: draft`, `intent: INTENT-0010`):
   - objetivo;
   - **catálogo de sinais**: tipos novos de evento v1 (`heartbeat`, `cost`, `judge.verdict`, `sandbox.*`, `gate.fail`) com campos e a correlação `trace_id`/`span_id` PLAN → TASK → attempt → chamada de ferramenta;
   - **mapeamento para OTLP/OpenInference** (atributos);
   - **regras do vigia** em arquivo (ex.: `.ginga/watch/rules.toml`): determinísticas, uma por linha da tabela do INTENT, cada uma com sinal, condição, janela, ação e severidade, e cada uma **testável** com fixture de eventos;
   - **ações**: integração com a rota de falhas do manda (INTENT-0008), o Discord (só o crítico, com dedupe e resumo) e os painéis da Roda;
   - **ACs testáveis**: por exemplo, "replay do log de 2026-10-27 com o cliente travado dispara `infra_stuck` em ≤ N min";
   - **PLANs afetados**, com a emenda sugerida para cada um (0004, 0008, 0010, 0012, 0014);
   - fora do escopo.

   Use os incidentes reais como casos de teste (fixtures).
2. **09-observabilidade.md:** acrescente uma seção "Operacional: detecção e ação", que resume e aponta para a SPEC-0003. Deixe claro que traces/Phoenix são a visualização e que **o vigia é a detecção**.
3. **07-eventos.md:** acrescente os tipos novos numa tabela "propostos (SPEC-0003)", sem alterar os existentes.
4. **Corrija o `situacao-vs-visao-2026-10-28.md`:**
   - o **judge cego ainda não existe** no manda (é a TASK-07 do PLAN-0008, draft);
   - o PLAN-0019 é uma avaliação de modelos, não uma peça do pinga;
   - o PLAN-0004 já tem as TASK-13/14 em `pass`, com o judge final rodando;
   - o PLAN-0018 já tem a TASK-07 em `pass`, com o judge final rodando;
   - o executor hoje roda com `--share-net` (rede aberta), um ponto temporário até a fase 2.

   Acrescente a linha **"Observabilidade operacional"** (INTENT-0010 / SPEC-0003) e uma nota no topo: "este arquivo deve ser regenerado no fim de cada onda a partir do estado (SPEC-0003)".

## Ao terminar

```
HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "SPEC-0003 observabilidade operacional (draft) + 09/07 atualizados + situacao-vs-visao corrigido"
```
