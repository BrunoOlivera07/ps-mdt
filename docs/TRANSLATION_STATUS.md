# Translation Status

## Áreas analisadas
- `web/package.json`
- `web/src`
- `web/src/pages`
- `web/src/components`
- `config.lua`
- `fxmanifest.lua`
- `client`
- `server`

## Arquivos migrados
- `web/src/main.ts`
- `web/src/pages/Settings.svelte`
- `web/src/components/management/ManagementLicenses.svelte`
- `web/src/components/management/ManagementTags.svelte`
- `web/src/components/management/ManagementTemplates.svelte`
- `web/src/components/ActivityTimeline.svelte`
- `web/src/components/management/ManagementSOP.svelte`
- `web/src/components/report-editor/ReportHeader.svelte`
- `web/src/components/ReportEditorHeader.svelte`
- `web/src/components/report-editor/PersonSearchModal.svelte`
- `web/src/components/report-editor/SuspectsManager.svelte`
- `web/src/components/report-editor/VehiclesManager.svelte`
- `web/src/components/report-editor/ChargesManager.svelte`
- `web/src/components/report-editor/EvidenceManager.svelte`
- `web/src/components/EvidenceManager.svelte`
- `web/src/components/InvolvedPersons.svelte`
- `web/src/components/dashboard/DispatchStatusWidget.svelte`
- `web/src/components/dashboard/ReportItem.svelte`
- `web/src/components/impound/ImpoundFormFields.svelte`
- `web/src/locales/en-US.ts`
- `web/src/locales/pt-BR.ts`
- `web/src/locales/index.ts`
- `web/src/lib/i18n.ts`
- `web/scripts/check-locales.mjs`

## Telas traduzidas
- `Settings`
- `ManagementLicenses`
- `ActivityTimeline`
- `ManagementTags`
- `ManagementTemplates`
- `ManagementJailFines`
- `ManagementActivity`
- `ManagementSOP`
- Cabeçalhos, busca de pessoas, suspeitos e veículos do editor de ocorrências
- Acusações, evidências e pessoas envolvidas do editor de ocorrências
- Pasta `web/src/components/dashboard` revisada e concluída
- Pasta `web/src/components/impound` revisada e concluída
- Pasta `web/src/components/management` revisada e concluída, incluindo `management/permissions`
- Componentes raiz migrados nesta leva: `ReportMetadata`, `InstanceTabs`, `TagManager`, `Pagination`, `ChargeType`, `SOPAgreementOverlay`, `LoginOverlay` e acessibilidade de `MugshotCamera`
- Componentes raiz concluídos com tradução de navegação, permissões e placeholders
- Pasta `web/src/components/report-editor` revisada e concluída
- Página `web/src/pages/Bodycams.svelte` migrada e removida da auditoria
- Página `web/src/pages/Cameras.svelte` migrada e removida da auditoria
- Página `web/src/pages/ImpoundForm.svelte` revisada manualmente e migrada
- Página `web/src/pages/Warrants.svelte` migrada e removida da auditoria
- Página `web/src/pages/doj/CourtCalendar.svelte` migrada e removida da auditoria

## Chaves pendentes
- Auditoria ainda aponta muitos arquivos do `web/src` com textos hardcoded.

## Testes executados
- `npm.cmd run build`
- `npm.cmd run check`
- `npm.cmd run check:locales`

## Resultado da compilação
- Build do frontend concluído com sucesso.

## Limitações encontradas
- O recurso não possui camada de i18n pronta.
- Há textos hardcoded espalhados em componentes Svelte.

## Último ponto concluído
- `ManagementSOP` e a primeira leva do editor de ocorrências migrados.
- Próximo alvo: `web/src/pages/ComplaintForm.svelte`.
- Catálogo de permissões concluído: 19 categorias e 63 permissões traduzidas sem alterar os identificadores enviados ao backend; textos upstream são mantidos como fallback para novas atualizações.
- Primeira leva do catálogo de permissões concluída: cidadãos, ocorrências, casos, evidências e alertas de busca. Categorias ainda não migradas usam o texto upstream como fallback.
- Segunda leva do catálogo concluída: mandados, veículos, armas, acusações e efetivo.
- Terceira leva do catálogo concluída: avaliações de desempenho, treinamento de campo, câmeras, despacho e corregedoria.
- Leva final do catálogo concluída: procedimentos operacionais, mural, calendário e gerenciamento.
- `npm.cmd run build` concluído com sucesso; `svelte-check` mantém erros preexistentes fora do escopo de tradução.
