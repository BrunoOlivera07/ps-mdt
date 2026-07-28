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
- Nenhuma divergência de chaves entre `en-US` e `pt-BR` no frontend.
- Nenhuma referência ausente entre os locales Lua `en-US` e `pt-BR`.
- Nenhuma pendência de tradução identificada pela auditoria conjunta.

## Testes executados
- `npm.cmd run build`
- `npm.cmd run check`
- `npm.cmd run check:locales`
- `node scripts/check-lua-locales.mjs`
- `node scripts/check-sql-translations.mjs`

## Resultado da compilação
- `npm.cmd run check:locales`: concluído com `missing: []`, `extra: []` e `hardcoded: []`.
- `npm.cmd run build`: concluído com sucesso; 458 módulos transformados e `web/dist` atualizado localmente.
- Locales Lua: 868 referências validadas e 885 chaves disponíveis em cada idioma.
- SQL: 580 valores visíveis validados em cada schema, com placeholders, tags HTML e apóstrofos portáveis preservados; os cinco tipos internos de modelos não são traduzidos.
- Migração existente: 328 atualizações condicionais dentro de transação, incluindo cinco reparos de tipos legados.
- `npm.cmd run check`: mantém 56 erros e 173 avisos preexistentes em 44 arquivos, fora do escopo da tradução; o build de produção não é bloqueado por eles.

## Limitações encontradas
- `web/dist` é usado pelo `fxmanifest.lua`, mas está ignorado pelo Git; deve ser regenerado com `npm.cmd run build` após checkout ou atualização.
- Nomes próprios, siglas e identificadores funcionais são preservados.
- Textos administrativos salvos no banco não são traduzidos dinamicamente pelo seletor de idioma.
- O scanner anterior verificava apenas sete palavras em inglês e não falhava quando encontrava hardcodes. Isso foi corrigido e a lista de padrões confiáveis foi ampliada.

## Último ponto concluído
- Migração completa do frontend concluída com `pt-BR` padrão e `en-US` como fallback.
- Seletor de idioma funcional em desenvolvimento e produção, com preferência persistida localmente.
- Catálogo de permissões concluído: 19 categorias e 63 permissões traduzidas sem alterar identificadores enviados ao backend.
- Auditoria automatizada e ampliada limpas; build final concluído em 16/07/2026.
- Auditoria global reaberta em 17/07/2026; falsos negativos confirmados em `ManagementColors`, `ManagementTemplates`, `Vehicles` e `Map` foram migrados para locales.
- Tradução de Lua, seeds `qbx.sql`/`qbcore.sql` e migração não destrutiva concluídas em 17/07/2026.
- Revisão SQL reproduzível pelos scripts de tradução, revisão terminológica, geração da migração e validação estrutural.

## Auditoria profunda de integridade - 18/07/2026
- Nenhum arquivo rastreado foi excluído e os 689 registros públicos de eventos, callbacks, comandos e exports foram preservados.
- Os 94 arquivos Lua passaram na validação sintática; a topologia dos 69 arquivos Lua modificados foi preservada, exceto pela correção intencional em `server/backend/management.lua`.
- Corrigida a navegação DOJ que não renderizava a aba `Bulletin Board`, embora a página e a permissão ainda existissem.
- Corrigida a normalização de abas ocultas com espaços, incluindo `tab_hidden_bulletin_board`.
- Corrigida a classificação de cargos na tela de permissões: somente o cargo realmente configurado como chefe é bloqueado para edição.
- Migrados os hardcodes residuais de `ContentArea`, `ManagementLicenses`, `PPR` e `Weapons`; a auditoria agora também valida placeholders entre idiomas e padrões desses campos.
- O banco ativo contém as 63 tabelas `mdt_*` e todas as colunas esperadas pelo `qbx.sql`; as seeds administrativas obrigatórias estão presentes.
- `mdt_permission_roles` está vazio no banco ativo. Isso não remove páginas, mas cargos não-chefe ficam sem acesso até que um chefe configure suas permissões em Configurações.
- Categorias de boletim são criadas em tempo de execução por emprego; uma tabela inicialmente vazia não representa perda de schema ou seed.
- Comparação completa com a base `3.1.4`: nenhum botão, campo, seletor, função, callback ou export foi removido. Permanecem 273 callbacks de servidor, 286 callbacks NUI estáticos e 13 exports.
- Corrigida a ocultação do botão de inserir modelo na nova ocorrência. A tradução havia alterado `mdt_report_templates.type`, quebrando a correspondência com os tipos internos do frontend.
- Os cinco tipos do banco ativo foram reparados, o backend normaliza instalações legadas e o `npm run dev` agora fornece modelos localizados de demonstração.
- Preservada a sigla funcional `SWAT`, que havia sido traduzida incorretamente como `GOLPE` nos seeds e no banco ativo.
- Segunda auditoria semântica migrou textos visíveis residuais de câmeras, gizmo, relatórios, mandados, evidências, veículos, armas, sentenciamento, apreensão e rastreamento.
- O scanner Lua agora rejeita também notificações, títulos de diálogos, ajuda, placeholders e fallbacks visíveis escritos diretamente no código.
- O botão de inserir modelo permanece em `ReportMetadata.svelte`; em produção depende dos tipos internos dos modelos SQL e, no `npm run dev`, recebe cinco modelos localizados de demonstração.
- O histórico de prisão é gravado ao salvar um relatório do tipo interno `Arrest Report` com pelo menos uma pessoa envolvida marcada como suspeita; prender alguém isoladamente não cria esse registro no MDT.
- O schema ativo de `brutal_housing` e `ps-housing` foi conferido com os presets automáticos. O sentenciamento automático prioriza `p_policejob` e mantém `pickle_prisons` como fallback.
- Build final repetido em 18/07/2026 com sucesso: 458 módulos transformados e `web/dist` atualizado.
- Corrigido o contrato de erros de mandados e os timeouts das buscas rápidas: mensagens do backend agora chegam ao frontend, buscas possuem debounce e chamadas iguais são serializadas para não colidir no `ps_lib`.
- Corrigidas as chaves do pátio que estavam em `components.vehicles`, embora a tela consultasse `pages.vehicles`; pesquisa, filtros, ações e estados do pátio voltaram a resolver em ambos os idiomas.
- A auditoria do frontend passou a validar referências literais de `t()` e `tf()` contra os catálogos. A nova regra também encontrou e corrigiu namespaces residuais na prévia de cores, licenças, status comuns e visão civil.
- O banco ativo foi conferido e não possui valores de apreensão semelhantes a chaves de locale; o problema do pátio era restrito ao frontend.
- A tela de Treinamento/FTO foi revisada novamente: filtros, atualização, criação de treinamento, progresso, critérios de avanço, DORs, resultado final e confirmações deixaram de usar textos ingleses diretos.
- A auditoria ganhou padrões de regressão específicos para os hardcodes encontrados em FTO.

## Integração ps-dispatch - 18/07/2026
- Chamados criados no mapa do MDT passam a ser registrados na lista real do `ps-dispatch` e usam o ID retornado pelo provedor.
- Notas, anexos de unidades e encerramentos são sincronizados entre MDT e `ps-dispatch`.
- O fluxo anterior com IDs `mdt-*` permanece como fallback automático quando o recurso ou os exports de integração não estiverem disponíveis.
- A integração é controlada por `Config.Dispatch.SyncWithPsDispatch`; a aparência do alerta é configurável em `Config.Dispatch.PsAlert`.

## Revisão de Configurações - 18/07/2026
- As 13 abas da página de gerenciamento passaram a resolver seus rótulos pelos locales.
- As 16 categorias de rastreamento de auditoria tiveram rótulos e descrições migrados para `en-US` e `pt-BR`.
- O título das categorias do mural e os comunicados de demonstração do `npm run dev` foram traduzidos.
- Identificadores dos Material Icons, como `campaign`, `local_police`, `school` e `forum`, foram preservados para não quebrar a renderização dos ícones.
- A auditoria agora rejeita novas listas visíveis com `label`, `description` ou comunicados de demonstração escritos diretamente nesses componentes.
- Corrigido o seletor de metas em Condecorações: os rótulos localizados agora são avaliados antes da renderização, em vez de exibir o código da função `t()`.
- Corrigida a apresentação dos tipos de relatório nos seletores, modelos e visão civil; os valores internos em inglês continuam preservados para compatibilidade com banco e backend.
- Separados os relatórios por domínio: EMS não recebe mais modelos, filtros ou indicadores de prisões/mandados; foram adicionados cinco modelos médicos e indicadores de atendimento, trauma e overdose. A mesma proteção foi aplicada ao DOJ.
- O backend corrige uma única vez os modelos policiais legados marcados como `all`, cria os padrões ausentes de EMS/DOJ e valida o tipo permitido antes de salvar novos modelos.
