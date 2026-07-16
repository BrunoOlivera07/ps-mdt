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

## Files that concentrate i18n changes
- `web/src/locales/*`
- `web/src/lib/i18n.ts`
- `web/scripts/check-locales.mjs`
