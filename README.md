# duh-homelab

Workspace que coordena os repos do ecossistema G-Ingá. Este repo guarda só a **coordenação**: o quadro de trabalho (`.ginga/`), as decisões, os planos e as regras dos agentes (`AGENTS.md`, `CLAUDE.md`). O código mora nos repos irmãos.

| Repo | Pasta | Papel |
|---|---|---|
| [g-inga](https://github.com/EduardoShibukawa/g-inga) | `ginga/` | CLI `ginga`: ciclo INTENT → SPEC → PLAN → TASK |
| [manda](https://github.com/EduardoShibukawa/manda) | `manda/` | Despacho e execução de TASKs |
| [p-inga](https://github.com/EduardoShibukawa/p-inga) | `p-inga/` | Verificação formal e ledger (`pinga`) |
| [gira-g](https://github.com/EduardoShibukawa/gira-g) | `gira-g/` | Contexto semântico (`gira`) |
| [docs-benchmark](https://github.com/EduardoShibukawa/docs-benchmark) | `docs-benchmark/` | Benchmark de documentação |
| [spring-petclinic-modern](https://github.com/EduardoShibukawa/spring-petclinic-modern) | `spring-petclinic-modern/` | Alvo de dogfood (Java/Maven) |

## Começar (Linux ou macOS)

```bash
git clone https://github.com/EduardoShibukawa/duh-homelab.git
cd duh-homelab
./bootstrap.sh          # ou ./bootstrap.sh --all
```

O script instala o `mise`, clona os repos nas pastas acima e instala as dependências de cada um.

## Notas

- `bin/` e `scripts/` são específicos do ambiente Linux/tuios do autor.
- O `ledger.db` do pinga é local a cada máquina. Em uma máquina nova ele começa vazio, então use-a para rodar testes.
- Comece qualquer sessão de trabalho por [`.ginga/index.md`](.ginga/index.md).
- Licença: Apache-2.0 (ver `LICENSE`).
