# Captura de tokens do opencode (PLAN-0016 TASK-02)

> Prova de que dá para medir tokens/custo/turnos do opencode em modo code.
> Ambiente: `opencode v2.2.0` (mise), modelo `opencode/glm-5.3-flash-free`.

## Conclusão (resumo)

**Dá para medir, via `opencode session export`.** A saída `--format json` do `run` **não** é suficiente sozinha: ela só emite `step_finish` (com `tokens`/`cost`) nos passos que fazem tool call; o passo final de texto não tem `step_finish`. O `session export` devolve o agregado completo (`info.tokens` + `info.cost`) e os tokens por turno (cada mensagem `assistant`).

**Pegadinha obrigatória:** sessão criada com `--standalone` só é exportável com `--standalone` também. Sem a flag, o `session export` conecta no serviço de fundo (porta 49374) e devolve **vazio** (0 bytes).

## Comandos exatos

```bash
# 1. Rodar em diretório temporário vazio (servidor privado, não o serviço compartilhado)
cd "$(mktemp -d)"
opencode run --standalone --format json \
  -m opencode/glm-5.3-flash-free "responda só: ok" > run.jsonl

# 2. Extrair o sessionID da primeira linha do JSON
SESSION_ID=$(head -1 run.jsonl | jq -r .sessionID)

# 3. Exportar a sessão (COM --standalone) e ler os tokens
opencode session export --standalone "$SESSION_ID" > export.json
jq '{in: .info.tokens.input, out: .info.tokens.output, cache: .info.tokens.cache.read, cost: .info.cost, turns: ([.messages[] | select(.type=="assistant")] | length)}' export.json
```

## Exemplo de saída (sem segredos)

### `run --format json` (1 turno, sem tool)

```jsonl
{"type":"step_start","timestamp":1793156599107,"sessionID":"ses_e7f89c3d8ffeTl411cLuEckAE4","part":{"id":"prt_180764d4300107mEIukblz8KtU","sessionID":"ses_e7f89c3d8ffeTl411cLuEckAE4","messageID":"msg_1807648410010T0imU7W414ORn","type":"step-start"}}
{"type":"text","timestamp":1793156599516,"sessionID":"ses_e7f89c3d8ffeTl411cLuEckAE4","part":{"id":"prt_1807648410010T0imU7W414ORn_text-0","sessionID":"ses_e7f89c3d8ffeTl411cLuEckAE4","messageID":"msg_1807648410010T0imU7W414ORn","type":"text","text":"ok","time":{"start":1793156597829,"end":1793156599516}}}
```

> Sem tool call, **não há `step_finish`** — logo, sem tokens na saída do `run`.

### `run --format json` (com tool call: `read`)

```jsonl
{"type":"step_start",...,"sessionID":"ses_e7f897938ffeQrTAWoRBGMFb2e",...}
{"type":"tool_use",...,"tool":"read","state":{"status":"completed","input":{"path":"notas.txt"},"output":"Read file notas.txt, lines 1-3\n..."}}
{"type":"step_finish",...,"reason":"tool-calls","cost":0,"tokens":{"input":3911,"output":13,"reasoning":26,"cache":{"read":4352,"write":0}}}
{"type":"step_start",...,"messageID":"msg_180769901001vgsE9aqoMfZUWf",...}
{"type":"text",...,"text":"O arquivo descreve uma cena noturna..."}
```

> O `step_finish` aparece **só** no passo que fez tool call. O passo final (texto) não tem `step_finish`, então a soma por `step_finish` fica incompleta.

### `session export` (agregado + por turno)

```json
{
  "info": {
    "id": "ses_e7f897938ffeQrTAWoRBGMFb2e",
    "model": { "id": "glm-5.3-flash-free", "providerID": "opencode" },
    "cost": 0.0000494,
    "tokens": { "input": 14810, "output": 104, "reasoning": 85, "cache": { "read": 16320, "write": 0 } },
    "outcome": "succeeded"
  },
  "messages": [
    { "type": "user", "text": "\"leia o arquivo notas.txt e resuma em uma frase\"" },
    { "type": "assistant", "cost": 0, "tokens": { "input": 3911, "output": 13, "reasoning": 26, "cache": { "read": 4352, "write": 0 } } },
    { "type": "assistant", "cost": 0, "tokens": { "input": 2952, "output": 50, "reasoning": 29, "cache": { "read": 7616, "write": 0 } } },
    { "type": "assistant", "cost": 0, "tokens": { "input": 7498, "output": 32, "reasoning": 30, "cache": { "read": 4352, "write": 0 } } },
    { "type": "idle", "outcome": "succeeded" }
  ]
}
```

## Como os números se relacionam (soma por turno)

| Campo | `info.tokens` (agregado) | Soma dos 3 turnos | Diferença |
|---|---|---|---|
| input | 14810 | 14361 | +449 (overhead do system prompt, constante) |
| output | 104 | 95 | +9 (overhead constante) |
| reasoning | 85 | 85 | 0 |
| cache.read | 16320 | 16320 | 0 |

- **`reasoning` e `cache.read` somam exatamente** por turno.
- **`input`/`output`** têm um overhead fixo (~449/~9) no agregado, que não é atribuído a nenhuma mensagem `assistant` (é o prompt de sistema + contabilidade do primeiro turno).
- **`turns`** = número de mensagens `assistant` (cada uma é um passo/turno do agente).
- **`cost`** = `info.cost` (agregado). No modelo free o custo por mensagem é `0`, mas o `info.cost` reporta um valor minúsculo (4.94e-05) — artefato de contabilidade; para modelos pagos, `info.cost` é o número a usar.

## O que falta / ressalvas

- **`cache.write`** aparece como `0` nos testes (o glm-5.3-flash-free não escreveu cache). O campo existe no schema e deve ser somado quando o modelo gravar cache.
- **`reasoning`** não está no contrato `{in,out,cache,cost,turns}` do PLAN-0016, mas está disponível no export e é relevante para modelos com thinking. O script abaixo o inclui como campo extra.
- **Custo por turno:** o `cost` por mensagem `assistant` é `0` no modelo free; para custo por turno em modelo pago, somar `messages[].cost` (ou usar `info.cost` para o total).
- **Latência** não vem no export; medir por fora (timestamp do `run`).

## Script

`tokens.sh <sessionID>` imprime `{in,out,cache,cost,turns,reasoning}` a partir do `session export --standalone`.
