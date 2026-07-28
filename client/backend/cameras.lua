local resourceName = tostring(GetCurrentResourceName())

-- Events
RegisterNUICallback('viewCamera', function(data, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open') })
        return
    end

    ps.debug('viewCamera', data)

    local cameraId = data
    if type(data) == 'table' then
        cameraId = data.id or data.cameraId or data
    end

    if not cameraId then
        cb({ success = false, message = L('client.invalid_camera') })
        return
    end

    local result = ps.callback(resourceName .. ':server:viewCamera', cameraId)

    if result and result.success then
        CloseMDT(true)
        cb({ success = true })
    else
        cb({ success = false, message = result and result.error or L('client.view_camera_failed') })
    end

end)

RegisterNUICallback('getCameras', function(_, cb)
    if not MDTOpen then
        cb({ success = false, message = L('client.mdt_not_open'), data = {} })
        return
    end

    local cameras = ps.callback(resourceName .. ':server:getCameras')

    if cameras then
        cb({ success = true, data = cameras })
    else
        cb({ success = false, message = L('client.fetch_cameras_failed'), data = {} })
    end
end)
