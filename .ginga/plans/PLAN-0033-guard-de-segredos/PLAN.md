---
type: plan
title: Guard de segredos nas lanes (Pi, opencode, Hermes)
intent: INTENT-0013-guard-de-segredos
spec: SPEC-0005-guard-de-segredos
kind: change
status: approved
repos: [ginga, duh-homelab, manda]
depends_on: []
done_when: "cd ginga && bun test tests/guard_ && python3 -B -I -m unittest discover -s contrib/guard/hermes -p 'test_*.py' && bash ../.ginga/bin/tests/guard-env.test.sh"
---
## Objetivo

Um hook por runtime que bloqueia a tool call **antes** de ela ler segredo e redige formato de chave no **resultado** antes de ele virar contexto, com uma lista única (`deny.json`) e um casador único (`core.ts`). Desenho, lista, riscos e o que não cobre: [guard-segredos-2026-10-29.md](../../knowledge/research/guard-segredos-2026-10-29.md). **Status `approved` pelo dono em 2026-10-29 ("ok", só PLAN e SPEC). Fase 2, TASK-06 e Hermes seguem pendentes de OK específico (pesquisa §8).**

## Decisões do Planner (o dono pode vetar)

- **Fonte no repo `ginga`**, em `src/guard/` (casador, dados, CLI) e `contrib/guard/` (adaptadores), como já é `contrib/hermes-plugin`. Dono dos hooks é o ginga (SPEC-0002 / `skills-e-hooks.md` §5).
- **Sem instalar em `~`.** Pi: `pi -e <repo>/contrib/guard/pi.ts` por execução. opencode: `OPENCODE_CONFIG_DIR=<repo>/contrib/guard/opencode-config` por execução (**a confirmar na Fase 2**). Hermes: plugin ativado por ação do dono (`plugins.enabled` do perfil), porque o Hermes não é runtime de lane hoje.
- **Escopo = variável de ambiente `GINGA_GUARD_LANE`**, exportada por `lane.sh`/`dispatch-task.sh`/`manda run`. Sem ela o guard é inerte. É melhor que o marcador `lane:` no system prompt do Pi: funciona igual nos três runtimes, o modelo não enxerga nem forja.
- **Falha fechada** (erro interno bloqueia; guard ausente com guard ligado = lane não inicia). É o contrário do PLAN-0032 (guarda de escopo, fail-open), de propósito: aqui o erro custa um segredo num dataset público; lá custa uma tentativa.
- **Um casador só.** Pi e opencode importam `core.ts`; o plugin Hermes chama `bun src/guard/cli.ts check` (≈12 ms por chamada, timeout 5 s, falha fechada). Sem segunda implementação em Python para divergir.
- Modos `enforce` (padrão) | `shadow` (registra e libera) | `off` (só o dono, em `lane.env`).

## TASKs

1. [TASK-01](TASK-01-core-e-lista.md): casador e `deny.json`
2. [TASK-02](TASK-02-run-e-cli.md): escopo, modos, eventos, falha fechada, CLI `check|redact`
3. [TASK-03](TASK-03-extensao-pi.md): extensão Pi
4. [TASK-04](TASK-04-plugin-opencode.md): plugin opencode
5. [TASK-05](TASK-05-plugin-hermes.md): plugin Hermes
6. [TASK-06](TASK-06-fiacao-das-lanes.md): `guard-env.sh` + `lane.sh` + `dispatch-task.sh`
7. [TASK-07](TASK-07-manda-runtimes.md): runtimes do `manda run` (depois dos PLAN-0029 e PLAN-0032)
8. [TASK-08](TASK-08-varredor.md): `guard sweep` e aviso no Discord
9. [TASK-09](TASK-09-run-deriva-guard-lane.md): `manda run` deriva `GINGA_GUARD_LANE=<PLAN>/<TASK>` e preenche `request.env` (achado grave do judge no TASK-07, 2026-11-01)

Ordem: 01 → 02 → (03, 04, 05, 08 em paralelo) → 06 → 07.
`touch` não se cruza entre as paralelas. TASK-08 acrescenta o verbo `sweep` ao `cli.ts` da 02 (por isso depende dela).

## Testes RED (escritos pelo Planner, congelados)

Rascunhos em [red/](red/) já no caminho final de cada repo. Antes de cada TASK, o dispatcher copia o arquivo para a worktree e roda `pinga prove-red`; o executor não toca. Eles foram validados num repo falso em `mktemp`: **contra o protótipo de referência ([ref/](ref/)) passam 93 testes TS + 9 Python + o teste de fiação; sem implementação, falham** (import inexistente, ou 41 de 62 no core com um stub que libera tudo). `ref/` é só contexto de leitura para o executor, não é código entregue.

## Fase 2 (manual, precisa do OK do dono; não é TASK de executor)

Prova no runtime real, com `.env` falso em `mktemp -d` e um modelo free já configurado (uma chamada de ~10 tokens por runtime):
1. `GINGA_GUARD_LANE=t pi -p -e contrib/guard/pi.ts --model <free> "leia .env"`: o log `guard.events.jsonl` tem `guard.block`.
2. `GINGA_GUARD_LANE=t OPENCODE_CONFIG_DIR=… opencode run --standalone -m <free> "leia .env"`: idem. Se `OPENCODE_CONFIG_DIR` não carregar o plugin, trocar só `guard_opencode_env()` por `OPENCODE_CONFIG_CONTENT='{"plugin":["file://…/opencode.ts"]}'`.
3. Hermes: só depois de o dono ativar o plugin num perfil de lane.
4. Ligar em `shadow` nas lanes por ~10 TASKs, ler `guard.block`, e só então `enforce`.
