---
type: task
mode: padrao
goal: "Porta de notificação com adapters hermes, webhook do Discord e stdout, em cadeia de fallback"
title: Porta de notificação
plan: PLAN-0010-tick-serve-notifier
repo: ginga
depends_on: []
tier: medium
pinga_task: T22
touch: [src/notify/port.ts, src/notify/hermes.ts, src/notify/discord.ts, src/notify/stdout.ts, tests/notify_port.test.ts]
done_when: "bun test tests/notify_port.test.ts"
tests_frozen: [tests/notify_port.test.ts]
---
## Fazer
- `send({target, text, thread?})`: hermes (`hermes send -t <plataforma:chat[:thread]>`, spawn injetável) → discord (REST v10, token/canal de env ou `[notify.discord]`) → stdout.
- Falha de um adapter cai para o próximo e registra o motivo.
## Não fazer
- Não ler `~/.hermes/*`; sem canal padrão no código.
## Contexto
- `p-inga/src/discord.ts` (`sendDiscordMessage` l. 71, `formatReceiptDiscordEmbed` l. 110); DECISION-0002.
