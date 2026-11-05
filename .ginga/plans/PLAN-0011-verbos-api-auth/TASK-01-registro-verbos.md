---
type: task
mode: padrao
goal: "Um registro único de verbos implementa intent, approve, reject, answer, decide, pause, resume, retry, escalate, cancel, budget raise e as leituras"
title: Registro de verbos
plan: PLAN-0011-verbos-api-auth
pinga_task: T120
repo: ginga
depends_on: []
tier: medium
touch: [src/verbs/registry.ts, src/verbs/write.ts, src/verbs/read.ts, src/verbs/audit.ts, tests/verbs.test.ts]
done_when: "bun test tests/verbs.test.ts"
tests_frozen: [tests/verbs.test.ts]
---
## Fazer
- Verbo = `{name, args, write: bool, run(ctx, args) → JSON}`; `ctx` tem `by`, `via`, raiz do bundle e `state.db`.
- `intent new` cria `INTENT-NNNN-slug.md` com `source: via`; `approve|reject` mudam o frontmatter; `answer|decide` gravam no `state.db` e na seção "Respostas" do artefato; `pause|resume|retry|escalate|cancel|budget raise` só `state.db`.
- Escrita → linha no `log.md` do PLAN + `transition`/`answer`. Leituras: `status`, `board`, `inbox`, `watch` (stream).
## Não fazer
- Nenhuma regra fora do registro.
## Contexto
- Doc 05 §2 (tabela de verbos); `src/state/db.ts` (PLAN-0010).
