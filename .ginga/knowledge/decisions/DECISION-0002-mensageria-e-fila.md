---
type: decision
title: Mensageria via Hermes (adapter) e fila fora do Hermes
status: accepted
timestamp: 2026-10-27
---
## Mensageria

- O **Hermes é o adapter padrão da porta de notificação**, não uma dependência.
  - Saída: `hermes send -t <plataforma:chat[:thread]>`, sem LLM e sem precisar do gateway rodando. Cobre Discord, Telegram, Slack, WhatsApp e Signal.
  - Entrada: o gateway do Hermes e um plugin que traduz comandos e respostas em verbos do `ginga` de forma determinística. Só a conversa livre passa pelo LLM, que usa a skill do ginga.
- Fallbacks: webhook direto do Discord (`p-inga/src/discord.ts`) e stdout/log.
- Em aberto: o gateway expõe botões interativos? Se não expuser, a v1 é "responder na thread".

## Fila

- **Fora do Hermes.** O dispatcher é determinístico e o estado fica no `state.db` do ginga. O `kanban` do Hermes não é usado, para não haver dois quadros.
- A lógica fica num comando só, **`ginga tick`**: idempotente, com claim e lease (base: `pinga queue`). Ele lê o estado, escolhe a TASK desbloqueada com quota disponível e despacha para o `manda` (Manda-CARU).
- Gatilhos, todos com o mesmo `tick`:
  - `ginga serve`, por evento e timer;
  - systemd timer `--user`;
  - cron do Hermes (opcional).

## Onde o ginga roda

- **Um host por workspace** (o homelab) roda `ginga serve` como serviço systemd do usuário.
- As outras máquinas e o celular são **clientes**: a Roda Web pela rede (ex.: Tailscale), Discord e Telegram pelo Hermes, a CLI apontando para o host.
- Sem daemon, tudo funciona no modo manual (`ginga tick` ou o timer).
