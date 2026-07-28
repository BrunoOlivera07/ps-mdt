local resourceName = tostring(GetCurrentResourceName())

-- Action-to-category mapping
local ACTION_CATEGORIES = {
    mdt_login = 'authentication',
    mdt_logout = 'authentication',
    report_created = 'reports',
    report_updated = 'reports',
    report_deleted = 'reports',
    case_created = 'cases',
    case_updated = 'cases',
    case_deleted = 'cases',
    case_officer_assigned = 'cases',
    case_officer_removed = 'cases',
    case_attachment_added = 'cases',
    case_attachment_uploaded = 'cases',
    case_attachment_removed = 'cases',
    evidence_added = 'evidence',
    evidence_updated = 'evidence',
    evidence_deleted = 'evidence',
    evidence_transferred = 'evidence',
    evidence_image_added = 'evidence',
    evidence_image_removed = 'evidence',
    evidence_linked_case = 'evidence',
    case_created_from_evidence = 'evidence',
    warrant_issued = 'warrants',
    warrant_closed = 'warrants',
    vehicle_updated = 'vehicles',
    vehicle_impounded = 'vehicles',
    vehicle_released = 'vehicles',
    vehicle_impound_fee_paid = 'vehicles',
    vehicle_cleanup = 'vehicles',
    vehicle_impound_override = 'vehicles',
    weapon_created = 'weapons',
    weapon_updated = 'weapons',
    weapon_deleted = 'weapons',
    fine_processed = 'charges',
    charge_updated = 'charges',
    search_citizens = 'searches',
    search_players = 'searches',
    search_officers = 'searches',
    signal100_activated = 'dispatch',
    signal100_deactivated = 'dispatch',
    callsign_changed = 'officers',
    sent_to_jail = 'sentencing',
    arrest_logged = 'arrests',
    icu_deleted = 'icu',
    camera_viewed = 'cameras',
    bodycam_viewed = 'bodycams',
    -- ── Patrol management ────────────────────────────────────────────────────
    patrol_created          = 'patrols',
    patrol_deleted          = 'patrols',
    patrol_renamed          = 'patrols',
    patrol_zone_created     = 'patrols',
    patrol_zone_updated     = 'patrols',
    patrol_zone_cleared     = 'patrols',
    patrol_officer_assigned = 'patrols',
    patrol_officer_removed  = 'patrols',
    patrols_reordered       = 'patrols',
}

-- Cache for tracking config (loaded once, updated on save)
local trackingConfig = nil

local function getDefaultTracking()
    return Config and Config.AuditTracking or {
        authentication = true,
        reports = true,
        cases = true,
        evidence = true,
        warrants = true,
        vehicles = true,
        weapons = true,
        charges = true,
        searches = false,
        dispatch = true,
        officers = true,
        sentencing = true,
        arrests = true,
        icu = true,
        cameras = true,
        bodycams = true,
        patrols = true,   -- ← new
    }
end

local function loadTrackingConfig()
    local row = MySQL.single.await('SELECT `value` FROM mdt_settings WHERE `key` = ?', { 'audit_tracking' })
    if row and row.value then
        local ok, decoded = pcall(json.decode, row.value)
        if ok and type(decoded) == 'table' then
            -- Merge with defaults so new categories get their default value
            local defaults = getDefaultTracking()
            for k, v in pairs(defaults) do
                if decoded[k] == nil then
                    decoded[k] = v
                end
            end
            trackingConfig = decoded
            return trackingConfig
        end
    end
    trackingConfig = getDefaultTracking()
    return trackingConfig
end

function GetTrackingConfig()
    if trackingConfig then return trackingConfig end
    return loadTrackingConfig()
end

function IsActionTracked(action)
    local config = GetTrackingConfig()
    local category = ACTION_CATEGORIES[action]
    if not category then return true end -- unknown actions are always tracked
    if config[category] == nil then return true end
    return config[category] == true
end

-- Expose for audit.lua
ps.isActionTracked = IsActionTracked
ps.actionCategories = ACTION_CATEGORIES

-- Get tracking config callback
ps.registerCallback(resourceName .. ':server:getAuditTrackingConfig', function(source)
    local src = source
    if not CheckAuth(src) then return '{}' end
    -- Return as JSON string to preserve boolean false values through msgpack
    return json.encode(GetTrackingConfig())
end)

-- Save tracking config callback
ps.registerCallback(resourceName .. ':server:saveAuditTrackingConfig', function(source, payload)
    local src = source
    if not CheckAuth(src) then return { success = false, message = L('settings.unauthorized') } end

    -- Payload arrives as JSON string to preserve boolean false values through msgpack
    if type(payload) == 'string' then
        local ok, decoded = pcall(json.decode, payload)
        if ok and type(decoded) == 'table' then
            payload = decoded
        else
            return { success = false, message = L('settings.invalid_payload') }
        end
    end

    if type(payload) ~= 'table' then
        return { success = false, message = L('settings.invalid_payload') }
    end

    -- Validate: only allow known category keys with boolean values
    local defaults = getDefaultTracking()
    local sanitized = {}
    for k, _ in pairs(defaults) do
        if payload[k] ~= nil then
            sanitized[k] = payload[k] == true
        else
            sanitized[k] = defaults[k]
        end
    end

    MySQL.update.await([[
        INSERT INTO mdt_settings (`key`, `value`)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE `value` = VALUES(`value`)
    ]], { 'audit_tracking', json.encode(sanitized) })

    trackingConfig = sanitized

    ps.auditLog(src, 'settings_updated', 'settings', 'audit_tracking', sanitized)

    return { success = true }
end)

-- Jail / Fines Configuration

local jailFinesConfig = nil

local function getDefaultJailFinesConfig()
    return {
        reductionOffers = { 10, 25, 50 },  -- % options shown on the Reduction button
        maxFineAmount = (Config and Config.Fines and Config.Fines.MaxAmount) or 100000,
    }
end

local function loadJailFinesConfig()
    local row = MySQL.single.await('SELECT `value` FROM mdt_settings WHERE `key` = ?', { 'jail_fines' })
    if row and row.value then
        local ok, decoded = pcall(json.decode, row.value)
        if ok and type(decoded) == 'table' then
            local defaults = getDefaultJailFinesConfig()
            if not decoded.reductionOffers or type(decoded.reductionOffers) ~= 'table' or #decoded.reductionOffers == 0 then
                decoded.reductionOffers = defaults.reductionOffers
            end
            if not decoded.maxFineAmount or tonumber(decoded.maxFineAmount) == nil then
                decoded.maxFineAmount = defaults.maxFineAmount
            end
            jailFinesConfig = decoded
            return jailFinesConfig
        end
    end
    jailFinesConfig = getDefaultJailFinesConfig()
    return jailFinesConfig
end

function GetJailFinesConfig()
    if jailFinesConfig then return jailFinesConfig end
    return loadJailFinesConfig()
end

ps.registerCallback(resourceName .. ':server:getJailFinesConfig', function(source)
    local src = source
    if not CheckAuth(src) then return {} end
    return GetJailFinesConfig()
end)

ps.registerCallback(resourceName .. ':server:saveJailFinesConfig', function(source, payload)
    local src = source
    if not CheckAuth(src) then return { success = false, message = L('settings.unauthorized') } end
    if not CheckPermission(src, 'management_settings') then
        return { success = false, message = L('settings.no_settings_permission') }
    end

    if type(payload) ~= 'table' then
        return { success = false, message = L('settings.invalid_payload') }
    end

    -- Validate reductionOffers: must be array of numbers 1-100
    local offers = {}
    if type(payload.reductionOffers) == 'table' then
        for _, v in ipairs(payload.reductionOffers) do
            local num = tonumber(v)
            if num and num >= 1 and num <= 100 then
                offers[#offers + 1] = math.floor(num)
            end
        end
    end
    if #offers == 0 then
        offers = getDefaultJailFinesConfig().reductionOffers
    end

    local maxFine = tonumber(payload.maxFineAmount)
    if not maxFine or maxFine < 0 then
        maxFine = getDefaultJailFinesConfig().maxFineAmount
    end
    maxFine = math.floor(maxFine)

    local sanitized = {
        reductionOffers = offers,
        maxFineAmount = maxFine,
    }

    MySQL.update.await([[
        INSERT INTO mdt_settings (`key`, `value`)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE `value` = VALUES(`value`)
    ]], { 'jail_fines', json.encode(sanitized) })

    jailFinesConfig = sanitized

    if ps.auditLog then
        ps.auditLog(src, 'settings_updated', 'settings', 'jail_fines', sanitized)
    end

    return { success = true }
end)

-- Report Templates Configuration

local legacyReportTemplateTypes = {
    ['Relatório de incidente'] = 'Incident Report',
    ['Relatório de tráfego'] = 'Traffic Report',
    ['Relatório de Investigação'] = 'Investigation Report',
    ['Relatório de prisão'] = 'Arrest Report',
    ['Relatório de evidências'] = 'Evidence Report',
}

local reportTemplateTypesByJob = {
    leo = {
        ['Incident Report'] = true,
        ['Traffic Report'] = true,
        ['Investigation Report'] = true,
        ['Arrest Report'] = true,
        ['Evidence Report'] = true,
    },
    ems = {
        ['Medical Report'] = true,
        ['Trauma Report'] = true,
        ['Overdose Report'] = true,
        ['Psychiatric Report'] = true,
        ['Mass Casualty Report'] = true,
    },
    doj = {
        ['Court Filing'] = true,
        ['Legal Brief'] = true,
        ['Judicial Order'] = true,
        ['Plea Agreement'] = true,
        ['Sentencing Report'] = true,
    },
}

local defaultDomainReportTemplates = {
    { jobType = 'ems', type = 'Medical Report', name = 'Avaliação Médica Geral', content = [[<h2>Avaliação do paciente</h2><p><strong>Queixa principal:</strong> [QUEIXA]</p><p><strong>Sinais vitais:</strong> [SINAIS VITAIS]</p><h2>Tratamento e Destino</h2><p>[TRATAMENTO / TRANSPORTE]</p>]] },
    { jobType = 'ems', type = 'Trauma Report', name = 'Atendimento de Trauma', content = [[<h2>Avaliação do trauma</h2><p><strong>Mecanismo da lesão:</strong> [MECANISMO]</p><p><strong>Lesões:</strong> [LESÕES]</p><h2>Intervenções</h2><p>[INTERVENÇÕES / TRANSPORTE]</p>]] },
    { jobType = 'ems', type = 'Overdose Report', name = 'Atendimento de Overdose', content = [[<h2>Avaliação da overdose</h2><p><strong>Substância suspeita:</strong> [SUBSTÂNCIA]</p><p><strong>Condição inicial:</strong> [CONDIÇÃO]</p><h2>Tratamento e Resultado</h2><p>[TRATAMENTO / RESPOSTA / TRANSPORTE]</p>]] },
    { jobType = 'ems', type = 'Psychiatric Report', name = 'Avaliação Psiquiátrica', content = [[<h2>Avaliação de saúde mental</h2><p><strong>Apresentação:</strong> [APRESENTAÇÃO]</p><p><strong>Avaliação de risco:</strong> [RISCO]</p><h2>Intervenção e Destino</h2><p>[INTERVENÇÃO / DESTINO]</p>]] },
    { jobType = 'ems', type = 'Mass Casualty Report', name = 'Atendimento com Múltiplas Vítimas', content = [[<h2>Visão geral do incidente</h2><p><strong>Local:</strong> [LOCAL]</p><p><strong>Resumo da triagem:</strong> [QUANTIDADES POR TRIAGEM]</p><h2>Recursos e Transporte</h2><p>[RECURSOS / DESTINOS]</p>]] },
    { jobType = 'doj', type = 'Court Filing', name = 'Petição Judicial Padrão', content = [[<h2>Petição judicial</h2><p><strong>Processo:</strong> [PROCESSO Nº]</p><p>[DETALHES DA PETIÇÃO]</p>]] },
    { jobType = 'doj', type = 'Legal Brief', name = 'Memorial Jurídico Padrão', content = [[<h2>Memorial jurídico</h2><p><strong>Matéria:</strong> [MATÉRIA]</p><p>[ARGUMENTOS E FUNDAMENTOS]</p>]] },
    { jobType = 'doj', type = 'Judicial Order', name = 'Ordem Judicial Padrão', content = [[<h2>Ordem judicial</h2><p><strong>Processo:</strong> [PROCESSO Nº]</p><p>[ORDEM]</p>]] },
    { jobType = 'doj', type = 'Plea Agreement', name = 'Acordo Judicial Padrão', content = [[<h2>Acordo judicial</h2><p><strong>Réu:</strong> [NOME]</p><p>[TERMOS]</p>]] },
    { jobType = 'doj', type = 'Sentencing Report', name = 'Relatório de Sentença Padrão', content = [[<h2>Relatório de sentença</h2><p><strong>Réu:</strong> [NOME]</p><p>[FUNDAMENTAÇÃO E SENTENÇA]</p>]] },
}

local reportTemplateDomainsEnsured = false

local function normalizeReportTemplateJobType(jobType)
    if jobType == 'ems' or jobType == 'doj' then return jobType end
    return 'leo'
end

local function getReportTemplateJobType(src, requestedJobType)
    local jobName = ps.getJobName(src)
    if Config.DojJobs then
        for _, name in ipairs(Config.DojJobs) do
            if name == jobName then return 'doj' end
        end
    end

    local sourceJobType = ps.getJobType(src)
    if Config.DojJobType and sourceJobType == Config.DojJobType then return 'doj' end
    if sourceJobType == 'leo' or sourceJobType == 'ems' or sourceJobType == 'doj' then
        return sourceJobType
    end

    return normalizeReportTemplateJobType(requestedJobType)
end

local function ensureReportTemplateDomains()
    if reportTemplateDomainsEnsured then return end
    reportTemplateDomainsEnsured = true

    local migrationKey = 'report_template_domains_v1'
    if MySQL.scalar.await('SELECT 1 FROM mdt_settings WHERE `key` = ? LIMIT 1', { migrationKey }) then
        return
    end

    MySQL.update.await([[
        UPDATE mdt_report_templates
        SET `job_type` = 'leo'
        WHERE (`job_type` IS NULL OR `job_type` = 'all')
          AND `type` IN (
              'Incident Report', 'Traffic Report', 'Investigation Report', 'Arrest Report', 'Evidence Report',
              'Relatório de incidente', 'Relatório de tráfego', 'Relatório de Investigação', 'Relatório de prisão', 'Relatório de evidências'
          )
    ]])

    for _, template in ipairs(defaultDomainReportTemplates) do
        local exists = MySQL.scalar.await(
            'SELECT 1 FROM mdt_report_templates WHERE `job_type` = ? AND `type` = ? LIMIT 1',
            { template.jobType, template.type }
        )
        if not exists then
            MySQL.insert.await(
                'INSERT INTO mdt_report_templates (`name`, `type`, `content`, `job_type`) VALUES (?, ?, ?, ?)',
                { template.name, template.type, template.content, template.jobType }
            )
        end
    end

    MySQL.update.await([[
        INSERT INTO mdt_settings (`key`, `value`)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE `value` = VALUES(`value`)
    ]], { migrationKey, '1' })
end

ps.registerCallback(resourceName .. ':server:getReportTemplates', function(source, data)
    local src = source
    if not CheckAuth(src) then return {} end

    ensureReportTemplateDomains()

    local jobType = getReportTemplateJobType(src, type(data) == 'table' and data.jobType or nil)
    local allowedTypes = reportTemplateTypesByJob[jobType]
    -- Return templates matching the job type or 'all'
    local rows = MySQL.query.await(
        'SELECT `id`, `name`, `type`, `content`, `job_type` FROM mdt_report_templates WHERE `job_type` = ? OR `job_type` = ? ORDER BY `type`, `name`',
        { jobType, 'all' }
    )
    local filteredRows = {}
    for _, row in ipairs(rows or {}) do
        row.type = legacyReportTemplateTypes[row.type] or row.type
        if allowedTypes[row.type] then
            filteredRows[#filteredRows + 1] = row
        end
    end
    return filteredRows
end)

ps.registerCallback(resourceName .. ':server:saveReportTemplate', function(source, payload)
    local src = source
    if not CheckAuth(src) then return { success = false, message = L('settings.unauthorized') } end
    if not CheckPermission(src, 'management_settings') then
        return { success = false, message = L('settings.no_template_change_permission') }
    end

    if type(payload) ~= 'table' then
        return { success = false, message = L('settings.invalid_payload') }
    end

    local name = tostring(payload.name or ''):sub(1, 100)
    local tmplType = tostring(payload.type or ''):sub(1, 50)
    local content = tostring(payload.content or '')

    if name == '' or tmplType == '' or content == '' then
        return { success = false, message = L('settings.template_fields_required') }
    end

    local jobType = getReportTemplateJobType(src, tostring(payload.jobType or ''):sub(1, 10))
    if not reportTemplateTypesByJob[jobType][tmplType] then
        return { success = false, message = L('settings.invalid_payload') }
    end

    local templateId = payload.id and tonumber(payload.id) or nil

    if templateId then
        -- Update existing
        MySQL.update.await('UPDATE mdt_report_templates SET `name` = ?, `type` = ?, `content` = ?, `job_type` = ? WHERE `id` = ?', {
            name, tmplType, content, jobType, templateId
        })
    else
        -- Insert new
        templateId = MySQL.insert.await('INSERT INTO mdt_report_templates (`name`, `type`, `content`, `job_type`) VALUES (?, ?, ?, ?)', {
            name, tmplType, content, jobType
        })
    end

    if ps.auditLog then
        ps.auditLog(src, 'settings_updated', 'settings', 'report_template_' .. tostring(templateId), { name = name, type = tmplType, jobType = jobType })
    end

    return { success = true, template = { id = templateId, name = name, type = tmplType, content = content, job_type = jobType } }
end)

ps.registerCallback(resourceName .. ':server:deleteReportTemplate', function(source, payload)
    local src = source
    if not CheckAuth(src) then return { success = false, message = L('settings.unauthorized') } end
    if not CheckPermission(src, 'management_settings') then
        return { success = false, message = L('settings.no_template_delete_permission') }
    end

    if type(payload) ~= 'table' or not payload.id then
        return { success = false, message = L('settings.invalid_payload') }
    end

    local id = tonumber(payload.id)
    if not id then
        return { success = false, message = L('settings.invalid_template') }
    end

    MySQL.update.await('DELETE FROM mdt_report_templates WHERE `id` = ?', { id })

    if ps.auditLog then
        ps.auditLog(src, 'settings_updated', 'settings', 'report_template_' .. tostring(id), { action = 'deleted' })
    end

    return { success = true }
end)

-- ═══════════════════════════════════════════════════════════════
--  COLORS CONFIG
-- ═══════════════════════════════════════════════════════════════

local colorConfigCache = nil

local function getColorSettingsKey(src)
    local jobName = ps.getJobName and ps.getJobName(src) or 'police'
    return 'colors_' .. (jobName or 'police')
end

ps.registerCallback(resourceName .. ':server:getColorConfig', function(source)
    local src = source
    if not CheckAuth(src) then return nil end

    local settingsKey = getColorSettingsKey(src)

    if colorConfigCache and colorConfigCache._key == settingsKey then
        return colorConfigCache
    end

    local rows = MySQL.query.await('SELECT `value` FROM mdt_settings WHERE `key` = ?', { settingsKey })
    if rows and rows[1] and rows[1].value then
        local ok, parsed = pcall(json.decode, rows[1].value)
        if ok and parsed then
            parsed._key = settingsKey
            colorConfigCache = parsed
            return parsed
        end
    end

    return nil
end)

ps.registerCallback(resourceName .. ':server:saveColorConfig', function(source, payload)
    local src = source
    if not CheckAuth(src) then return { success = false, message = L('settings.unauthorized') } end
    if not CheckPermission(src, 'management_settings') then
        return { success = false, message = L('settings.no_color_permission') }
    end

    if type(payload) ~= 'table' then
        return { success = false, message = L('settings.invalid_payload') }
    end

    local config = {
        accent = type(payload.accent) == 'string' and payload.accent or nil,
        accentText = type(payload.accentText) == 'string' and payload.accentText or nil,
        background = type(payload.background) == 'string' and payload.background or nil,
        cardBackground = type(payload.cardBackground) == 'string' and payload.cardBackground or nil,
        buttonPrimary = type(payload.buttonPrimary) == 'string' and payload.buttonPrimary or nil,
    }

    if not config.accent then
        return { success = false, message = L('settings.accent_required') }
    end

    local settingsKey = getColorSettingsKey(src)
    local jsonValue = json.encode(config)

    MySQL.query.await([[
        INSERT INTO mdt_settings (`key`, `value`) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE `value` = VALUES(`value`)
    ]], { settingsKey, jsonValue })

    config._key = settingsKey
    colorConfigCache = config

    if ps.auditLog then
        ps.auditLog(src, 'settings_updated', 'settings', settingsKey, config)
    end

    return { success = true }
end)
