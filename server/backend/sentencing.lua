local resourceName = tostring(GetCurrentResourceName())
local ok, QBCore = pcall(function() return exports['qb-core']:GetCoreObject() end)
if not ok then QBCore = nil end

-- Send to Jail
ps.registerCallback(resourceName .. ':server:sendToJail', function(source, payload)
    local src = source
    if not CheckAuth(src) then return { success = false, message = L('sentencing.unauthorized') } end
    if not CheckPermission(src, 'charges_edit') then
        return { success = false, message = L('sentencing.insufficient_permissions') }
    end

    payload = payload or {}
    local citizenId = payload.citizenId
    local sentence = tonumber(payload.sentence)

    if not citizenId or not sentence or sentence <= 0 then
        return { success = false, message = L('sentencing.invalid_sentence') }
    end

    local maxSentence = (Config and Config.Fines and Config.Fines.MaxSentence) or 999
    if sentence > maxSentence then
        return { success = false, message = L('sentencing.above_maximum', { months = maxSentence }) }
    end

    local targetPlayer = ps.getPlayerByIdentifier(citizenId)
    if not targetPlayer then
        return { success = false, message = L('sentencing.player_must_be_online') }
    end

    local targetSource = targetPlayer.source or (targetPlayer.PlayerData and targetPlayer.PlayerData.source)
    if not targetSource then
        return { success = false, message = L('sentencing.source_unavailable') }
    end

    local sentencing = (Config and Config.Sentencing) or {}
    local jailSystem = tostring(sentencing.system or 'auto')
    local pPoliceResource = tostring(sentencing.pPoliceResource or 'p_policejob')
    local pickleResource = tostring(sentencing.pickleResource or 'pickle_prisons')
    local usePickle = jailSystem == 'pickle_prisons'
        or (jailSystem == 'auto'
            and GetResourceState(pPoliceResource) ~= 'started'
            and GetResourceState(pickleResource) == 'started')

    if usePickle then
        if GetResourceState(pickleResource) ~= 'started' then
            return { success = false, message = L('sentencing.pickle_not_running') }
        end

        local prisonIndex = tostring(sentencing.picklePrison or 'default')
        local exportOk, exportErr = pcall(function()
            exports[pickleResource]:JailPlayer(targetSource, math.floor(sentence), prisonIndex)
        end)
        if not exportOk then
            ps.warn(('[Sentencing] pickle_prisons JailPlayer failed: %s'):format(tostring(exportErr)))
            return { success = false, message = L('sentencing.pickle_failed') }
        end

        if ps.auditLog then
            ps.auditLog(src, 'sent_to_jail', 'citizen', citizenId, {
                sentence = sentence,
                system = 'pickle_prisons',
                prison = prisonIndex,
            })
        end

        return { success = true, message = L('sentencing.sent_minutes', { minutes = sentence }) }
    end

    local usePPolice = jailSystem == 'p_policejob'
        or (jailSystem == 'auto' and GetResourceState(pPoliceResource) == 'started')

    if usePPolice then
        if GetResourceState(pPoliceResource) ~= 'started' then
            return { success = false, message = L('sentencing.policejob_not_running') }
        end

        local exportOk, exportResult = pcall(function()
            return exports[pPoliceResource]:JailPlayer(src, {
                player = targetSource,
                jail = math.floor(sentence),
                fine = 0,
                reason = 'MDT',
            })
        end)

        -- Older p_policejob builds may not expose JailPlayer. Their documented
        -- jail command remains a compatible fallback and runs as the officer.
        if not exportOk or exportResult == false then
            TriggerClientEvent(resourceName .. ':client:sendToPPoliceJail', src, targetSource, sentence)
        end

        if ps.auditLog then
            ps.auditLog(src, 'sent_to_jail', 'citizen', citizenId, {
                sentence = sentence,
                system = 'p_policejob',
                method = exportOk and exportResult ~= false and 'export' or 'command',
            })
        end

        return { success = true, message = L('sentencing.request_sent', { minutes = sentence }) }
    end

    local OtherPlayer = QBCore and QBCore.Functions.GetPlayer(targetSource)
    if not OtherPlayer then
        return { success = false, message = L('sentencing.target_not_found') }
    end

    local currentDate = os.date('*t')
    if currentDate.day == 31 then
        currentDate.day = 30
    end

    OtherPlayer.Functions.SetMetaData('injail', sentence)
    OtherPlayer.Functions.SetMetaData('criminalrecord', {
        ['hasRecord'] = true,
        ['date'] = currentDate
    })
    TriggerClientEvent('police:client:SendToJail', targetSource, sentence)
    ps.notify(src, L('sentencing.sent_months', { months = sentence }), 'success')

    if ps.auditLog then
        ps.auditLog(src, 'sent_to_jail', 'citizen', citizenId, {
            sentence = sentence,
        })
    end

    return { success = true, message = L('sentencing.sent_months', { months = sentence }) }
end)

ps.registerCallback(resourceName .. ':server:giveCitation', function(source, payload)
    local src = source
    if not CheckAuth(src) then return { success = false, message = L('sentencing.unauthorized') } end
    if not CheckPermission(src, 'charges_edit') then
        return { success = false, message = L('sentencing.insufficient_permissions') }
    end

    payload = payload or {}
    local citizenId = payload.citizenId
    local fine = tonumber(payload.fine)
    local reportId = payload.reportId

    if not citizenId then
        return { success = false, message = L('sentencing.missing_citizen') }
    end
    if not fine or fine ~= fine or fine <= 0 then
        return { success = false, message = L('sentencing.invalid_fine') }
    end
    fine = math.floor(fine)

    local Player = ps.getPlayerByIdentifier(citizenId)
    if not Player then
        return { success = false, message = L('sentencing.online_for_fine') }
    end

    local playerSrc = Player.source or (Player.PlayerData and Player.PlayerData.source)
    if not playerSrc then
        return { success = false, message = L('sentencing.source_unavailable') }
    end

    local removed = ps.removeMoney(playerSrc, 'bank', fine, 'mdt-fine')
    if not removed then
        return { success = false, message = L('sentencing.fine_deduction_failed') }
    end

    ps.notify(playerSrc, L('sentencing.fine_deducted', { amount = fine }), 'error')
    ps.notify(src, L('sentencing.fine_issued_success', { amount = fine }), 'success')

    if ps.auditLog then
        local officerName = ps.getPlayerName(src) or L('sentencing.unknown_officer')
        ps.auditLog(src, 'fine_issued', 'citizen', citizenId, {
            fine = fine,
            reportId = reportId,
            officerName = officerName,
        })
    end

    return { success = true, message = L('sentencing.fine_issued', { amount = fine }) }
end)
