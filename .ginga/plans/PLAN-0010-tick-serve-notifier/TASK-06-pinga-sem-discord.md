---
type: task
mode: mvp
goal: "Com $GINGA_EVENTS definido o pinga só emite eventos e não chama o Discord; o discord.ts não lê mais ~/.hermes"
title: pinga deixa de notificar direto (A4)
plan: PLAN-0010-tick-serve-notifier
repo: p-inga
depends_on: []
tier: free
pinga_task: T23
touch: [src/discord.ts, src/cli.ts, tests/discord_events.test.ts]
done_when: "bun test tests/discord_events.test.ts"
tests_frozen: [tests/discord_events.test.ts]
---
## Fazer
- `pinga notify` e o notify da `queue`: com `$GINGA_EVENTS`, nenhum `fetch` ao Discord.
- `resolveDiscordConfig`: só `DISCORD_BOT_TOKEN`/`DISCORD_CHANNEL_ID`; sem canal padrão fixo (l. 58).
- Atualizar `tests/discord.test.ts` caso 1 para usar HOME falso (env `DISCORD_BOT_TOKEN`/`DISCORD_CHANNEL_ID`, como em `tests/helpers/home.ts`), sem depender do `~/.hermes` real nem do canal fixo.
## Não fazer
- Não apagar o `discord.ts` ainda (fallback de quem usa o pinga sozinho).
## Contexto
- `src/discord.ts` (l. 14-66), `src/cli.ts:1638` (`notify`).
