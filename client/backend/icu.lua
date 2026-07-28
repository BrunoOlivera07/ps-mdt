local resourceName = tostring(GetCurrentResourceName())

RegisterNUICallback('deleteICU', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end

    if type(data) ~= 'table' or not data.id then
        cb({ success = false, message = L('client.missing_icu') })
        return
    end

    local result = ps.callback(resourceName .. ':server:deleteICU', data)
    cb(result or { success = false, message = L('client.delete_icu_failed') })
end)
