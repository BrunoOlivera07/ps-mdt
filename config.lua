Config = {}
ps = exports.ps_lib:init()

--Configurações básicas
Config.Debug = false --Ativa/desativa o modo de depuração (booleano)
Config.OnlyShowOnDuty = true --Permitir que o MDT seja aberto somente quando estiver em serviço (booleano)

-Configurações de acesso civil
Config.CivilianAccess = {
    enabled = true,   --Permitir que civis abram o MDT (somente visualização de perfil + legislação)
    command = true,   --Permitir comando /mdt para civis
    showWarrants = false, --Mostrar mandados ativos no perfil civil
    showBolos = false,    --Mostrar BOLOs ativos no perfil civil
}

-Configurações de hora e data
Config.DateTime = {
    TimeFormat = '24', --Formato para exibição da hora ('24' ou '12')
    DateFormat = "DD-MM-YYYY" --Formato para exibição da data (string: "MM-DD-AAAA", "DD-MM-AAAA" ou "AAAA-MM-DD")
}

-Compartilhamento de dados do departamento
Config.Sharing = {
    -Compartilhamento mútuo (bidirecional)
    --Todos os departamentos deste grupo podem ver os dados uns dos outros
    Mutual = {
        types = {
            'reports',
            'bodycams',
            'evidence',
            'bolos',
            'warrants'
        },
        departments = {
            'lspd',
            'bcso',
            'sahp'
        }
    },

    -Compartilhamento unidirecional (unidirecional)
    --Os visualizadores podem ver os dados do departamento alvo, mas não vice-versa
    OneWay = {
        { --Exemplo: FIB e GOV
            viewers = {
                'fib',
                'gov'
            },
            targets = {
                'lspd',
                'bcso',
                'sahp'
            },
            types = {
                'reports',
                'bodycams',
                'evidence',
                'bolos',
                'warrants',
            }
        },
    },
}

-Atalhos de teclado
Config.Keys = {
    --https://docs.fivem.net/docs/game-references/controls/| QWERTY padrão
    OpenMDT = {
        enabled = true, --Ativar/desativar atalho de teclado (booleano)
        key = 'F11', --Chave para abrir o MDT (string)
    },
}

--Comandos
Config.Commands = {
    Open = {
        enabled = true, --Comando ativar/desativar (booleano)
        command = 'mdt', --Comando para abrir o MDT (string)
    },
    MessageOfTheDay = {
        enabled = true, --Comando ativar/desativar (booleano)
        command = 'motd', --Comando para definir a mensagem do dia (string)
    },
}

--Configurações de envio
Config.Dispatch = {
    --Qual recurso de despacho alimenta o MDT. Provedores suportados:
    --'ps' → despacho ps 'qs' → despacho qs 'cd' → cd_dispatch
    --'auto' escolhe qualquer um dos três que esteja em execução no momento.
    Provider = 'auto',
    FilterByJob = true,
}

-10 códigos oferecidos no modal "Criar Chamada". `code` aparece no menu suspenso,
--`label` é o nome humano (também usado como título da chamada se nenhum for digitado).
Config.DispatchCodes = {
    { code = '10-13', label = 'Officer Needs Assistance' },
    { code = '10-71', label = 'Shooting' },
    { code = '10-90', label = 'Robbery' },
    { code = '10-80', label = 'Pursuit' },
    { code = '10-15', label = 'Civil Disturbance' },
    { code = '10-52', label = 'Ambulance Needed' },
    { code = '10-53', label = 'Vehicle Accident' },
    { code = '10-66', label = 'Suspicious Activity' },
    { code = '10-11', label = 'Traffic Stop' },
    { code = '10-62', label = 'Meet Complainant' },
    { code = '911',   label = 'General 911 Call' },
}

-Configurações do leitor de placas Wolfknight
Config.UseWolfknightRadar = true --Ativar/desativar a integração do radar Wolfknight
Config.WolfknightNotifyTime = 5000 --Duração (ms) para notificações do leitor de placas
Config.PlateScanForDriversLicense = true -Verifique a carteira de motorista na digitalização da placa

-Configurações de impressão digital
Config.FingerprintAutoFilled = false -Preencher automaticamente as impressões digitais nos perfis dos cidadãos (se forem falsas, os policiais deverão adicionar manualmente as impressões digitais)

-Integração de digitalização de impressão digital
Config.FingerprintScan = {
    enabled = true,                                         --Habilite o gatilho de leitura de impressão digital do MDT
    officerEvent = 'police:client:showFingerprint',          -Evento do cliente acionado no oficial
    suspectEvent = 'police:client:showFingerprint',          -Evento do cliente acionado no suspeito
}

--Nome do recurso de combustível
Config.Fuel = 'LegacyFuel' --Nome do recurso de combustível para gerenciamento de combustível de veículos

--Integração telefônica (fonte única de verdade) ---------------------------------
--Um lugar para tudo relacionado ao telefone: resolver o número de cidadão para o
-Perfil MDT E envio de SMS de lembrete judicial /e-mails de convite. Aponte isso para o seu
-recurso de telefone uma vez e ambos os recursos o utilizam, para que nunca possam se separar.
--Deixe Resource = '' para usar charinfo.phone para exibição e desabilitar SMS/mail judicial.
Config.Phone = {
    Resource     = 'lb-phone',                    --nome do recurso do script de telefone ('' = apenas charinfo.phone, sem SMS/mail)
    NumberExport = 'GetEquippedPhoneNumber',      --export retornando um número de cidadão para um Citizenid
    UseCharinfoFallback = true,                   --se a exportação não retornar nada, volte para charinfo.phone

    -Mensagens judiciais (usa o mesmo recurso acima)
    SmsSenderNumber = 'SA-COURT',                 --número "de" mostrado no SMS de lembrete (qualquer string que o lb-phone aceita)
    MailSender      = 'San Andreas Judicial System', --remetente mostrado na caixa de entrada do destinatário
}


-Assuntos Internos
Config.IA = {
    --Anti-spam: quanto tempo um cidadão deve esperar entre a apresentação de reclamações.
    CooldownMs = 300000, -5 minutos

    --Envie um e-mail ao reclamante quando a reclamação mudar de status. Usa o telefone
    --recurso do Config.Phone; ignorado silenciosamente se nenhum estiver em execução.
    NotifyComplainant = true,
    MailSender = 'Internal Affairs',
}


--Integração Habitação /Propriedades
--O MDT mostra as propriedades que um cidadão possui em seu perfil. Cada habitação
--o recurso armazena isso em uma tabela diferente com nomes de coluna diferentes, então
– escolha o sistema que você executa abaixo – ou defina um mapeamento totalmente personalizado.
--
--Para trocar de sistema você normalmente altera SOMENTE `Config.Housing.system`.
Config.Housing = {
    enabled = true,             --false = oculta totalmente o recurso de propriedades (nenhuma consulta de banco de dados de alojamento é executada)
    system  = 'auto',           --detecta automaticamente um recurso em execução, escolha uma predefinição ou use 'personalizado'
    AutoPriority = {
        'brutal_housing',
        'ps_housing',
        'qbx_properties',
        'qb_houses',
    },

    --Predefinições: mapeamentos de esquemas prontos para recursos habitacionais populares.
    --`columns` mapeia os campos internos do MDT para as colunas reais da sua tabela:
    --proprietário = coluna contendo o CitizenID do proprietário (obrigatório)
    --id = coluna contendo o id exclusivo da propriedade (necessário para abrir uma única propriedade)
    --name = coluna mostrada como o nome/rótulo da propriedade
    --coords = coluna contendo coordenadas como JSON (usado para o botão "definir waypoint"; opcional)
--keyholders = coluna contendo keyholders como matriz/objeto JSON (opcional)
    --Defina uma coluna como nula se o seu sistema não a tiver.
    --
    --Para sistemas de DUAS TABELA (por exemplo, qb-houses), onde a definição de propriedade e
    --a propriedade fica em tabelas separadas, adicione um `join` (veja o arquivo qb_houses
    --predefinido abaixo para um exemplo completo).
    Presets = {
        --Propriedades do Qbox (padrão). Isso corresponde à tabela que o MDT usou antes
        --esta opção existia, então deixá-la selecionada mantém o comportamento antigo.
        qbx_properties = {
            resource = 'qbx_properties',
            table = 'properties',
            columns = {
                owner      = 'owner',
                id         = 'id',
                name       = 'property_name',
                coords     = 'coords',
                keyholders = 'keyholders',
            },
        },

        --Projeto Habitação Preguiça (ps-habitação).
        --ps-housing não tem uma única coluna de coordenadas (ele usa door_data), e o
        --o nome de exibição vem de `street`.
        ps_housing = {
            resource = 'ps-housing',
            table = 'properties',
            columns = {
                owner      = 'owner_citizenid',
                id         = 'property_id',
                name       = 'street',
                coords     = 'door_data',
                keyholders = 'has_access',
            },
        },

        -Habitação de Scripts Brutais. Propriedade e detalhes da propriedade são armazenados
        --juntos; o acesso à chave é gerenciado internamente pelo recurso.
        brutal_housing = {
            resource = 'brutal_housing',
            table = 'brutal_housing',
            columns = {
                owner      = 'owner',
                id         = 'id',
                name       = 'label',
                coords     = 'coords',
                keyholders = nil,
            },
        },

        --qb-houses (QBCore legado). Sistema de duas mesas: a propriedade reside em
        --`player_houses`, a definição da propriedade (label + coords) reside em
        --`houselocations`, vinculado por player_houses.house = houselocations.name.
        qb_houses = {
            resource = 'qb-houses',
            table = 'player_houses',   --tabela de propriedade
            columns = {
                owner      = 'citizenid',
                id         = 'id',
                name       = nil,      --retirado da tabela unida (rótulo)
                coords     = nil,      --retirado da tabela unida (coords)
                keyholders = 'keyholders',
            },
            join = {
                table = 'houselocations',                 --tabela de definições
                on    = { left = 'house', right = 'name' }, --player_houses.house=houselocations.name
                columns = {                                --extraia esses campos da tabela unida
                    name   = 'label',
                    coords = 'coords',
                },
            },
        },

        -Mapeamento totalmente personalizado. Defina Config.Housing.system = 'custom' e edite
        -os valores abaixo para corresponder ao banco de dados do seu recurso habitacional.
        custom = {
            table = 'properties',
            columns = {
                owner      = 'owner',
                id         = 'id',
                name       = 'property_name',
                coords     = 'coords',
                keyholders = 'keyholders',
            },
            --Remova o comentário e ajuste para um sistema de duas tabelas:
            --juntar = {
            --tabela = 'outra_tabela',
            --on = { left = 'local_col', right = 'other_col' },
            --colunas = { nome = 'rótulo', coordenadas = 'coords' },
            --},
        },
    },
}

--────────────────────────────────────── ─────────────────── ────────────────────
-Veículo MDT -Pontos de Licença
--────────────────────────────────────── ─────────────────── ────────────────────
--Os "pontos de licença" são mostrados no perfil MDT de um veículo e (opcionalmente) no
-lista de veículos. Os oficiais os adicionam um de cada vez, ou por meio de predefinições rápidas, no
--visualização detalhada do veículo (requer a permissão `vehicles_edit_dmv`).
Config.VehiclePoints = {
    enabled   = false, --false = ocultar pontos em todos os lugares (coluna da lista, perfil, editor) e rejeitar gravações de pontos
    visualMax = 12,   --quantos pips a barra de pontos desenha antes de mostrar um emblema de estouro "+N"
}

--────────────────────────────────────── ─────────────────── ────────────────────
--Veículo MDT — Integração de Seguros
--────────────────────────────────────── ─────────────────── ────────────────────
-Quando ativado, o STATUS do veículo (a pílula mostrada no canto superior direito do perfil e
-na lista de veículos) é conduzido AO VIVO pelo seu recurso de seguro em vez de ser
--definido manualmente — os policiais não podem mais editar o status/motivo manualmente.
--
-Quando DESATIVADO, o status simplesmente é padronizado como "Válido" em todos os lugares e SEM seguro
--pesquisas são executadas.
--
--A pesquisa é totalmente configurável para que você possa apontá-la para qualquer script de seguro
-você corre. Exemplo (m-Insurance), que usa uma exportação estilo retorno de chamada:
--exportações['m-Insurance']:HasCarInsurance('ABC123', function(hasInsurance) ... fim)
--
--NOTA: as pesquisas sempre FALHA ABERTA — um recurso/exportação ausente, um erro ou um
--o tempo limite é tratado como "segurado", portanto, um script de seguro quebrado nunca pode ser erroneamente
-sinalizar todos os veículos como não segurados.
Config.VehicleInsurance = {
    enabled  = false,
    resource = 'm-Insurance',     --recurso que expõe a exportação
    export   = 'HasCarInsurance', --exporta o nome para ligar

    --Como a exportação fornece sua resposta:
    --callback = true -> exportações[recurso]:export(placa, função(hasInsurance) fim)
    --callback = false -> local hasInsurance = exports[resource]:export(plate)
    callback = true,

    timeout  = 2000, --ms para aguardar uma resposta de retorno de chamada antes de falhar na abertura (tratado como segurado)

    -Resolver o seguro para CADA linha da lista de veículos? Em servidores grandes isso é
    -uma pesquisa por veículo. Defina false para resolvê-lo apenas na visualização detalhada (o
    --a lista mostra então "Válido" até que um veículo seja aberto).
    resolveInList = true,

    --Como o resultado segurado/não segurado é mapeado na pílula de status/motivo existente:
    insuredStatus   = 'valid',                -status quando o veículo ESTÁ segurado
    uninsuredStatus = 'uninsured',            -status quando NÃO está segurado
    uninsuredReason = 'No active insurance',  --texto do motivo mostrado ao lado da pílula
}

--────────────────────────────────────── ─────────────────── ────────────────────
--Veículo MDT — Integração de Registro
--────────────────────────────────────── ─────────────────── ────────────────────
--Um irmão de Config.VehicleInsurance. Quando ativado, o REGISTRO de um veículo
--(mostrado como seu próprio campo Registrado/Não registrado no perfil + no veículo
--list, e como um comprimido na visualização de detalhes do perfil) é resolvido AO VIVO a partir de um
--recurso configurável. Quando desativado, cada veículo simplesmente lê “Registrado”
--e NÃO são realizadas pesquisas de registro.
--
--A pesquisa é totalmente configurável. Exemplo (m-Insurance), que utiliza um
--exportação estilo retorno de chamada:
--exportações['m-Insurance']:HasCarRegistration('ABC123', function(hasReg) ... end)
--
--NOTA: as pesquisas sempre FALHA ABERTA — um recurso/exportação ausente, um erro ou um
--o tempo limite é tratado como "registrado", portanto, um script quebrado nunca pode sinalizar erroneamente
-todos os veículos como não registrados.
Config.VehicleRegistration = {
    enabled  = false,
    resource = 'm-Insurance',        --recurso que expõe a exportação
    export   = 'HasCarRegistration', --exporta o nome para ligar

    --Como a exportação fornece sua resposta:
    --callback = true -> exportações[recurso]:export(placa, função(hasReg) fim)
    --callback = false -> local hasReg = exports[resource]:export(plate)
    callback = true,

    timeout  = 2000, --ms para aguardar uma resposta de retorno de chamada antes de falhar na abertura (tratado como registrado)

    --Resolver registro para CADA linha da lista de veículos? Em servidores grandes isso
    --é uma pesquisa por veículo. Defina false para resolvê-lo apenas na visualização detalhada
    --(a lista mostra então "Registrado" até que um veículo seja aberto).
    resolveInList = true,

    --Texto do motivo mostrado ao lado da pílula quando um veículo NÃO está registrado:
    unregisteredReason = 'No active registration',
}

-Registro de armas
Config.RegisterWeaponsAutomatically = false -Registro automático de armas na compra (ox_inventory e qb-inventory/qb-weapons)
Config.RegisterCreatedWeapons = false --Também registra automaticamente armas na criação de itens (somente ox_inventory)

--Caminho da imagem da arma
Config.WeaponImagePath = 'nui://ox_inventory/web/images/'
--────────────────────────────────────── ─────────────────── ────────────────────
-Apreender
--────────────────────────────────────── ─────────────────── ────────────────────
-Liberar um veículo o coloca de volta na garagem do proprietário -eles
-recupere-o lá como qualquer outro carro. Os lotes são puramente um registro de ONDE o
-o veículo está detido enquanto está apreendido.
Config.Impound = {
    Lots = {
        { id = 'lspd',   label = 'LSPD Impound' },
        { id = 'paleto', label = 'Paleto Impound' },
    },

    --Motivos de confisco oferecidos no MDT, cada um com uma taxa padrão (o oficial
    -ainda pode editar a taxa durante a apreensão).
    --`hold` é o ID de duração (veja Durações abaixo) que é pré-selecionado quando um
    -o oficial escolhe esse motivo. É uma recomendação, não uma regra: o policial pode
    -sempre altere-o antes de arquivar. Omita-o e a razão voltará a
    --Duração padrão.
    Reasons = {
        { label = 'Evidence / Investigation', fee = 0,    hold = 'hold' },
        { label = 'Reckless Driving',         fee = 750,  hold = '1d' },
        { label = 'Illegal Parking',          fee = 250,  hold = 'immediate' },
        { label = 'Unregistered Vehicle',     fee = 500,  hold = 'immediate' },
        { label = 'Stolen Vehicle Recovery',  fee = 0,    hold = 'immediate' },
        { label = 'DUI',                      fee = 1500, hold = '3d' },
        { label = 'Illegal Modifications',    fee = 1000, hold = '1d' },
        { label = 'Abandoned Vehicle',        fee = 300,  hold = 'immediate' },
    },

    DefaultFee = 500,
    MaxFee     = 50000,
    --Conta da qual é cobrada a taxa de liberação ('banco' ou 'dinheiro').
    FeeAccount = 'bank',
    -Exigir que a taxa seja paga antes que um veículo possa ser liberado.
    RequireFeePaid = true,

    --Quanto tempo o veículo é retido antes de poder ser liberado.
    --dias = 0 → liberável imediatamente
    --dias = n → mantido por n dias
    --dias = nil → mantido até que um oficial decida o contrário
    -A taxa ainda precisa ser paga em cima; a espera é uma questão de tempo, não de dinheiro.
    Durations = {
        { id = 'immediate', label = 'Releasable immediately', days = 0 },
        { id = '1d',        label = '1 day',                  days = 1 },
        { id = '3d',        label = '3 days',                 days = 3 },
        { id = '7d',        label = '7 days',                 days = 7 },
        { id = 'hold',      label = 'Until an officer releases it' },
    },
    DefaultDuration = 'hold',

    -Envie um e-mail ao proprietário quando seu veículo for apreendido, cobrado ou liberado.
    --O proprietário geralmente não está perto do veículo quando isso acontece, então uma mensagem na tela
    -a notificação que eles nunca veem é pior que inútil. Usa Config.Phone.
    NotifyOwner = true,
    MailSender  = 'Vehicle Impound Unit',

    --Taxa de armazenamento: aumenta a cada dia que o veículo fica no estacionamento, limitado para que
    -nunca pode fugir. Calculado a partir da data de apreensão, nunca acumulado por um
    -temporizador, para que ele sobreviva às reinicializações e não possa desviar.
    Storage = {
        PerDay  = 500,
        MaxDays = 7,    --depois de tantos dias, a taxa de armazenamento para de crescer
    },

    -Apreensão no local: /apreensão leva o veículo em que o policial está, ou o
    -o mais próximo. Veículos que ninguém possui (tráfego de NPCs) são simplesmente removidos e
    -o policial recebe um pequeno pagamento por manter as ruas limpas.
    OnSite = {
        Command   = 'mdtimpound',
        -A que distância o policial pode ficar do veículo.
        MaxDistance = 6.0,

        --O policial documenta o veículo e depois o transmite por rádio. Ambas as etapas são
        -cancelável: ir embora aborta a apreensão e nada é escrito.
        Sequence = {
            NotepadMs = 4500,   -escrevendo na área de transferência
            RadioMs   = 6000,   -chamando o caminhão de reboque
        },

        -Uma vez concluída a papelada, o veículo desaparece e é removido.
        FadeMs = 1500,

        Cleanup = {
            --Pagamento pela remoção de um veículo sem dono, randomizado nesta faixa.
            RewardMin   = 100,
            RewardMax   = 200,
            Account     = 'cash',
            -Antiabuso: segundos entre pagamentos e quantos um policial pode
            --ganho por turno (reinicia quando eles saem de serviço /o servidor reinicia).
            -tudo está registrado
            Cooldown    = 120,
            MaxPerShift = 20,
        },
    },
}

-Configurações de trabalho
Config.PoliceJobType = "leo"
Config.PoliceJobs = {
    'lspd',
    'bcso',
    'sahp',
    'fib',
    'gov'
}

-Integração na prisão. O modo automático prefere p_policejob, depois pickle_prisons e
-usa o evento de prisão QBCore existente como substituto final.
Config.Sentencing = {
    system = 'auto', --auto/pickle_prisons/p_policejob/qb_policejob
    pickleResource = 'pickle_prisons',
    picklePrison = 'default',
    pPoliceResource = 'p_policejob',
    pPoliceCommand = 'prender',
    pPoliceType = 'prisao',
}

Config.DojJobType = "doj"
Config.DojJobs = {
    'lawyer',
    'judge',
}

Config.MedicalJobType = "ems"
Config.MedicalJobs = {
    'ambulance',
}

Config.Uploads = {
    MaxBytes = 5242880, -5 MB
    RateLimitPerMinute = 10, --Máximo de uploads por jogador por minuto (0 = ilimitado)
    AllowedAttachmentTypes = {
        'image/jpeg',
        'image/png',
        'image/webp',
        'application/pdf'
    },
    AllowedEvidenceImageTypes = {
        'image/jpeg',
        'image/png',
        'image/webp'
    }
}

--Limites de paginação
Config.Pagination = {
    Citizens = 20, -Cidadãos por página
    CitizenSearch = 20, -Máximo de resultados de pesquisa de cidadãos
    Cases = 20, --Casos por página
    CitizenCharges = 5, --Cobranças por página na seção Cobranças do perfil Cidadão
}

--Processamento fino
Config.Fines = {
    MaxAmount = 100000,   -Valor máximo da multa ($) para evitar explorações econômicas
    CooldownMs = 30000,   --Tempo de espera anti-spam entre multas (milissegundos)
}

-Padrões de garantia
Config.Warrants = {
    DefaultExpiryDays = 7, -Expiração do mandado padrão quando nenhuma data é fornecida
}

-----------------------------------------------------------------------------
--Limpeza de dados pessoais (núcleo da Fase 1)
-----------------------------------------------------------------------------
-Quando um oficial é demitido, o painel do chefe pode, opcionalmente, limpar isso
--pegada MDT PESSOAL da pessoa. A regra orientadora: remova apenas os dados que
--pertence ao indivíduo (seu próprio arquivo/pegada) e não pode prejudicar
-investigações em andamento ou registros de outros oficiais.
--
--EXCLUÍDOS (seus próprios dados): tags de perfil, sessões, identificadores, registros de relógio,
-galeria, status de oficial, reconhecimentos de SOP, arquivo de estagiário FTO,
-PPRs escritos SOBRE eles, mensagens que enviaram, adesão à patrulha e auditoria
--registra entradas sobre eles.
--
--SEMPRE MANTIDOS (investigativos/compartilhados/outros oficiais): relatórios, cobranças,
-evidências, BOLOs, casos, mandados, prisões, armas, registros judiciais,
--licenses, a linha de identidade principal mdt_profiles (mantida em cascata com FK
--linhas investigativas como mandados nunca são removidos), sentença/penal/SOP
--definições e qualquer registro de autoria da pessoa no arquivo de OUTRA PESSOA
-(por exemplo, DORs que eles escreveram como treinadores, PPRs que eles criaram sobre outros).
--
--O esquema do mecanismo de limpeza verifica cada tabela/coluna em tempo de execução, portanto falta
--ou tabelas renomeadas são ignoradas em vez de apresentarem erros. Alterne as partes opcionais:
Config.PersonnelCleanup = {
    --Chave mestre: mesmo que o chefe marque a caixa, a limpeza só é executada quando isso
    -é verdade. Permite que os proprietários de servidores desabilitem totalmente o caminho destrutivo.
    Enabled = true,

    --Remova as linhas do log de auditoria cujo assunto (entity_id) é a pessoa demitida.
    --Seus registros de ações como atores são deixados intactos para prestação de contas, a menos que você
    -habilite também DeleteActorAuditLogs abaixo.
    DeleteSubjectAuditLogs = true,

    --Remova também as linhas do log de auditoria onde a pessoa demitida era o ATOR. Desativado por
    --padrão porque apaga o histórico de "quem fez o quê" em que outros funcionários podem confiar.
    DeleteActorAuditLogs = false,

    --Remova as mensagens enviadas pela pessoa demitida.
    DeleteSentMessages = true,
}

--TTLs do cache do painel (segundos)
Config.CacheTTL = {
    ReportStats = 30,
    ActiveUnits = 10,
    UsageMetrics = 60,
}

-Animação de tablet
Config.Animation = {
    Dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a',
    Name = 'idle_a',
}

-Câmera Mugshot
Config.MugshotCamera = {
    DefaultFov = 50.0,
    FovMin = 15.0,
    FovMax = 80.0,
    FovSpeed = 5.0,
}

-Visualizador de câmera de segurança
Config.CameraViewer = {
    RotationSpeed = 0.15,
    ZoomClamp = { min = 0.25, max = 10.0 },
    StartingZoom = 3.0,
    ZoomStep = 0.1,
    FovMin = 10.0,
    FovMax = 100.0,
    FovStep = 2.0,
    --Deslocamento de guinada (graus) aplicado à *visão*de câmeras que geram uma imagem real
    -Suporte CCTV (colocados pelo jogador). Esses adereços estão voltados para o lado oposto do
    --direção do olhar da câmera, então o feed precisa de +180. Câmeras virtuais
    --(spawns_model = false) não são afetados. Defina como 0,0 se seus modelos de suporte
    -já olhe para o lado certo.
    HeadingOffset = 180.0,
    -Sobreposição de CFTV na tela mostrada durante a visualização de uma câmera
    Overlay = {
        enabled = true,
        showTimestamp = true,   --data/hora real (canto superior direito)
        recBlink = true,        --indicador REC piscando (falso = sempre ligado)
    },
}

--=========================================================================
-Dashcams (câmeras de veículos policiais)
-IMPORTANTE: um veículo só recebe uma câmera de painel funcionando se seu modelo estiver listado em
--`Positions.models` abaixo. Veículos não configurados ainda aparecem na câmera
--list, mas abri-los retorna um erro em vez de um feed. Não há
--`padrão` de propósito -isso evita que todos os carros de polícia trabalhem silenciosamente.
--Os deslocamentos estão no espaço local do veículo: lateral = +direita, frente = +frente,
--altura = +para cima (metros), pitch = inclinação da câmera (o negativo olha para baixo). Traseira
--os valores são opcionais e retornam aos valores iniciais. Chaves são nomes de spawn.
--=========================================================================
Config.Dashcam = {
    --São considerados apenas veículos desta classe (18 = Emergência, igual ao
    -sistema de rastreamento usado para identificar veículos policiais). Verificado no cliente.
    EmergencyClass = 18,
    --Com que frequência (ms) o servidor envia a posição ao vivo de uma unidade para a câmera do painel
    --espectadores. Menor = mais suave para unidades distantes, mas com mais tráfego de rede.
    UpdateInterval = 250,
    Positions = {
        models = {
            ['police']  = { side = 0.0, forward = 0.75, height = 0.55, pitch = 1.0, rearForward = 1.2, rearHeight = 0.60, rearPitch = 1.0 },
            -['police2'] = {lado = 0,0, frente = 1,1, altura = 0,85, altura = -6,0},

            --Exemplo com uma câmera traseira sintonizada separadamente:
            -['fbi2'] = { forward = 2,0, height = 0,9, pitch = -5,0, rearForward = 2,4, rearHeight = 0,8, rearPitch = -8,0 },
        },
    },
}

--Permissões e padrões de gerenciamento (por nível de trabalho)
Config.ManagementPermissions = {
    -Cidadãos
    'citizens_search',
    'citizens_edit_licenses',
    --BOLOS
    'bolos_view',
    'bolos_create',
    -Veículos
    'vehicles_search',
    'vehicles_edit_dmv',
    -Armas
    'weapons_search',
    'weapons_add',
    -Casos
    'cases_view',
    'cases_create',
    'cases_edit',
    'cases_delete',
    -Evidência
    'evidence_view',
    'evidence_create',
    'evidence_transfer',
    'evidence_upload',
    --Relatórios
    'reports_view',
    'reports_create',
    'reports_delete',
    -Garantias
    'warrants_view',
    'warrants_issue',
    'warrants_close',
    -Encargos
    'charges_view',
    'charges_edit',
    -Despacho
    'map_patrols_view',
    "map_patrols_manage",
    "map_patrols_edit",
    'dispatch_attach',
    'dispatch_route',
    'dispatch_assign',
    'dispatch_notes',

    -Apreender
    'vehicle_impound',
    'vehicle_impound_release',
    'vehicle_impound_override',
    -Câmeras e câmeras corporais
    'cameras_view',
    'bodycams_view',
    'dashcams_view',
    -Notas
    'notes_edit_department',
    -Lista
    'roster_manage_certifications',
    'roster_manage_officers',
    -PPR
    'ppr_view',
    'ppr_manage',
    -FTO
    'fto_view',
    'fto_manage',
    -Quadro de avisos
    'bulletin_view',
    'bulletin_post',
    'bulletin_pin',
    --Calendário (audiências judiciais são tribunal_*; treinamentos/reuniões/outros são treinamento_*)
    'court_view',
    'court_create',
    'court_edit',
    'court_delete',
    'training_view',
    'training_create',
    'training_edit',
    'training_delete',
    -Assuntos Internos
    'ia_view',
    'ia_manage',
    -POP
    'sop_view',
    'sop_manage',
    --Gerenciamento
    'management_permissions',
    'management_bulletins',
    'management_activity',
    'management_tags',
    'management_tracking',
    'management_settings',
}

-Configurações da Bodycam (substitua os padrões se necessário, remova para usar os padrões integrados)
Config.Bodycam = {
    DutyEvent = 'QBCore:Server:OnJobUpdate',
    DutyEventMode = 'qbcore',
    MultiJobDutyEvent = 'ps-multijob:server:dutyChanged',
    DutyResource = 'qb-core',
    MultiJobResource = 'ps-multijob',
}

--Status do Oficial (guia Mapa) ------------------------------------------------------------------
--Define todos os status selecionáveis. `id` é a chave estável armazenada no banco de dados e
-enviado pela rede -nunca renomeie um ID existente, apenas adicione novos, ou
--os oficiais que salvaram um status antigo retornarão ao padrão abaixo.
--`id` : chave estável (string, sem espaços, letras minúsculas recomendadas)
--`label`: nome de exibição mostrado na UI
--`color`: hexadecimal usado para o crachá/ponto e anel marcador do mapa
--`icon` : emoji opcional/glifo curto mostrado ao lado do rótulo (puramente visual)
--Para adicionar um novo status, basta anexar uma nova entrada — nenhum outro arquivo precisa ser alterado.
Config.OfficerStatus = {
    list = {
        { id = 'active', label = 'Active', color = '#22C55E', icon = '●' },
        { id = 'busy',   label = 'Busy',   color = '#F59E0B', icon = '●' },
        --Exemplos de status futuros (descomente/ajuste conforme necessário):
        --{ id = 'enroute', label = 'En Route', color = '#3B82F6', icon = '●' },
        --{ id = 'indisponível', label = 'Indisponível', color = '#EF4444', icon = '●' },
        --{ id = 'break', label = 'On Break', color = '#8B5CF6', icon = '●' },
    },
    --ID de status assumido para qualquer oficial que nunca tenha definido um.
    Default = 'active',
    --Comprimento máximo para a nota de texto livre opcional (por exemplo, "Traffic Stop").
    MaxNoteLength = 60,
    --Mínimo ms entre duas mudanças de status do mesmo player (anti-spam).
    ChangeCooldownMs = 1500,
}

--Padrões opcionais para permissões de função por cargo/classe
-Exemplo:
--Config.PermissionDefaults={
--polícia = {
--['0'] = { 'relatórios_de acesso' },
--['1'] = { 'access_reports', 'view_bodycams' },
--}
--}
Config.PermissionDefaults = Config.PermissionDefaults or {}

-ALTAMENTE recomendado não usar isso nativamente. Use FiveManage para isso.
--Activity Tracking -Controla quais ações são registradas na trilha de auditoria
-As categorias podem ser ativadas/desativadas na página Configurações no MDT
--Estes são os valores PADRÃO; alterações de tempo de execução são armazenadas na tabela mdt_settings
Config.AuditTracking = {
    authentication = true,   -Eventos de login/logout
    reports = true,          -Criar relatório, atualizar, excluir
    cases = true,            -Caso CRUD, atribuições de oficiais, anexos
    evidence = true,         -Evidência CRUD, transferências, imagens
    warrants = true,         --Warrant emitido/fechado
    vehicles = true,         -Atualizações de veículos, apreensão/liberação
    weapons = true,          -Criar, atualizar, excluir arma
    charges = true,          -Multas processadas, cobranças atualizadas
    searches = false,        -Pesquisas de cidadãos/jogadores/oficiais (alto volume)
    dispatch = true,         -Sinal 100 ativar/desativar
    officers = true,         -Mudanças de indicativo
    sentencing = true,       -Pena de prisão
    arrests = true,          -Registro de prisão
    icu = true,              -Exclusão de registro de UTI
    cameras = true,          -Acesso à câmera de segurança
    bodycams = true,         -Acesso à câmera corporal do oficial
}

--Modelos de câmeras disponíveis para posicionamento de câmera estática
Config.CameraModels = {
    ['security_cam_01'] = 'v_serv_securitycam_1a',
    ['security_cam_02'] = 'v_serv_securitycam_03',
    ['security_cam_03'] = 'ba_prop_battle_cctv_cam_01a',
    ['security_cam_04'] = 'prop_cctv_cam_06a',
    ['security_cam_05'] = 'ba_prop_battle_cctv_cam_01b',
    ['security_cam_06'] = 'prop_cctv_cam_01b',
    ['security_cam_07'] = 'ch_prop_ch_cctv_cam_02a',
    ['security_cam_08'] = 'prop_cctv_cam_04c',
    ['security_cam_09'] = 'prop_cctv_cam_03a',
    ['security_cam_10'] = 'ch_prop_ch_cctv_cam_01a',
    ['security_cam_11'] = 'prop_cctv_cam_01a',
    ['security_cam_12'] = 'prop_cctv_cam_05a',
    ['security_cam_13'] = 'prop_cctv_cam_07a',
    ['security_cam_14'] = 'prop_cctv_cam_04b',
    ['security_cam_15'] = 'tr_prop_tr_camhedz_cctv_01a',
    ['security_cam_16'] = 'prop_cctv_cam_02a',
    ['security_cam_17'] = 'prop_cctv_cam_04a',
    ['cctv_cam_01'] = 'm24_1_prop_m24_1_carrier_bank_cctv_02',
    ['cctv_cam_02'] = 'xm_prop_x17_cctv_01a',
    ['cctv_cam_03'] = 'prop_cctv_pole_02',
    ['cctv_cam_04'] = 'm24_1_prop_m24_1_carrier_bank_cctv_01',
    ['cctv_cam_05'] = 'prop_cctv_pole_04',
    ['cctv_cam_06'] = 'xm_prop_x17_server_farm_cctv_01',
    ['cctv_cam_07'] = 'prop_cctv_pole_03',
    ['cctv_cam_08'] = 'p_cctv_s',
    ['cctv_cam_09'] = 'hei_prop_bank_cctv_02',
}

--=========================================================================
-Colocador de câmera estática (ferramenta de administração)
--Abre um menu no jogo para criar/editar/reposicionar/excluir estática
-câmeras de segurança usando um dispositivo 3D. O comando de entrada é registrado através
--lib.addCommand do ox_lib, cujo campo `restricted` lida com o controle administrativo
--server-side (ele cria automaticamente o `command.<name>` ás).
--=========================================================================
Config.CameraPlacer = {
    command = 'cameraplacer',  --Comando de bate-papo que abre o menu do placer
    restricted = 'group.admin', --grupo restrito ox_lib/ace tem permissão para usá-lo
}

-Quais armas devem poder ser registradas manualmente
Config.Weapons = {
    { model = "weapon_heavypistol", label = "Heavy Pistol" },
    { model = "weapon_sniperrifle", label = "Hunting Rifle" },
    { model = "weapon_ceramicpistol", label = "Ceramic Pistol" },
    { model = "weapon_doubleaction", label = "Double-Action Revolver" },
    { model = "weapon_navyrevolver", label = "Navy Revolver" },
    { model = "weapon_musket", label = "Musket" },
}
--=========================================================================
-Tribunal /Calendário (audiências, reuniões, treinamentos)
-Aciona o calendário do DOJ: SMS de lembrete, e-mails de convite, status automático
-ciclo de vida e grupos de adição rápida de participantes.
--=========================================================================
Config.Court = {
    -Quantos minutos antes da audiência o SMS de lembrete é enviado.
    ReminderLeadMinutes = 15,

    -Quando uma audiência criada a partir de um mandado for concluída, resolva automaticamente o
    --BOLO vinculado (correspondente ao reportId do mandado). Defina falso para cancelar.
    ResolveBolosOnComplete = true,

    --Prazo de entrega padrão (dias) para audiências agendadas diretamente de um mandado
    -através do botão "Agendar audiência" na lista de mandados.
    WarrantHearingLeadDays = 2,

    ------SMS de lembrete (substitui a antiga notificação do MDT) ----------------------
    Sms = {
        enabled = true,
        SendDelayMs = 25,    --ms entre cada envio para que grandes listas de convidados não aumentem o quadro
    },

    ------Convidar e-mail na criação -----------------------------------------
    Email = {
        enabled = true,
        --Se uma audiência for criada com MAIS participantes do que isso, o valor por pessoa
        -os e-mails são totalmente ignorados (eles ainda recebem o SMS de lembrete). Isto
        -evita picos de atraso em grandes listas de convidados.
        MaxRecipients = 25,
        SendDelayMs = 50,    --ms entre cada envio de e-mail
    },

    ------Ciclo de vida de status automático ---------------------------------------
    AutoStatus = {
        enabled = true,
        --agendado -> in_session assim que o agendamento_at for alcançado
        --in_session -> concluído uma vez agendado_at + duração + tolerância passada
        CompleteGraceMinutes = 5,
        --true = uma audiência concluída é excluída (limpeza automática do calendário)
        --false = uma audiência concluída é mantida com o status 'concluído'
        DeleteOnComplete = true,
    },

    ------Grupos de adição rápida de participantes (botões no modal criar/editar) ----
    --id: identificador estável
    --label: texto do botão
    --role: função do participante que as pessoas adicionadas em massa recebem (consulte VALID_ROLES)
    --domínio: 'police' (polícia + DOJ compartilham um calendário) ou 'ems' (separado)
    --jobType: corresponde à estrutura job.type (leo/doj/ems...)
    --jobs: lista de permissões explícita opcional de nomes de trabalho (substitui jobType)
--maxGrade: teto opcional de nível de série (por exemplo, novatos = nota 0-1)
    --onlyOnDuty: inclui apenas jogadores atualmente em serviço
    Groups = {
        -Domínio Polícia /DOJ
        { id = 'all_officers', label = 'All Officers',  role = 'officer',  domain = 'police', jobType = Config.PoliceJobType },
        { id = 'rookies',      label = 'Rookies',       role = 'officer',  domain = 'police', jobType = Config.PoliceJobType, maxGrade = 1 },
        { id = 'on_duty',      label = 'On-Duty Units', role = 'officer',  domain = 'police', jobType = Config.PoliceJobType, onlyOnDuty = true },
        { id = 'all_doj',      label = 'All DOJ',       role = 'attendee', domain = 'police', jobType = Config.DojJobType },
        { id = 'judges',       label = 'Judges',        role = 'judge',    domain = 'police', jobs = { 'judge' } },
        { id = 'lawyers',      label = 'Lawyers',       role = 'attendee', domain = 'police', jobs = { 'lawyer' } },

        -Domínio EMS (calendário separado)
        { id = 'all_ems',       label = 'All EMS',        role = 'attendee', domain = 'ems', jobType = Config.MedicalJobType },
        { id = 'ems_rookies',   label = 'EMS Rookies',    role = 'trainee',  domain = 'ems', jobType = Config.MedicalJobType, maxGrade = 1 },
        { id = 'ems_on_duty',   label = 'On-Duty EMS',    role = 'attendee', domain = 'ems', jobType = Config.MedicalJobType, onlyOnDuty = true },
    },
}
--═════════════════════════════════════ ══════════════════════════════════════
-Rádio em MDT
-Permite que os jogadores pressionem para falar no rádio enquanto o MDT está aberto. Porque o
-O MDT mantém o foco total do NUI (o teclado vai para a IU, não para o jogo), a IU
--ele próprio captura a chave PTT e a encaminha para o cliente, o que aciona o
-sistema de voz ativo. Nenhum RegisterKeyMapping extra é adicionado -sempre que possível
-o teclado de rádio EXISTENTE do player é detectado e reutilizado.
--═════════════════════════════════════ ══════════════════════════════════════
Config.Radio = {
    Enabled = true,

    --Qual recurso de voz direcionar:
    --'auto' → detecta o primeiro em execução (ordem abaixo no AutoDetect)
    --'pma-voz' | 'chat salgado' | 'yaca' → forçar um sistema específico
    VoiceSystem = 'auto',

    -Tecla PTT de fallback que o MDT escuta SE o atalho de teclado real não puder ser lido
    --(valor KeyboardEvent do navegador — um código como 'AltLeft'/'CapsLock' ou um
    --caractere único como 'n'). Escolha uma chave não textual para evitar conflito com
    -digitando relatórios. A chave de rádio real do jogo é detectada automaticamente quando
    -possível e tem prioridade sobre isso.
    PTTKey = 'AltLeft',

    --Gatilho por sistema + qual chave de comando ler para o ouvinte NUI.
    --type = 'comando' → ExecuteCommand(iniciar) /ExecuteCommand(parar)
    --type = 'exportar' → exportações[recurso][fn](estado)
    --`keyCmd` é o comando de mapeamento de teclado cuja chave vinculada lemos (nil = use o
    --PTTKey substituto). `startCandidates` nos permite combinar comandos renomeados como fork.
    Systems = {
        ['pma-voice'] = {
            type = 'command',
            start = '+radiotalk',
            stop = '-radiotalk',
            keyCmd = '+radiotalk',
            startCandidates = { '+radiotalk' },
        },
        ['saltychat'] = {
            type = 'command',
            start = '+primaryRadio',
            stop = '-primaryRadio',
            keyCmd = '+primaryRadio',
            -Os garfos do SaltyChat nomeiam isso de forma diferente; primeiras vitórias registradas.
            startCandidates = { '+primaryRadio', '+radioPrimary', '+SaltyChat_RadioPrimary' },
        },
        ['yaca'] = {
            type = 'export',
            resource = 'yaca-voice',
            fn = 'radioTalkingStart',
            --YACA conduz rádio através de uma exportação; nenhum comando estável para ler, então
            -o NUI escuta o PTTKey substituto (defina-o como sua chave YACA).
            keyCmd = nil,
        },
    },

    --ordem de detecção 'automática': { system = key in Systems, resource = res name }.
    AutoDetect = {
        { system = 'pma-voice', resource = 'pma-voice' },
        { system = 'saltychat', resource = 'saltychat' },
        { system = 'yaca',      resource = 'yaca-voice' },
    },
}
