local resourceName = tostring(GetCurrentResourceName())

-- Set Callsign
RegisterNUICallback('setCallsign', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end
    if type(data) ~= 'table' or (not data.cid and not data.citizenid) or (not data.newcallsign and not data.callsign) then
        cb({ success = false, message = L('client.missing_citizen_callsign') })
        return
    end
    local result = ps.callback(resourceName .. ':server:setCallsign', {
        citizenid = data.cid or data.citizenid,
        callsign = data.newcallsign or data.callsign,
    })
    cb(result or { success = false, message = L('client.set_callsign_failed') })
end)

RegisterNUICallback('getCallsign', function(data, cb)
    if not MDTOpen then cb({ callsign = '' }) return end
    local result = ps.callback(resourceName .. ':server:getCallsign', {
        citizenid = data.citizenid,
    })
    cb(result or { callsign = '' })
end)

-- Set Radio Frequency
RegisterNUICallback('setRadio', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end

    if type(data) ~= 'table' or (not data.cid and not data.citizenid) or (not data.newradio and not data.radio) then
        cb({ success = false, message = L('client.missing_citizen_radio') })
        return
    end

    local result = ps.callback(resourceName .. ':server:setRadio', {
        citizenid = data.cid or data.citizenid,
        radio = data.newradio or data.radio,
    })
    cb(result or { success = false, message = L('client.set_radio_failed') })
end)

-- Radio set event from server
RegisterNetEvent(resourceName .. ':client:setRadio', function(radio)
    if type(tonumber(radio)) == 'number' then
        local success = pcall(function()
            exports['pma-voice']:setVoiceProperty('radioEnabled', true)
            exports['pma-voice']:setRadioChannel(tonumber(radio))
        end)
        if success then
            ps.notify(L('client.radio_set', { frequency = radio }), 'success')
        else
            ps.notify(L('client.pma_voice_unavailable'), 'error')
        end
    else
        ps.notify(L('client.invalid_radio'), 'error')
    end
end)

-- Set Waypoint to Unit (GPS to another officer)
RegisterNUICallback('setWaypointU', function(data, cb)
    if not MDTOpen then cb('ok') return end
    local coords = ps.callback(resourceName .. ':server:getUnitLocation', data.cid)
    if coords then
        SetNewWaypoint(coords.x, coords.y)
        ps.notify(L('client.gps_officer'), 'success')
    else
        ps.notify(L('client.officer_offline'), 'error')
    end
    cb('ok')
end)

-- House Waypoint (Set GPS to property)
RegisterNUICallback('SetHouseLocation', function(data, cb)
    if not MDTOpen then cb('ok') return end
    if data.coord and data.coord[1] then
        local coords = {}
        for word in data.coord[1]:gmatch('[^,%s]+') do
            coords[#coords + 1] = tonumber(word)
        end
        if coords[1] and coords[2] then
            SetNewWaypoint(coords[1], coords[2])
            ps.notify(L('client.gps_property'), 'success')
        end
    elseif data.x and data.y then
        SetNewWaypoint(data.x, data.y)
        ps.notify(L('client.gps_property'), 'success')
    end
    cb('ok')
end)
