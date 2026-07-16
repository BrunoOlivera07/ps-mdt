local resourceName = tostring(GetCurrentResourceName())

RegisterNetEvent(resourceName .. ':client:sendToPPoliceJail', function(targetSource, sentence)
    targetSource = tonumber(targetSource)
    sentence = tonumber(sentence)
    if not targetSource or not sentence or sentence <= 0 then return end

    local sentencing = Config.Sentencing or {}
    local command = tostring(sentencing.pPoliceCommand or 'prender')
    local sentenceType = tostring(sentencing.pPoliceType or 'prisao')

    -- Execute as the officer so p_policejob can apply its normal job and
    -- permission checks before creating the prison sentence.
    ExecuteCommand(('%s %d %s %d MDT'):format(
        command,
        targetSource,
        sentenceType,
        math.floor(sentence)
    ))
end)

-- Send to Jail
RegisterNUICallback('sendToJail', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = 'MDT is not open' })
        return
    end

    if type(data) ~= 'table' or not data.citizenId or not data.sentence then
        cb({ success = false, message = 'Missing citizen ID or sentence' })
        return
    end

    local result = ps.callback(resourceName .. ':server:sendToJail', data)
    cb(result or { success = false, message = 'Failed to send to jail' })
end)

-- Give Citation
RegisterNUICallback('giveCitation', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = 'MDT is not open' })
        return
    end

    if type(data) ~= 'table' or not data.citizenId then
        cb({ success = false, message = 'Missing citizen ID' })
        return
    end

    local result = ps.callback(resourceName .. ':server:giveCitation', data)
    cb(result or { success = false, message = 'Failed to give citation' })
end)
