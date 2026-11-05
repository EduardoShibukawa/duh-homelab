Você é o avaliador de arquitetura do duh-homelab (cwd `/home/shibuka/Projetos/duh-homelab`). **Só leitura**, exceto o arquivo de saída `.ginga/knowledge/research/determinismo-e-placement.md`. Sem commits, sem código. Outro agente está escrevendo a SPEC-0003: não toque em `.ginga/specs/` nem em `design/`.

## O pedido do dono (2026-10-28)

"Devemos ter alguém para avaliar outra coisa: tudo que precisa ser determinístico, o que deve ser não determinístico, o que precisa do uso de Jev para ser eficiente, e onde cada tooling precisa ir: skill, hook, prompt, script, projeto etc."

## Jev (fonte: https://opencode.ai/docs/zen/)

- Modelo "System One" da TypeSafe AI, de **decisão estruturada**: não gera texto.
- Avalia um `state` contra perguntas tipadas e devolve valores **com probabilidades**. Tipos: sim/não (`noul`), `choice` e `score` (rubrica). Várias perguntas são avaliadas em paralelo numa chamada.
- Endpoint: `https://opencode.ai/inference/systemone/v1/systemone`, com Bearer da API key do Console.
- Preço: Jev 1.13 Free é grátis por tempo limitado; o Jev 1.13 custa US$0,042 por 1M de entrada, com saída grátis.

## Leia (inventário)

- `.ginga/bin/*` e `.ginga/prompts/*`;
- `.ginga/models/ROUTING.md`;
- intents 0006, 0008, 0009 e 0010;
- `.ginga/specs/SPEC-0001` e `SPEC-0002`;
- `design/ginga-revamp/02`, `07`, `08`, `10`;
- `knowledge/research/`: `skills-e-hooks.md`, `sessao-2026-10-27/analise.md`;
- `PLAN-0008` e `PLAN-0016` (frontmatter + TASKs);
- os `log.md` das ondas 1–3, onde está o que deu errado.

Use `ls`/`rg` no `manda/src`, `p-inga/src` e nos hooks (`~/.claude/settings.json` só para listar os hooks, **sem** copiar segredos).

## Entregue

1. **Taxonomia em 3 faixas, com critério claro:**
   - **Determinístico** (script/código/gate): resultado verificável; erro inaceitável; repetível.
   - **Classificação estruturada (Jev)**: decisão fechada sobre texto livre, onde a probabilidade importa e o custo deve ser quase zero.
   - **Generativo (LLM)**: escrever código, testes, planos, pesquisa, revisão aberta.

   Inclua a regra de ouro: o LLM nunca decide o que pode ser verificado; o Jev decide classes; o script verifica.
2. **Tabela de todas as decisões e operações do harness** (no mínimo 30 linhas, a partir do inventário real). Colunas: operação | faixa | por quê | onde mora (**skill**, **hook do host**, **script/CLI**, **código do pacote** (pinga/manda/g-inga), **prompt de papel**, **config de projeto** `project.toml`/ROUTING) | pacote dono | PLAN/INTENT que cobre (ou "novo").

   Exemplos que **devem** aparecer:
   - validar frontmatter e unicidade de `pinga_task`;
   - escolher o modelo pelo tier;
   - classificar `BLOCKED:` (INTENT-0008);
   - novo × regressão no judge;
   - detectar cliente travado;
   - teto de custo;
   - escrever o teste RED;
   - julgar o diff;
   - triagem de tier (light/standard/heavy);
   - decidir se um alerta vai para o Discord;
   - severidade de um alerta;
   - merge;
   - gerar `situacao-vs-visao`;
   - medir tokens;
   - classificar a falha de sandbox;
   - escolher as skills de uma TASK (só o necessário na sandbox);
   - resumo de handoff.
3. **Onde vive cada tipo de tooling:** uma definição curta de skill, hook, prompt, script, código de pacote e config de projeto, e quando usar cada um. Um diagrama mermaid simples do fluxo: evento → hook/vigia (determinístico) → Jev (classifica) → LLM (só se precisar) → script verifica.
4. **Onde o Jev entra primeiro:** as 3 a 5 aplicações de maior retorno, um **experimento** para validar cada uma (acurácia contra rótulos manuais tirados dos `log.md` reais; meta ≥ 90%) e os riscos (probabilidade mal calibrada, limite do free "por tempo limitado", dados enviados).
5. **O que hoje está na faixa errada nesta sessão:** por exemplo, o operador LLM fazendo merge, o Claude lendo log à mão, o teto por processo.

## Estilo

Português, conciso, com tabelas, no máximo ~220 linhas. Cite os arquivos de origem. Escreva "a verificar" quando não souber.

## Ao terminar

```
HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "Avaliação determinismo × Jev × LLM e placement de tooling pronta: .ginga/knowledge/research/determinismo-e-placement.md"
```
