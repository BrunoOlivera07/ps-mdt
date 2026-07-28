local resourceName = tostring(GetCurrentResourceName())

RegisterNUICallback('getCharges', function(data, cb)
    if not MDTOpen then cb({}) return end
    local callbacks = ps.callback('ps-mdt:getChargeList', false)
    cb(callbacks)
end)

RegisterNUICallback('processFine', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end

    if type(data) ~= 'table' or not data.citizenid or not data.fine then
        cb({ success = false, message = L('client.missing_citizen_fine') })
        return
    end

    local result = ps.callback(resourceName .. ':server:processFine', data)
    cb(result or { success = false, message = L('client.process_fine_failed') })
end)

RegisterNUICallback('updateCharge', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end

    if type(data) ~= 'table' or not data.code then
        cb({ success = false, message = L('client.missing_charge_code') })
        return
    end

    local result = ps.callback(resourceName .. ':server:updateCharge', data)
    cb(result or { success = false, message = L('client.update_charge_failed') })
end)

-- Phase 3: charge CRUD bridges (create / delete / category list)
RegisterNUICallback('addCharge', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end
    local result = ps.callback(resourceName .. ':server:createCharge', data)
    cb(result or { success = false, message = L('client.create_charge_failed') })
end)

RegisterNUICallback('deleteCharge', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end
    if type(data) ~= 'table' or not data.code then
        cb({ success = false, message = L('client.missing_charge_code') })
        return
    end
    local result = ps.callback(resourceName .. ':server:deleteCharge', data)
    cb(result or { success = false, message = L('client.delete_charge_failed') })
end)

RegisterNUICallback('getChargeCategories', function(data, cb)
    if not MDTOpen then cb({}) return end
    local result = ps.callback(resourceName .. ':server:getChargeCategories', false)
    cb(result or {})
end)
