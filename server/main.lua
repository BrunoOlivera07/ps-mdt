-- Server main entry point (intentionally minimal - logic lives in server/backend/*.lua)

local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("mdttablet", function(source, item)
    TriggerClientEvent('ps-mdt:client:open', source)
end)
