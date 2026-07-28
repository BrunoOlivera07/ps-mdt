local resourceName = tostring(GetCurrentResourceName())

-- Events
RegisterNUICallback('viewBodycam', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end

    ps.debug('viewBodycam', data)

    local bodycamId = data
    if type(data) == 'table' then
        bodycamId = data.id or data.bodycamId or data
    end

    if not bodycamId then
        cb({ success = false, message = L('client.invalid_bodycam') })
        return
    end

    local result = ps.callback(resourceName .. ':server:viewBodycam', bodycamId)

    if result and result.success then
        CloseMDT(true)
        cb({ success = true })
    else
        cb({ success = false, message = result and result.error or L('client.view_bodycam_failed') })
    end

end)

RegisterNUICallback('getBodycams', function(_, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open'), data = {} })
        return
    end

    local bodycams = ps.callback(resourceName .. ':server:getBodycams')

    if bodycams then
        cb({ success = true, data = bodycams })
    else
        cb({ success = false, message = L('client.fetch_bodycams_failed'), data = {} })
    end
end)
