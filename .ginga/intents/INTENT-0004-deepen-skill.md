---
type: intent
legacy_id: "workspace/intents/0001"
source: cli
timestamp: 2026-10-21T00:00:00Z
id: "0004"
title: "Skill global `deepen` — transformar um pedido numa versão mais profunda (não maior) antes de executar"
status: BACKLOG
depends_on: []
created_at: "2026-10-21"
scope: "camada-orquestrador (workspace) — artefato vive em ~/.claude/skills, fora de qualquer repo filho"
---

# INTENT 0001 (workspace): Skill global `deepen` — o prompt de depth do Felix, com juiz anti-burla, checagem de disponibilidade e corte de escopo

> **Fonte:** "How to be more ambitious: a tutorial for humans with models" (Felix Rieseberg, out/2026), seção *Depth*, e a discussão de 2026-10-21. **Irmã:** `pi-harness/intents/0033` (o juiz pertence ao planejador) — mesma tese aplicada à esteira.

## 1. Contexto e Motivação

Modelos fazem exatamente o que se pede — e o pedido costuma descrever a **tarefa**, não o **resultado** nem o **método**. O prompt de depth do artigo ataca isso reescrevendo o pedido antes de executar:

> *I want a deeper version of this task, not a bigger one. Before rewriting it: (1) say what a top professional in this field would do here that I'm not asking for; (2) name the rawest material they would start from instead of what has already been digested for me; (3) name the specific methods and tools they would use; (4) say what, other than you or me, would show the result is right. Then rewrite my prompt to ask for exactly that.*

Pontos fortes: "deeper, not bigger" trava o escopo; (1) pergunta sobre método sem persona; (4) exclui até o humano como juiz; a saída é um **prompt**, não o trabalho (planejamento separado de execução).

Lacunas identificadas:
- **Sem pergunta de burla:** meta ambiciosa + juiz definido ⇒ o caminho mais curto é satisfazer o juiz sem resolver o problema.
- **Sem checagem de disponibilidade:** (3) pode nomear ferramentas/dados que não existem no ambiente — o próprio artigo diz que nada funciona sem acesso.
- **Sem corte:** "deeper" ainda pode crescer; falta dizer o que sai.

**Por que global e não no gira-g:** o catálogo `gira-g/internal/skills/catalog/` é coeso — toda skill embrulha uma operação `gira` (`operations`, `output_contract`, `budget`). `deepen` não tem operação gira, é técnica agnóstica de modelo; colocá-la lá quebraria a coesão, prenderia um texto iterável ao ciclo PR + CI + tag + goreleaser e distribuiria algo não pedido a quem instala o gira.

**Por que não no worker do pi-harness:** profundidade é etapa do **planejador**, não estilo do executor. Em modelo barato com "Zero Wandering", "o que um especialista faria além disso?" abre escopo e queima tokens.

## 2. Objetivos Principais

### 1. A skill
`~/.claude/skills/deepen/SKILL.md`, versionada num repo (dotfiles ou repo de skills pessoais) e linkada em `~/.claude/skills/`. Corpo = os 6 itens:

1. O que um especialista no domínio faria aqui que o pedido não pede?
2. De qual matéria-prima crua partiria (logs, transcripts, dados, código-fonte), em vez de resumos já digeridos?
3. Quais métodos e ferramentas específicos usaria? **Para cada um: está disponível neste ambiente?** Se não, vira pré-requisito explícito, não suposição.
4. Que evidência externa — nem do modelo, nem do usuário — prova que o resultado está certo? (comando determinístico > modelo de outra família > nada)
5. Como um executor poderia satisfazer essa evidência **sem** resolver o problema? Cada resposta vira guard ou critério negativo.
6. O que sai do escopo para compensar a profundidade adicionada?

Saída: o pedido reescrito, pronto para colar numa **sessão nova** ou entregar a um executor — mais a lista de pré-requisitos ausentes, se houver.

### 2. Gatilho e anti-gatilho
- **Usar** quando o pedido é não trivial: resultado incerto, mais de um arquivo/sistema, há um "por quê" por trás, ou o critério de pronto não está claro.
- **Pular** em tarefa mecânica (renomear, bump, ajuste de import) — o custo de uma passada no modelo caro não se paga.
- Não usar **dentro** de um juiz (régua tem de ser fixa) nem em worker barato.

### 3. Gancho opcional com o gira
Se o repo tiver `gira.yaml`, o item (2) indica `gira-impact-briefing` / `gira-context` como matéria-prima de impacto, em vez de leitura ad-hoc de arquivos. Referência, não dependência: sem gira, a skill funciona igual.

### 4. Validação honesta
Antes de declarar que "funciona": 3–5 pedidos reais (ex.: uma investigação de bench, um bug, um desenho de feature), cada um executado **com e sem** `deepen` em sessões separadas, comparando o que cada versão entregou contra um critério escrito **antes** de rodar. Registrar o resultado (inclusive "não fez diferença") no `LESSONS.md` da raiz.

## 3. Critérios de Aceite
- **Dado** um pedido não trivial, **quando** `/deepen <pedido>` roda, **então** a saída contém os 6 itens respondidos e um prompt reescrito autocontido.
- **Dado** que um método do item (3) depende de ferramenta ausente, **então** ela aparece como pré-requisito e o prompt reescrito não presume que existe.
- **Dado** um pedido trivial, **então** a skill diz que não vale a pena e devolve o pedido intacto.
- **Dado** um repo com `gira.yaml`, **então** o item (2) cita as skills gira; sem ele, não cita.
- O arquivo-fonte está versionado e o link em `~/.claude/skills/deepen` aponta para ele.

## 4. Non-Goals
- **Não** entra no catálogo do gira-g nem no worker do pi-harness.
- **Não** executa o pedido reescrito automaticamente — a reescrita é revisada pelo usuário (planejamento ≠ execução).
- **Não** é "range" (lentes múltiplas/red team) — candidato a intent futura, se `deepen` provar valor.

## 5. OPEN QUESTIONS
1. **Onde versionar:** repo de dotfiles existente, ou um repo novo de skills pessoais?
2. **Invocação:** só explícita (`/deepen`, `disable-model-invocation: true`) para controlar custo, ou também por auto-gatilho do modelo? Recomendação: explícita até a validação do objetivo 4.
3. **Também para o pi (`.pi/skills`)?** Útil se sessões pi na raiz do workspace fazem planejamento; nesse caso, mesma fonte linkada nos dois lugares.
