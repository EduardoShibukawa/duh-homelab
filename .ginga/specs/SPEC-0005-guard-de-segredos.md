---
type: spec
title: Guard de segredos nas lanes
intent: INTENT-0013-guard-de-segredos
status: approved
bench: none
---
## Objetivo

Impedir, **antes de a tool rodar**, que uma sessão de lane (Pi, opencode, Hermes) leia ou exfiltre segredos do dono, e **redigir** formatos de chave no resultado da tool antes de ele entrar no contexto (e, portanto, no prompt enviado ao provider). Uma lista de bloqueio única, um só casador, três adaptadores finos. O guard é uma camada de regra: o que ele **não** cobre está declarado (pesquisa §6) e exige isolamento de processo para fechar.

## ACs

- [ ] Existe **uma** lista de bloqueio em dados (`deny.json`) e **um** casador (`core.ts`); os três adaptadores só traduzem o evento do runtime. Uma tabela de casos única (`cases.json`) é usada pelos testes dos três.
- [ ] Em sessão de lane, `cat .env` e `cat ~/.pi/agent/auth.json` são barrados no Pi, no opencode e no Hermes; `cat README.md` passa. Caminhos são resolvidos (`~`, `$HOME`, `..`, symlink) antes de comparar.
- [ ] `env`, `printenv`, `set` sem argumento, `export -p`, `/proc/*/environ` e `curl ... @arquivo-protegido` são barrados; `env FOO=1 cmd`, `set -e` e `rg process.env src/` passam.
- [ ] Formato de chave (`sk-`, `nvapi-`, `ghp_`, `AKIA`, JWT, PEM etc.) e o **valor exato** de variável de ambiente sensível são substituídos por `[REDACTED:<regra>]` no resultado da tool; o texto limpo passa igual.
- [ ] **Escopo:** sem `GINGA_GUARD_LANE` no ambiente o guard é inerte (sessões interativas do dono). As lanes e o `manda run` exportam a marca; `GINGA_GUARD=off` só por decisão do dono.
- [ ] **Falha fechada:** erro interno do guard bloqueia a chamada (`guard_error`) em modo `enforce`; em `shadow` registra e libera. Guard ligado e arquivos ausentes = a lane não inicia.
- [ ] Todo bloqueio e toda redação gera um evento JSONL (`guard.block`, `guard.redact`, `guard.error`) **sem o trecho que casou**.
- [ ] Nada é escrito em `~/.pi`, `~/.config/opencode` ou `~/.hermes`: Pi carrega por `-e`, opencode por `OPENCODE_CONFIG_DIR`, Hermes por plugin ativado numa ação do dono (ver PLAN).
- [ ] O varredor `sweep` sai com código 3 e imprime só `arquivo:linha regra` quando acha formato de chave em logs.
- [ ] Meta de resultado (medida depois): ≥ 20 TASKs reais com o guard em `enforce` e taxa de falso positivo < 2% das chamadas (referência do protótipo: 3 em 1716 chamadas dos `runs/` antigos).

## Dados e dinheiro

Nenhum dado novo sai da máquina e nenhum custo é criado. As provas da Fase 2 usam `.env` **sintético** em `mktemp -d` e modelo free já configurado (decisão do dono antes de rodar).

## Fora do escopo

HOME restrito / bwrap do processo do runtime, injeção de credencial por provider, guard no Claude Code (PreToolUse) e scan da requisição ao provider (`before_provider_request`): follow-ups em §7 da pesquisa.
