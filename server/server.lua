local RESOURCE_ENABLED = "started"
local PERMISSION_PLAYER = "user"

local core = nil
local usingEsx = false
local usingQbus = false
local staffCount = 0

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    print("Staff tracker has started.")
    print("Trying to detect ESX framework ...")

    if (GetResourceState(Config.ESX_RESOURCE) == RESOURCE_ENABLED) then
        usingEsx = true
        print("ESX framework detected, using ESX.")

        TriggerEvent('esx:getSharedObject', function(obj) core = obj end)
    elseif (GetResourceState(Config.QBUS_RESOURCE) == RESOURCE_ENABLED) then
        usingQbus = true
        print("QBus framework detected, using QBus.")

        TriggerEvent('QBCore:GetObject', function(obj) core = obj end)
    else
        print("No supported framework detected.")
    end
end)

-- Wait for framework detection in order to register correct events
Citizen.CreateThread(function()
    while core == nil do
        Citizen.Wait(0)
    end
end)

if usingQbus then
    AddEventHandler("QBCore:Server:OnPlayerLoaded", function()
        local player = core.Functions.GetPlayer(source)
        if player ~= nil then
            if player.Functions.GetPermission() ~= PERMISSION_PLAYER then
                updateStaffCount(staffCount + 1)
            end
        end
    end)

    AddEventHandler("playerDropped", function()
        local player = core.Functions.GetPlayer(source)
        if player ~= nil then
            if player.Functions.GetPermission() ~= PERMISSION_PLAYER then
                updateStaffCount(staffCount - 1)
            end
        end
    end)
elseif usingEsx then
    AddEventHandler('es:playerLoaded', function()
        local player = core.GetPlayerFromId(source)
        if player ~= nil then
            if player.GetGroup() ~= PERMISSION_PLAYER then
                updateStaffCount(staffCount + 1)
            end
        end
    end)

    AddEventHandler("playerDropped", function()
        local player = core.GetPlayerFromId(source)
        if player ~= nil then
            if player.GetGroup() ~= PERMISSION_PLAYER then
                updateStaffCount(staffCount - 1)
            end
        end
    end)
end

function updateStaffCount(count)
    staffCount = count
end