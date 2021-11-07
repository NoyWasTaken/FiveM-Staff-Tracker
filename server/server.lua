local RESOURCE_ENABLED = "started"
local PERMISSION_PLAYER = "user"
local NO_STAFF_IDENTIFIER = "no_staff"

local core = nil
local usingEsx = false
local usingQbus = false
local staffData = {}
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

        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = core.GetPlayerFromId(xPlayers[i])
            if xPlayer.GetGroup() ~= PERMISSION_PLAYER then
                staffMemberConnect(xPlayer.source)
            end
        end
    elseif (GetResourceState(Config.QBUS_RESOURCE) == RESOURCE_ENABLED) then
        usingQbus = true
        print("QBus framework detected, using QBus.")

        TriggerEvent('QBCore:GetObject', function(obj) core = obj end)

        for k, v in pairs(core.Functions.GetPlayers()) do
            local Player = core.Functions.GetPlayer(v)
            if Player ~= nil then
                if Player.Functions.GetPermission() ~= PERMISSION_PLAYER then
                    staffMemberConnect(source)
                end
            end
        end
    else
        print("No supported framework detected.")
    end
    
    if staffCount == 0 then
        updateStaffCount(0)
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
                staffMemberConnect(source)
            end
        end
    end)

    AddEventHandler("playerDropped", function()
        local player = core.Functions.GetPlayer(source)
        if player ~= nil then
            if player.Functions.GetPermission() ~= PERMISSION_PLAYER then
                staffMemberDisconnect(source)
            end
        end
    end)
elseif usingEsx then
    AddEventHandler('es:playerLoaded', function()
        local player = core.GetPlayerFromId(source)
        if player ~= nil then
            if player.GetGroup() ~= PERMISSION_PLAYER then
                staffMemberConnect(source)
            end
        end
    end)

    AddEventHandler("playerDropped", function()
        local player = core.GetPlayerFromId(source)
        if player ~= nil then
            if player.GetGroup() ~= PERMISSION_PLAYER then
                staffMemberDisconnect(source)
            end
        end
    end)
end

function staffMemberConnect(src)
    staffData[src] = {}
    staffData[src]["connect"] = getTimestamp()
    updateStaffCount(staffCount + 1)
end

function staffMemberDisconnect(src)
    local timePassed = (getTimestamp() - staffData[src]["connect"]) / 60
    updateTime(getSteamId(src), getDateFormat(), timePassed)

    staffData[src] = nil
    updateStaffCount(staffCount - 1)
end

function updateStaffCount(count)
    if staffCount == 0 and count > 0 then
        local timePassed = (getTimestamp() - staffData[0]["connect"]) / 60
        updateTime(NO_STAFF_IDENTIFIER, getDateFormat(), timePassed)
    elseif staffCount > 0 and count == 0 then
        staffData[0] = {}
        staffData[0]["connect"] = getTimestamp()
    end

    staffCount = count
end

function updateTime(identifier, date, time)
    MySQL.Async.execute('INSERT INTO `staff_tracker` (`identifier`, `date`, `time`) VALUES (@identifier, @date, @timePassed) ON DUPLICATE KEY UPDATE `time` = `time` + @timePassed',
    {
        ['@identifier'] = identifier,
        ['@date'] = date,
        ['@timePassed'] = time
    },
    function()end)
end

function getDateFormat()
    return os.date("%d-%m-%Y", getTimestamp())
end

function getTimestamp()
    return os.time(os.date("!*t"))
end

function getSteamId(src)
    local steamID  = "no info"

	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			steamID = v
        end
	end

    return steamID
end