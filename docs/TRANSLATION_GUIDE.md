# Translation Guide

## Locale files
- `web/src/locales/en-US.ts`
- `web/src/locales/pt-BR.ts`
- `web/src/locales/index.ts`
- `web/src/lib/i18n.ts`

## Default language
- Default: `pt-BR`
- Fallback: `en-US`

## Add a key
1. Add the key to `en-US.ts`.
2. Add the same key to `pt-BR.ts`.
3. Use `t("section.key")` in the component.

## Add a new screen
1. Move visible strings to locale keys.
2. Keep internal IDs, events, exports, routes and database fields unchanged.
3. Rebuild the frontend.

## Audit
- Run `npm run check:locales` from `web/`.
- A auditoria do frontend agora falha quando encontra um hardcode confiável.
- A auditoria também valida todas as referências literais em `t()` e `tf()`; uma chave presente nos dois idiomas, mas no namespace incorreto, faz o comando falhar.
- Execute `node scripts/check-lua-locales.mjs` na raiz para validar referências e paridade dos locales Lua.
- Execute `node scripts/check-sql-translations.mjs` na raiz para validar estrutura, placeholders, HTML e a migração SQL.
- O seletor da interface não altera registros já persistidos no banco.

## Database content
- Preserve códigos, tipos, enums, chaves, nomes de recursos e demais identificadores funcionais.
- Traduza somente campos apresentados ao usuário, como `label`, `description`, `name`, `title`, `content`, `mission_statement` e `introduction`.
- Atualizar as seeds atende instalações novas; bancos existentes precisam executar a migração pt-BR específica.
- Para uma instalação nova, importe somente `sql/qbx.sql` ou `sql/qbcore.sql`, conforme o framework.
- Para uma instalação existente, faça backup e execute `sql/migrate_pt-BR.sql`; os `WHERE` preservam linhas que já foram personalizadas.

## Regenerar SQL
1. Execute `node scripts/translate-sql-seeds.mjs` para gerar as seeds a partir da versão `HEAD` em inglês.
2. Execute `node scripts/review-sql-translations.mjs` para aplicar a terminologia revisada.
3. Execute `node scripts/generate-sql-migration.mjs` para recriar a migração não destrutiva.
4. Execute `node scripts/check-sql-translations.mjs` antes de importar qualquer arquivo.

## Build
- Run `npm run build` from `web/`.
- The build writes `web/dist`, which is consumed by `fxmanifest.lua` but ignored by Git in this repository.

## Update workflow
1. Create a backup commit or branch.
2. Pull or merge upstream changes.
3. Resolve conflicts without replacing locale files.
4. Run locale audit.
5. Add new upstream keys to `en-US.ts`.
6. Translate them into `pt-BR.ts`.
7. Run type check and build.
8. Validate the resource.

## Adding upstream permissions
1. Preserve the permission key in `web/src/constants/management.ts`.
2. Add its label and description under `management.permissions.catalog.items` in both locale files.
3. Preserve category keys and add category labels under `management.permissions.catalog.categories`.
4. Run the locale audit and production build.

## Conflict strategy
- Keep locale files as the translation source of truth.
- Avoid editing compiled `dist/` output.
- Prefer updating source files only.

## Atualização do ps-dispatch
- O adaptador usa os exports de servidor `CreateDispatchCall`, `UpdateDispatchCall` e `RemoveDispatchCall` adicionados em `ps-dispatch/server/main.lua`.
- Depois de atualizar o `ps-dispatch`, preserve esses três exports e o evento de cliente `ps-dispatch:client:syncCalls`.
- Se a API estiver ausente, o MDT não interrompe o uso: ele volta automaticamente aos chamados internos com ID `mdt-*`.
- Inicie `ps-dispatch` antes de `ps-mdt` para que a sincronização esteja disponível desde a abertura do painel.

## Files that concentrate i18n changes
- `web/src/locales/*`
- `web/src/lib/i18n.ts`
- `web/scripts/check-locales.mjs`
