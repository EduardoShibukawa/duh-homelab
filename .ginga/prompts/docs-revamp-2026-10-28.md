Você é o redator de arquitetura do duh-homelab (cwd `/home/shibuka/Projetos/duh-homelab`). Edite **somente**:

- `.ginga/knowledge/design/ginga-revamp/`;
- `.ginga/specs/SPEC-0002-skills-e-hooks.md` (novo);
- `.ginga/knowledge/research/situacao-vs-visao-2026-10-28.md` (novo).

Outro agente está operando repos e PLANs: não toque em código, `.ginga/plans/` nem `.ginga/index.md`. Sem commits.

## Leia antes

- `.ginga/knowledge/design/ginga-revamp/README.md` e de `01` a `08`;
- `.ginga/knowledge/decisions/` (todas);
- `.ginga/intents/` (0006, 0007, 0008, 0009);
- `.ginga/specs/SPEC-0001-ginga-revamp.md`;
- `.ginga/plans/*/PLAN.md` (só frontmatter + Objetivo) e os `log.md` das ondas 1–3;
- `.ginga/models/ROUTING.md`;
- `.ginga/knowledge/research/`: `sandbox-ai.md`, `skills-e-hooks.md`, `sessao-2026-10-27/analise.md`;
- `.ginga/bin/sandbox-done-when.sh` e `.ginga/bin/sandbox-run.sh`;
- `.ginga/handoffs/` (os mais recentes).

## Tarefas

1. **Consolidar o `02-visao-atualizada.md`** com as decisões posteriores. Atualize os diagramas mermaid e marque cada mudança com "(2026-10-28)".
   - **DECISION-0003:** tudo OSI/MIT. A observabilidade é OTLP + OpenInference; o backend padrão é nosso (`ginga serve /v1/traces` + Roda); Phoenix, Jaeger etc. são destinos opcionais via `GINGA_OTLP_ENDPOINT`.
   - **DECISION-0004:** o repo e o pacote passam a se chamar `g-inga`; o CLI continua `ginga`.
   - **PLAN-0017:** o pi-harness sai como pacote, e o Pi vira host adapter no manda.
   - **ROUTING de 2026-10-28:** papéis × modelos, Go só no opencode, sem escalada automática para strong.
   - **INTENT-0008:** desbloqueio automático na rota de falhas.
   - **INTENT-0009 / skills-e-hooks:** fonte única `.ginga/skills/` + `hooks.toml` + perfis, com o gerador no `ginga install/init`.
   - **Porta `Sandbox`** separada da porta de runtime (INTENT-0006).
   - Atualize também a tabela de decisões do `README.md` do revamp, com as decisões 15 em diante.
2. **Novo `09-observabilidade.md`:**
   - a palestra da Arize (INTENT-0006, slides: code mode, −43% tokens);
   - o que o Phoenix faz;
   - por que ele é **opcional** (ELv2), com a interface OTLP;
   - o teste já feito (ponte `bridge.py` → 97 spans, projeto `duh-homelab-ondas-1-2`; o Phoenix só aceita protobuf);
   - um **plano de teste** do Phoenix como destino opcional, ligado ao PLAN-0014 e à H6 do PLAN-0016;
   - quais métricas queremos: tokens, turnos, custo e FTPR por papel e por modelo.
3. **Novo `10-sandbox.md`**, com a sandbox de execução isolada:
   - **Fase 1 (feita):** `sandbox-done-when.sh`, com bwrap, `--unshare-net`, HOME falso, `.git` somente leitura e identidade git por variável.
   - **Problemas reais observados por causa do isolamento:**
     - os testes do p-inga que leem o `~/.hermes` e o estado real (T26, W12);
     - o git sem identidade, que quebrou os commits dos testes do manda;
     - o serviço compartilhado do opencode na porta 49374, que travou os clientes;
     - o executor, que precisa alcançar o endpoint do provider;
     - os modelos free, que só funcionam no opencode.
   - **A questão do dono:** "devemos dar uma opção de networking ou pensar melhor?". Analise:
     - `net: none` (o done_when);
     - `net: allowlist[domínios]` (proxy de saída: `pasta`/`slirp4netns` + proxy, ou o `srt` Apache-2.0);
     - `net: host` (inseguro, só para debug);
     - o equivalente do `--network` do Docker.
   - Proponha o **perfil declarativo** por runtime e por papel (`mounts`, `env`, `net`, `needs:` de INTENT-0008), a **matriz de validação** e o **fail-closed**. Recomende: o que é padrão, o que é opção e o que é proibido.
   - Diga o que fica para a fase 2.
4. **Nova `SPEC-0002-skills-e-hooks.md`** (`status: draft`), a partir de `research/skills-e-hooks.md` e da INTENT-0009: objetivo, ACs testáveis, MVP (3 skills + 3 hooks do host), fora do escopo e os PLANs afetados (0006, 0008, 0015, 0016).
5. **Novo `research/situacao-vs-visao-2026-10-28.md`:** uma tabela "visão (02 consolidado) × estado atual". Para cada peça (pinga, manda, g-inga, Roda, gira, sandbox, observabilidade, skills/hooks, routing/budget, bench), diga o que existe, o que está mergeado, o que está em PLAN e o que nem tem PLAN. Depois, as lacunas priorizadas e os próximos 5 passos.

## Estilo

Português, conciso, com tabelas e mermaid onde ajudar. Cite os arquivos de origem. Não invente estado: se algo não estiver claro nos arquivos, escreva "a verificar".

## Ao terminar

```
HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "Docs do revamp atualizados (02 consolidado, 09-observabilidade, 10-sandbox, SPEC-0002) + situacao-vs-visao-2026-10-28.md"
```
