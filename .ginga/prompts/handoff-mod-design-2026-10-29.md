Tarefa de pesquisa e design (sessão nova, handoff de 2026-10-29). Escreva em português do Brasil. Não edite código dos repos; só crie o documento de saída. Sessão curta: não fique monitorando nada.

Contexto: workspace /home/shibuka/Projetos/duh-homelab (harness G-Ingá: .ginga/, CLIs ginga/manda/pinga; runtimes Claude Code, opencode, Pi, Codex, AGY). Leia de forma enxuta: .ginga/knowledge/design/ginga-revamp/06-handoff-e-learnings.md, .ginga/plans/PLAN-0013-handoff-e-learnings/ (PLAN + TASKs), .ginga/specs/SPEC-0002-skills-e-hooks.md, a seção "Decisões do dono" de .ginga/knowledge/research/cobertura-visao-02-2026-10-29.md e os números de .ginga/knowledge/research/eficiencia-conversas-dono-2026-10-29.md.

Ideia do dono (ele já usa no trabalho, só para Claude): um mod que percebe quando o cache da conversa vai expirar OU quando o contexto ficou grande (~100–120k tokens), gera um handoff com o contexto necessário (skill de handoff) e abre uma sessão nova (claude agents / --bg), redirecionando a conversa. Não temos o código; projete do zero.

Pesquise os ganchos reais de cada runtime (docs locais, `--help`, e web se precisar): Claude Code (hooks, statusline com uso de contexto/rate_limits via stdin, plugins/mods, `claude --bg`/agents/attach, TTL do cache: 1 h nesta conta); opencode (plugins TS, ex. em ~/.config/opencode/plugins/, eventos de sessão); Pi (extensões, ex. pi-harness/.pi/extensions/guard.ts com pi.on(...), sessões em ~/.pi/agent/sessions); Codex/AGY (provavelmente só wrapper).

Saída: /home/shibuka/Projetos/duh-homelab/.ginga/knowledge/design/ginga-revamp/11-handoff-automatico.md (frontmatter type: design, title, status: proposta, date: 2026-10-29; máx. ~150 linhas):
1. Gatilhos: ociosidade > TTL−margem, contexto > limiar (parâmetros em project.toml, ex. [handoff] idle_min, context_tokens), manual.
2. Núcleo agnóstico: `ginga handoff` determinístico (arquivos + git + estado do PLAN, sem LLM) e o formato (seções); quando vale um resumo LLM barato opcional do que só está no chat (decisões, preferências).
3. Adapter por runtime (tabela: detecção, geração, abertura da sessão nova, limitações); skill de handoff como fonte única em .ginga/skills/handoff/, projetada pelo `ginga install` (SPEC-0002).
4. Riscos (perder decisões do chat, loop de handoff, privacidade) e mitigação.
5. Até 6 TASKs pequenas (título, repo, goal, done_when testável, touch, interfaces) para emendar o PLAN-0013, executáveis por modelo barato.
Ao terminar, avise no Discord: HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "design do handoff automático pronto: .ginga/knowledge/design/ginga-revamp/11-handoff-automatico.md"
