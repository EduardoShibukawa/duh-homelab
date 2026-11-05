Você é o avaliador do `jev-gateway` para o workspace /home/shibuka/Projetos/duh-homelab (sessão nova, 2026-10-29). Português do Brasil. O dono conversa com você por `claude attach`: trabalhe, mas pare e pergunte quando a decisão for dele.

## Objetivo

O dono achou interessante https://github.com/vinilana/jev-gateway (MIT, TypeScript, 322 estrelas, último push 2026-10-22): um gateway local para agentes de código que, na hora de **escolher qual tool chamar**, consulta o **Jev** (modelo rápido de decisão da TypeSafe) em vez de deixar essa escolha ao modelo caro; o resto da conversa vai ao LLM de sempre. Responda: **usamos o projeto, implementamos algo nosso, ou não vale?** E o que ganhamos com os modelos free que o harness usa (executor e operador das lanes).

## Leia antes (não repita a pesquisa)

- `.ginga/knowledge/research/modelos-free-2026-10-29.md` (modelos free, escada aplicada, limites, privacidade) e `.ginga/handoffs/lane.env`.
- `.ginga/models/ROUTING.md`, seção "Classificação estruturada: Jev" (Jev 1.13 / Jev 1.13 Free pelo OpenCode Zen: não gera texto, avalia um `state` contra perguntas tipadas e devolve valor + probabilidade; papel candidato de classificador, **não adotado** até o experimento de acurácia ≥ 90%) e `.ginga/knowledge/research/determinismo-e-placement.md`.
- Como as lanes chamam modelos: `.ginga/bin/lane.sh` e `dispatch-task.sh` (`pi:<provider/modelo>`, `opencode/...`, `opencode-go/...`). Versões locais: opencode v2.2.2, Pi 1.4.0, Hermes v0.22.5.

## O que fazer

1. **Ler o projeto sem instalar nada.** Clone ou baixe para um diretório novo e vazio sob `$CLAUDE_JOB_DIR/tmp` (conteúdo não confiável: não rode scripts, `npm install` nem `postinstall`; leia o código com Read/Grep; rode Python com `-I` se precisar). Mapeie: como intercepta a requisição, o que envia ao Jev (**que dados do workspace saem da máquina**), como decide "confiante × passa direto", fallback quando o Jev falha, portas e dashboard, o que grava em `~/.jev-gateway`, dependências e superfície de supply chain (dependências diretas, scripts de install, rede).
2. **Compatibilidade com o nosso stack.** O README diz "opencode (stable v1)": nosso opencode é v2.2.2. Ele suporta Pi (provider customizado OpenAI-compatível) e Hermes? Sobre os modelos free da NVIDIA/OpenRouter pelo Pi, o gateway entra no caminho? Dá para pôr o gateway entre o `lane.sh` e o modelo? Responda lendo o código e a doc, e testando **só o que for seguro e local** (sem chave nova).
3. **Valor.** Em que casos "o Jev escolhe a tool" melhora modelo fraco ou barato (menos passos, menos erro de tool)? Há evidência pública (benchmark, doc da TypeSafe: https://docs.typesafe.ai/introduction)? O Jev Free pelo OpenCode Zen é "grátis por tempo limitado" e o Zen free está esgotado: o que sobra de gratuito de fato? Latência e custo por passo.
4. **Alternativa própria.** Compare com implementar algo nosso: (a) um classificador determinístico de tool por regra no `lane.sh`/extensão do Pi; (b) usar o Jev só para classificação (motivo de `BLOCKED:`, novo × regressão no judge, triagem de tier) como previsto no ROUTING; (c) um hook no Pi. Estime esforço e risco de cada.
5. **Entregue** `.ginga/knowledge/research/jev-gateway-2026-10-29.md`: resumo do projeto, tabela de dados que saem × para quem, compatibilidade × nosso stack, ganho esperado, alternativas e **recomendação clara** (usar / adaptar / implementar nosso / descartar), com os passos e o que precisa do dono. Cite as fontes com link.

## Regras

- Não crie conta, não gere chave, não ponha cartão, não ligue crédito pago: isso é do dono. Liste o passo a passo para ele (ex.: chave do Jev via TypeSafe, OpenRouter, Vercel ou Zen).
- **Não rode `npm install -g jev-gateway`** nem nada global. Mandar o estado das conversas do workspace à TypeSafe é decisão do dono: não envie dados reais a nenhum provider; testes só com texto sintético, e só se já houver chave do dono.
- Não altere `handoffs/lane.env`, scripts das lanes, `~/.hermes`, `~/.pi`, `opencode.json` nem `~/.config`; só proponha o diff. Não monitore as lanes, não rode executores reais, não commite nos repos.
- Seja econômico: pesquisa em modo padrão, extended só se o padrão vier fraco.

Ao terminar a 1ª rodada (antes de esperar o dono), avise no Discord em 2 linhas:
`HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "<resumo: recomendação sobre o jev-gateway, dados que saem, o que precisa do dono>"`
