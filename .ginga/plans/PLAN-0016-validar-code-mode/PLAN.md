---
type: plan
title: Validar as ideias da palestra de code mode no nosso harness
intent: INTENT-0006-sandbox-e-code-mode
kind: investigation
status: approved
repos: [ginga]
depends_on: [PLAN-0004-eventos-e-lint]
done_when: "cd ginga && bun test tests/code_mode/"
---
## Objetivo

Reproduzir no nosso contexto o experimento da palestra da Arize. Cada task tem instrução, ambiente e verifier. Cada trial roda num ambiente novo, com reward 0/1 e k trials. Com isso validamos ou derrubamos cada afirmação com **dados nossos, gastando quase nada de Claude**. O resultado decide como o manda e o ginga entregam as tools ao orquestrador.

## O que está sendo testado (o papel)

O **orquestrador**: lê o estado, cruza as fontes, decide e resume. Não é o executor que escreve código; esse papel já tem gate próprio. Na v1, as tasks são **perguntas com resposta exata** sobre um **snapshot congelado e real** das ondas 1–2: `.ginga/` (PLANs, logs, LEARNINGS), os ledgers do pinga e os `runs/`. Os modelos nunca viram esses dados, então não há contaminação.

## Hipóteses (pré-registradas: o critério de decisão é escrito antes de rodar)

| | Hipótese | Medida | Adotar se |
|---|---|---|---|
| H1 | Code mode reduz tokens e turnos frente ao MCP com uma tool por chamada | tokens de entrada, turnos | X2 com tokens ≤ 0,7× de M e reward ≥ M − 1 task |
| H2 | A 1ª versão do code mode sai pior, e o ajuste guiado pelos traces corrige | X1 contra X2 | só informativo |
| H3 | CLI + skill ≈ code mode, já que bash já compõe | C contra X2 | se C ≈ X2, **não** criar o tool `execute`: basta CLI + skill |
| H4 | Modelos pequenos perdem reward no code mode | reward por modelo × modo | define o modelo mínimo do orquestrador |
| H5 | O Oracle, uma solução de referência em script, prova que cada task tem solução | Oracle 10/10 | obrigatório antes de qualquer trial |
| H7 | Um ambiente mínimo, com só o necessário visível, reduz os tokens gastos explorando | X2 com `execute` em bwrap mínimo contra o FS inteiro | tokens ≤ 0,85× com o mesmo reward |

A H6 (traces no nosso receptor contra o Phoenix) fica para depois do PLAN-0014, porque o receptor ainda não existe.

## Desenho

- **Harness único: opencode**, que é open source. Assim a única variável é o **modo de entregar as tools**:
  - **M:** um servidor MCP com uma tool por operação (cerca de 12 tools sobre o snapshot).
  - **C:** bash, as CLIs `--json` e o `sqlite3`, mais uma skill que explica como usá-los.
  - **X1/X2:** só `search_tools` e `execute(script)`. O script roda **dentro do bwrap** (a sandbox fica no lado das tools, o modelo fica fora, como na palestra). A saída volta truncada. X2 é o X1 com as instruções ajustadas a partir dos traces.
  - **O:** o Oracle.
- **Modelos:**
  - `opencode/glm-5.3-flash-free` e `deepseek-v4.1-flash-free` (pequenos, grátis);
  - `opencode/deepseek-v4-pro` (forte, pago).
  - Baseline de outro harness: o **Codex `gpt-6-luna`** no modo nativo (≈ C), que está com a quota quase cheia.
  - Claude fora. No máximo uma amostra de 3 tasks quando a janela renovar.
- **Tasks:** 10, em 4 níveis:
  - consulta direta;
  - junção entre log e ledger;
  - agregação (custo e retries por modelo);
  - multi-hop, por exemplo "o que bloqueou o quê, e por quê".
  - Duas delas exigem filtrar muitos dados (`runs/`), onde o code mode deveria brilhar. Duas são armadilhas: exigem notar dado ausente ou anômalo, como o custo US$0 numa tentativa paga.
- **Métricas por trial:** reward, turnos, tokens de entrada e saída, custo e latência. Os resultados vão para `results.jsonl` e para eventos v1. Opcionalmente, para OTLP (Phoenix).

## Onde mora o código

No **ginga**, em `bench/code-mode/` (testes em `tests/code_mode/`), até a lacuna 9 (porta de bench) ter PLAN. O **snapshot real** (`.ginga/`, ledgers e `runs/`) nunca entra no repo (é MIT e público): fica em `.ginga/bench/code-mode/snapshot/` do workspace e chega ao código por `--snapshot <dir>`. Os testes usam um snapshot sintético pequeno (`tests/fixtures/code-mode/snapshot/`). A prova de captura de tokens já foi feita pelo PLAN-0019 (`.ginga/bench/code-mode/captura-tokens.md` e `tokens.sh`): a TASK-02 só a porta para TS.

## TASKs de código (executor barato)

1. [TASK-01](TASK-01-tasks-oracle.md): as 10 tasks, o Oracle e o verifier (H5)
2. [TASK-02](TASK-02-runner.md): runner de trials isolados + captura de tokens
3. [TASK-03](TASK-03-superficie-m.md): superfície M (MCP, uma tool por operação)
4. [TASK-04](TASK-04-superficie-c.md): superfície C (skill + CLIs) e config do agente por modo
5. [TASK-05](TASK-05-superficie-x.md): superfície X (`search_tools` + `execute` no bwrap)
6. [TASK-06](TASK-06-relatorio.md): relatório e decisão pelos critérios pré-registrados
7. [TASK-07](TASK-07-fixture-clean-checkout.md): fixture sintético completo em checkout limpo
8. [TASK-08](TASK-08-relatorio-criterios.md): critérios H4/H7, regra sub-task e CLI do relatório

Ordem: 01 → (02, 03, 04, 05) → 06 → (07, 08). TASK-04 depende da 03 (a config do agente cita as três superfícies).

## Rodadas (por código, depois das TASKs; não são TASKs de executor)

`bun bench/code-mode/run.ts --snapshot <dir> --plan <piloto|principal|h2|h7>` grava `results.jsonl` em `.ginga/bench/code-mode/` e eventos v1. Disparo: o Planner (ou o tick, quando a lacuna 1 existir), uma rodada por vez, com o Oracle em 10/10 antes de qualquer trial.

1. **Piloto:** 5 tasks, k=1, todas as células; mede custo e tempo, decide seguir e ajusta o k.
2. **Principal (H1, H3, H4 + Codex):** k=3; teto de **US$ 3** no `deepseek-v4-pro`, medido pelo `opencode.db`.
3. **H2:** o Planner lê os traces do X1 e escreve as instruções do X2 (`bench/code-mode/surfaces/x2.md`); roda de novo as mesmas tasks.
4. **H7:** X2 com bwrap mínimo contra X2 vendo o FS inteiro.
5. **Decisão:** `bun bench/code-mode/report.ts` + emenda no INTENT-0006 e nos PLANs 0007, 0008 e 0010.

## Interfaces (definidas no plano; mudar = replan)

```ts
// bench/code-mode/tasks.ts (TASK-01)
export type CMTask = { id: string; level: "direta" | "juncao" | "agregacao" | "multihop"; trap: boolean; heavy: boolean; question: string; answer_schema: object };
export const TASKS: CMTask[]; // exatamente 10
export function oracle(task: CMTask, snapshot: string): unknown; // resposta de referência
export function verify(task: CMTask, answer: unknown, snapshot: string): 0 | 1; // reward exato
// bench/code-mode/runner.ts (TASK-02)
export type Mode = "M" | "C" | "X1" | "X2" | "O";
export type Trial = { task: string; mode: Mode; model: string; k: number; reward: 0 | 1; turns: number; tokens_in: number; tokens_out: number; cost_usd: number; latency_ms: number; infra: boolean; session_id?: string };
export function trialArgv(mode: Mode, model: string, workdir: string, prompt: string): string[];
export function parseExport(json: string): { in: number; out: number; cache: number; cost: number; turns: number; reasoning: number };
export async function runTrial(o: { task: CMTask; mode: Mode; model: string; k: number; snapshot: string; spawn: Spawn }): Promise<Trial>;
// bench/code-mode/surfaces/m.ts (TASK-03): export const M_TOOLS: { name: string; run(snapshot: string, args: any): unknown }[]
// bench/code-mode/surfaces/x.ts (TASK-05)
export function bwrapArgv(snapshot: string, script: string, minimal: boolean): string[];
export function truncate(out: string, max?: number): string; // padrão 8000 chars
// bench/code-mode/report.ts (TASK-06)
export function decide(trials: Trial[]): { h: "H1"|"H2"|"H3"|"H4"|"H5"|"H7"; verdict: "adotar"|"rejeitar"|"informativo"|"inconclusivo"; evidence: string }[];
```

## Riscos

- **Medição de tokens do opencode:** resolvida pelo `session export --standalone` (PLAN-0019); a TASK-02 testa o parser contra um export real redigido.
- **429 dos modelos free:** espaçar os trials e registrar `infra` separado de falha.
- **Viés das tasks:** perguntas sobre os nossos dados favorecem quem lê arquivos. Por isso há um verifier exato e um Oracle, e a decisão é pré-registrada.
- **k pequeno:** é sinal, não prova. Diferenças menores que uma task não decidem nada.
- **Repo `bench/` inexistente:** o código fica no ginga (`bench/code-mode/`) e o snapshot no workspace; move quando a lacuna 9 tiver PLAN.
- **Armadilha do stdin:** `opencode run` sem `< /dev/null` espera o stdin e parece travado; o runner sempre fecha o stdin.
