local cachedPlayers = {}

local function getVehicleType(model)
    if IsThisModelABike(model) then
        return 'bike'
    elseif IsThisModelACar(model) then
        return 'car'
    elseif IsThisModelABoat(model) then
        return 'boat'
    elseif IsThisModelAPlane(model) then
        return 'plane'
    elseif IsThisModelAHeli(model) then
        return 'heli'
    end
end

lib.onCache('vehicle', function (newVeh, oldVeh)
    if not ESX.PlayerLoaded then return end
    local group = PlayerBlips.Groups[ESX.GetPlayerData().job.name]
    if not group then return end
    local sprite = newVeh and PlayerBlips.Sprite[getVehicleType(GetEntityModel(newVeh))] or PlayerBlips.Sprite['default']
    Wait(500)
    TriggerServerEvent('playerBlip:changeBlip', sprite)
end)

local function addBlip(entity, color, name, sprite)
    local blip = AddBlipForEntity(entity)
    SetBlipSprite(blip, sprite or 1)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, color)
    SetBlipShrink(blip, true)
    SetBlipDisplay(blip, 6)
    ShowHeadingIndicatorOnBlip(blip, true)
    SetBlipPriority(blip, 100)
    SetBlipCategory(blip, 7)
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString(name);
    EndTextCommandSetBlipName(blip);
    return blip
end

local function checkCached(source)
    if cachedPlayers[source] then
        local data = cachedPlayers[source]
        if data.blip and DoesBlipExist(data.blip) then
            RemoveBlip(data.blip)
            cachedPlayers[source] = nil
        end
    end
end

AddStateBagChangeHandler('changeBlip', nil, function (bag, key, value)
    if not value or not GetEntityFromStateBagName(bag) then return end
    if not PlayerBlips.Groups[ESX.GetPlayerData().job.name] then return end
    if value and value.job ~= ESX.GetPlayerData().job.name then return end
    if value.source == cache.serverId then return end
    local blipData = cachedPlayers[value.source]
    local blip = blipData.blip
    if DoesBlipExist(blip) then
        SetBlipSprite(blip, value.sprite)
        SetBlipColour(blip, blipData.color)
        SetBlipScale(blip, 0.6)
        SetBlipShrink(blip, true)
        SetBlipPriority(blip, 100)
        ShowHeadingIndicatorOnBlip(blip, value.sprite == 1 and true or false)
        SetBlipCategory(blip, 7)
        BeginTextCommandSetBlipName("STRING");
        AddTextComponentString(blipData.name);
        EndTextCommandSetBlipName(blip);
    end
end)

AddStateBagChangeHandler('joinBlip', nil, function (bag, key, value)
    print('Start Debugging joinBlip ----------------')
    if not value or not GetEntityFromStateBagName(bag) then return end
    print('Got Value', value)
    if not PlayerBlips.Groups[ESX.GetPlayerData().job.name] then return end
    print('Got Player Blips', PlayerBlips.Groups[ESX.GetPlayerData().job.name])
    if value and value.job ~= ESX.GetPlayerData().job.name then return end
    print('Got Job', value.job)
    if value.source == cache.serverId then return end
    print('Got Source', value.source)
    local entity = GetPlayerPed(GetPlayerFromServerId(value.source))
    print('Got Entity', entity)
    local cached = cachedPlayers[value.source]
    print('Got Cached', cached)
    if cached and DoesBlipExist(cached.blip) then
        RemoveBlip(cached.blip)
        cachedPlayers[value.source] = nil
        print('Removed Blip')
    end
    Wait(500) -- Mandatory Wait
    print('Waited 500')
    local blip = addBlip(entity, PlayerBlips.Groups[value.job], value.name)
    print('Added Blip', blip)
    cachedPlayers[value.source] = {
        blip = blip,
        entity = entity,
        name = value.name,
        color = PlayerBlips.Groups[value.job],
        job = value.job,
    }
end)

RegisterNetEvent('playerBlip:onJoin', function (job, data)
    if source == '' then return end
    if not data then return end
    for k, v in pairs(data) do
        if v.source ~= cache.serverId then
            local player = GetPlayerFromServerId(v.source)
            if player ~= -1 then
                local entity = GetPlayerPed(player)
                checkCached(v.source)
                local blip = addBlip(entity, PlayerBlips.Groups[job], v.name)
                cachedPlayers[v.source] = {
                    blip = blip,
                    entity = entity,
                    name = v.name,
                    color = PlayerBlips.Groups[job],
                    job = job,
                }
            end
        end
    end
end)

RegisterNetEvent('playerBlip:clear', function ()
    if source == '' then return end
    for k, v in pairs(cachedPlayers) do
        if v and DoesBlipExist(v.blip) then
            RemoveBlip(v.blip)
        end
        cachedPlayers[k] = nil
    end
end)

RegisterNetEvent('playerBlip:onLeave', function (playerId, job)
    if source == '' then return end
    if not cachedPlayers[playerId] then return end
    RemoveBlip(cachedPlayers[playerId].blip)
    cachedPlayers[playerId] = nil
end)