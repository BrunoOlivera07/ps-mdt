local resourceName = tostring(GetCurrentResourceName())

RegisterNUICallback('getAuditLogs', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end

    local result = ps.callback(resourceName .. ':server:getAuditLogs', data)
    cb(result or {})
end)

RegisterNUICallback('getAuditLogsByCase', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end

    local result = ps.callback(
        resourceName .. ':server:getAuditLogsByCase',
        data.caseId,
        data.page,
        data.limit
    )
    cb(result or {})
end)
