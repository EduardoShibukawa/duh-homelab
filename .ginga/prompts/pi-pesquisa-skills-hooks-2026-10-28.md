Você é pesquisador do duh-homelab (cwd `/home/shibuka/Projetos/duh-homelab`). **Só leitura**, exceto o arquivo de saída. Sem commits e sem dispatch. Pode usar busca na web e ler docs oficiais. Cite as fontes (URL) e marque o que é verificado e o que é inferido.

Leia antes:
- `.ginga/intents/INTENT-0009-skills-e-hooks.md` (o pedido do dono e as hipóteses);
- `.ginga/intents/INTENT-0006-sandbox-e-code-mode.md`;
- `.ginga/knowledge/research/sandbox-ai.md`;
- `.ginga/knowledge/research/sessao-2026-10-27/analise.md` (a seção do setup gerador);
- `.ginga/plans/PLAN-0016-validar-code-mode/PLAN.md` (H3);
- `PLAN-0006` e `PLAN-0015`;
- `.ginga/bin/sandbox-done-when.sh`;
- `.ginga/knowledge/design/ginga-revamp/README.md` (decisões; integração só por CLI/JSON/arquivos).

## Perguntas

1. **Estado da arte** (out/2026), por runtime: Claude Code, Codex CLI, OpenCode, Pi, Gemini/AGY e Hermes.
   - **Skills:** formato (SKILL.md / Agent Skills aberto?), descoberta progressiva, scripts executáveis, onde ficam e como são carregadas.
   - **Hooks/plugins:** quais eventos existem (pre/post tool, stop, prompt) e se podem **bloquear** uma ação.
   - Monte uma tabela de compatibilidade.
2. **O que já temos.** Inventário (com `ls`/`rg`, sem ler arquivos grandes inteiros):
   - skills: `p-inga/.agents/skills`, `gira-g` skills, `pi-harness` (`skill_catalog`, `skill_sync`, `.pi/extensions`), `_preservacao/G-Inga-archived` (`/work`, `skills/`, `hooks/`);
   - hooks: o do Claude que bloqueia `git add -A`, o `hk`/lefthook pre-commit, o `pinga install`, o `pinga precommit`.
   - Diga o que é duplicado, o que está morto e o que é útil.
3. **Skills + sandbox:**
   - como entregar **só o necessário** por papel e por TASK (mount somente leitura da pasta da skill, toolchain bun, rede `none`/allowlist);
   - como os scripts TypeScript da skill rodam dentro da sandbox e devolvem JSON;
   - qual a diferença entre um hook **fora** da sandbox (o host aplica e o modelo não contorna) e um hook **dentro** dela;
   - riscos: injeção via SKILL.md, script com rede, segredos.
4. **Determinismo.** O que deve ser script e o que deve ser prompt, com exemplos nossos: validar frontmatter, checar a unicidade do `pinga_task` no ledger, `tokens.sh`, classificar `BLOCKED:` (INTENT-0008), o teto de custo. Relacione com a H3 do PLAN-0016 e diga se isso muda o desenho do experimento.
5. **Uma fonte, vários runtimes.**
   - Proponha a fonte única (ex.: `.ginga/skills/<nome>/{SKILL.md,scripts/*.ts}` + `hooks.toml` + perfis de sandbox no `project.toml`).
   - Proponha o gerador (`ginga install`/`init`), que projeta essa fonte para o formato de cada runtime.
   - Diga qual pacote é dono (g-inga, manda ou pinga) e como isso se encaixa nos PLAN-0006/0015 sem duplicar.
6. **Recomendação:** sim, não ou parcial, com o motivo. Inclua um MVP mínimo (2–3 skills e 2–3 hooks que pagam o custo já) e o que fica para depois.

## Saída

- `.ginga/knowledge/research/skills-e-hooks.md`: em português, conciso, com tabelas, no máximo ~250 linhas, e as fontes no fim.
- Ao terminar: `HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "Pesquisa skills+hooks pronta: .ginga/knowledge/research/skills-e-hooks.md — recomendação: <1 linha>"`.
