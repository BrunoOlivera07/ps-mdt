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
- Página `web/src/pages/doj/CourtCases.svelte` migrada e removida da auditoria
- Página `web/src/pages/doj/CourtOrders.svelte` migrada e removida da auditoria
- Página `web/src/pages/doj/LegalDocuments.svelte` migrada e removida da auditoria
- Página `web/src/pages/doj/WarrantReview.svelte` migrada; pasta `web/src/pages/doj` concluída e removida da auditoria
- Página `web/src/pages/Awards.svelte` migrada e removida da auditoria
- Página `web/src/pages/Bolos.svelte` migrada e removida da auditoria
- Página `web/src/pages/BulletInBoard.svelte` migrada e removida da auditoria
- Página `web/src/pages/Cases.svelte` migrada e removida da auditoria
- Página `web/src/pages/Charges.svelte` migrada e removida da auditoria
- Página `web/src/pages/Citizens.svelte` migrada e removida da auditoria
- Página `web/src/pages/CivilianView.svelte` migrada e removida da auditoria
- Página `web/src/pages/ComplaintForm.svelte` migrada e removida da auditoria
- Página `web/src/pages/Dashboard.svelte` migrada e removida da auditoria
- Página `web/src/pages/Evidence.svelte` migrada e removida da auditoria
- Página `web/src/pages/FTO.svelte` migrada e removida da auditoria
- Página `web/src/pages/IA.svelte` migrada e removida da auditoria
- Página `web/src/pages/Map.svelte` migrada e removida da auditoria
- Página `web/src/pages/PPR.svelte` migrada e removida da auditoria
- Página `web/src/pages/ReportEditor.svelte` migrada e removida da auditoria
- Página `web/src/pages/Reports.svelte` migrada e removida da auditoria
- Página `web/src/pages/Roster.svelte` migrada e removida da auditoria
- Página `web/src/pages/SOP.svelte` migrada e removida da auditoria
- Página `web/src/pages/Vehicles.svelte` migrada e removida da auditoria
- Página `web/src/pages/Weapons.svelte` migrada e removida da auditoria
- `web/src/constants/index.ts` migrado e removido da auditoria; nomes internos de abas e valores de payload preservados
- `web/src/constants/management.ts` removido da auditoria; catálogo bilíngue permanece em locales e todas as chaves de permissão foram preservadas
- `web/src/services/authService.svelte.ts` migrado e removido da auditoria; fluxo de autenticação e permissões preservado
- `web/src/services/dashboardService.svelte.ts` migrado e removido da auditoria; carregamento e carrossel preservados
- `web/src/services/reportService.svelte.ts` migrado e removido da auditoria; tipos e payloads internos preservados
- Auditoria atual: `missing: []`, `extra: []`, `hardcoded: []`

## Chaves pendentes
- Nenhuma pendência detectada pela auditoria automatizada.
- Auditoria ampliada de markup e atributos concluída; literais técnicos, IDs, siglas e conteúdo vindo do backend foram preservados.

## Testes executados
- `npm.cmd run build`
- `npm.cmd run check`
- `npm.cmd run check:locales`

## Resultado da compilação
- `npm.cmd run check:locales`: concluído com `missing: []`, `extra: []` e `hardcoded: []`.
- `npm.cmd run build`: concluído com sucesso; 458 módulos transformados e `web/dist` atualizado localmente.
- `npm.cmd run check`: mantém 56 erros e 173 avisos preexistentes em 44 arquivos, fora do escopo da tradução; o build de produção não é bloqueado por eles.

## Limitações encontradas
- `web/dist` é usado pelo `fxmanifest.lua`, mas está ignorado pelo Git; deve ser regenerado com `npm.cmd run build` após checkout ou atualização.
- Textos administrativos salvos no banco de dados, nomes próprios, siglas e conteúdo recebido do backend não são traduzidos automaticamente.

## Último ponto concluído
- Migração completa do frontend concluída com `pt-BR` padrão e `en-US` como fallback.
- Seletor de idioma funcional em desenvolvimento e produção, com preferência persistida localmente.
- Catálogo de permissões concluído: 19 categorias e 63 permissões traduzidas sem alterar identificadores enviados ao backend.
- Auditoria automatizada e ampliada limpas; build final concluído em 16/07/2026.
