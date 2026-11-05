---
type: plan
title: Bundle .ginga no duh-homelab + cleanup da raiz
intent: INTENT-0002-workspace-bundle
status: done
done_when: "test -f .ginga/index.md && test -f .ginga/models/ROUTING.md && test -f _archive/MANIFEST.md"
---
## Abordagem

Aplicar a convenção do [doc 04](../../knowledge/design/ginga-revamp/04-artefatos.md) à mão, antes de existir ferramenta. Nada é apagado: o legado vai para `_archive/`, com manifesto.

O estado do pi-harness que ainda roda na raiz fica onde está, porque `.pi/harness.json` aponta para ele: `.pi/`, `features/`, `specs/.active`, `dreams/`, `LESSONS.md`.

## TASKs

1. [TASK-01](TASK-01-bundle-e-cleanup.md): criar o bundle, mover o design e arquivar o legado
2. [TASK-02](TASK-02-models-routing.md): registro de modelos por runtime + política de roteamento e budget
3. [TASK-03](TASK-03-index-e-entrada.md): `index.md` como quadro de trabalho + apontar CLAUDE.md/AGENTS.md para ele
