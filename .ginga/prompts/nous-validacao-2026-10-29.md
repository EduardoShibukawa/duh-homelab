Você é o validador dos modelos free do Nous Portal no workspace /home/shibuka/Projetos/duh-homelab (sessão nova, 2026-10-29). Português do Brasil. O dono conversa com você por `claude attach`: trabalhe, mas pare e pergunte quando a decisão for dele.

## Objetivo

A conta `nous` do dono (login OAuth já feito no Hermes, `~/.hermes`) é free-tier. O Portal recomenda `stepfun/step-3.7-flash:free`, `reflection/beam-1.0-501b-a23b:free`, `ornith/ornith-1.5-122b:free` (e `upstage/solar-mini4:free`, pequeno). O probe "responda só: ok" funcionou (5 a 13 s). **Falta validar tool calling real numa TASK de código** e levantar a política de dados e os limites do Nous Portal.

## Leia antes

`.ginga/knowledge/research/modelos-free-2026-10-29.md` (seção "Hermes / Nous Portal" e a tabela), `.ginga/knowledge/research/probes/task-red.sh` (TASK de correção que confere `unittest` e `md5` do teste).

## O que fazer

1. **Validar por TASK:** use `HERMES_HOME=$HOME/.hermes timeout 300 hermes -z "<prompt>" --provider nous -m <modelo> < /dev/null`, rodando num diretório novo de `mktemp -d` com a TASK de correção (o `textutil.py` com 2 bugs e o teste do `task-red.sh`). **Não use `--yolo`**: o sistema de permissões bloqueou essa flag nesta tarefa. Tente primeiro sem ela (veja `hermes --help` e `hermes chat --help` para toolsets/aprovação segura, p.ex. `-t` com `terminal,file`). Se o agente não conseguir usar tools sem aprovação, **pare** e entregue ao dono o comando exato para colar com `!` (prefixo `!` no prompt), e peça o resultado. Não copie `auth.json` nem credenciais para outro diretório.
2. Rode 2 rodadas por modelo (`step-3.7-flash`, `beam-1.0-501b`, `ornith-1.5-122b`). Registre: passou, tempo, `rc`, teste intacto, erro de provider × erro do modelo.
3. **Pesquise (modo padrão):** política de dados/treino e retenção do Nous Portal, limites do plano free (req/min, req/dia ou tokens), se exige cartão, e quem hospeda cada modelo free (se é o Nous ou um terceiro). Fontes primárias: `portal.nousresearch.com`, `hermes-agent.nousresearch.com/docs`, termos e política de privacidade. Marque o que não achar.
4. Entregue `.ginga/knowledge/research/nous-free-2026-10-29.md`: tabela modelo × tool calling × limite × treina? × testado, recomendação de papel (executor MIT, operador, fora), e passo a passo para o dono.

## Regras

- Não crie conta, não gere chave, não ponha cartão, não ligue crédito pago.
- Mandar dados do workspace a um provider novo é decisão do dono: os testes usam só código sintético. Nenhum operador em modelo que treina com os dados ou cuja política não foi lida.
- Não altere `~/.hermes`, `profiles/*`, `handoffs/lane.env` nem scripts das lanes; só proponha o diff. Não monitore as lanes, não rode executores reais, não commite nos repos.
- Outra sessão (`f9ddd794`) desenha os perfis do Hermes por papel; não duplique o trabalho dela, só entregue o que apurar sobre o Nous.

Ao terminar a 1ª rodada (antes de esperar o dono), avise no Discord em 2 linhas:
`HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "<resumo: modelos Nous validados, política de dados, o que precisa do dono>"`
