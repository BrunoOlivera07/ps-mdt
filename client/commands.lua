-- Command to open MDT
if not Config.Commands.Open.enabled then
    ps.debug('MDT Open Command is disabled in config, skipping command registration.')
else
    RegisterCommand(Config.Commands.Open.command, function()
        CreateThread(function()
            local authResult = CheckAuth()
            local isCivilian = type(authResult) == 'table' and authResult.isCivilian
            
            if isCivilian then
                return
            end
            OpenMDT()
        end)
    end, false)

    -- Add chat suggestion
    TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.Open.command, 'Open the MDT')

    ps.debug('MDT Open Command Enabled: ' .. Config.Commands.Open.command)
end

RegisterCommand('rcivil', function()
    CreateThread(function()
        local authResult = CheckAuth()
        local isCivilian = type(authResult) == 'table' and authResult.isCivilian
        
        if isCivilian then
            OpenMDT()
        else
            ps.notify("Comando apenas para civis. Use o tablet ou /rcivil.", "error")
        end
    end)
end, false)
TriggerEvent('chat:addSuggestion', '/rcivil', 'Abrir o Registro Civil')
