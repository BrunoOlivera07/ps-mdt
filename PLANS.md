# Plano

## Em andamento
- [x] Inventariar textos visíveis e pontos de integração do locale.
- [x] Implementar `en-US`, `pt-BR` e helper `t()`.
- [ ] Migrar textos da UI para chaves de locale.
- [x] Adicionar auditoria automatizada de locales.
- [x] Documentar processo de atualização futura.
- [ ] Continuar migração dos arquivos restantes apontados pela auditoria.
- [x] Adicionar seletor de idioma nas preferências.

## Concluído
- [x] Base inicial de i18n e documentação criada.
- [x] `Settings`, `ManagementLicenses`, `ActivityTimeline`, `ManagementTemplates` e `ManagementTags` migrados.
- [x] `ManagementJailFines` e `ManagementActivity` migrados.
- [x] `ManagementSOP` migrado.
- [x] Primeira leva do editor de ocorrências migrada: cabeçalhos, busca, suspeitos e veículos.
- [x] Segunda leva do editor de ocorrências migrada: acusações, evidências e pessoas envolvidas.
- [x] Pasta `web/src/components/dashboard` revisada e migrada.
- [x] Pasta `web/src/components/impound` revisada e migrada.
- [x] Pasta `web/src/components/management` revisada, incluindo `management/permissions`; falsos positivos da auditoria corrigidos.
- [x] Migrar o catálogo de apresentação de permissões em `web/src/constants/management.ts`, preservando todas as chaves internas.
  - [x] Infraestrutura de fallback e categorias `citizens`, `reports`, `cases`, `evidence` e `bolos`.
  - [x] Categorias `warrants`, `vehicles`, `weapons`, `charges` e `roster`.
  - [x] Categorias `ppr`, `fto`, `cameras`, `dispatch` e `ia`.
  - [x] Categorias `sop`, `bulletin_board`, `calendar` e `management`; catálogo completo.
- [x] Componentes diretamente em `web/src/components` revisados e migrados.
- [x] Pasta `web/src/components/report-editor` revisada e migrada.
- [x] Página `Bodycams.svelte` migrada.
- [x] Página `Cameras.svelte` migrada.
- [x] Página `ImpoundForm.svelte` migrada.
- [x] Página `Warrants.svelte` migrada.
- [x] Página `web/src/pages/doj/CourtCalendar.svelte` migrada.
