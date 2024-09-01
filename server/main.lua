local cachedPlayers = {}

for k, v in pairs(PlayerBlips.Groups) do
    if not cachedPlayers[k] then
        cachedPlayers[k] = {}
    end
end

RegisterNetEvent('playerBlip:changeBlip', function (sprite)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not PlayerBlips.Groups[xPlayer.job.name] then return end
    if not cachedPlayers[xPlayer.job.name][src] then return end
    Player(src --[[@as string]]).state:set('changeBlip', {source = src, sprite = sprite, job = xPlayer.job.name, name = xPlayer.getName()}, true)    
end)

AddEventHandler('esx:playerLoaded', function (playerId, xPlayer, isNew)
    if isNew then return end
    if not PlayerBlips.Groups[xPlayer.job.name] then return end
    if not cachedPlayers[xPlayer.job.name][playerId] then
        cachedPlayers[xPlayer.job.name][playerId] = {
            source = playerId,
            name = xPlayer.getName(),
        }
    end
    SetPlayerCullingRadius(playerId, 15000.0)
    Wait(500)
    Player(playerId).state:set('joinBlip', {name = xPlayer.getName(), job = xPlayer.job.name, source = playerId}, true)
    Wait(500)
    TriggerLatentClientEvent('playerBlip:onJoin', playerId, 0, xPlayer.job.name, cachedPlayers[xPlayer.job.name])
end)

AddEventHandler('esx:playerLogout', function (playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    if not PlayerBlips.Groups[xPlayer.job.name] then return end
    if not cachedPlayers[xPlayer.job.name][playerId] then return end
    cachedPlayers[xPlayer.job.name][playerId] = nil
    TriggerClientEvent('playerBlip:onLeave', -1, playerId, xPlayer.job.name)
end)

AddEventHandler('esx:playerDropped', function (playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    if not PlayerBlips.Groups[xPlayer.job.name] then return end
    if not cachedPlayers[xPlayer.job.name][playerId] then return end
    cachedPlayers[xPlayer.job.name][playerId] = nil
    TriggerClientEvent('playerBlip:onLeave', -1, playerId, xPlayer.job.name)
end)

AddEventHandler('esx:setJob', function (playerId, job, lastjob)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    if job.name == lastjob.name then
        local newCache = cachedPlayers[job.name]
        if newCache then
            SetPlayerCullingRadius(playerId, 15000.0)
            if not cachedPlayers[job.name][playerId] then
                cachedPlayers[job.name][playerId] = {}
            end
            cachedPlayers[job.name][playerId] = {
                source = playerId,
                name = xPlayer.getName(),
            }
            Wait(500)
            Player(playerId).state:set('joinBlip', {name = xPlayer.getName(), job = job.name, source = playerId}, true)
            TriggerLatentClientEvent('playerBlip:onJoin', playerId, 0, job.name, cachedPlayers[job.name])
        end
        return
    end
    if job.name ~= lastjob.name  then
        local cachedJob = cachedPlayers[lastjob.name]
        if cachedJob then
            if cachedPlayers[lastjob.name][playerId] then
                cachedPlayers[lastjob.name][playerId] = nil
                TriggerClientEvent('playerBlip:clear', playerId)
                TriggerClientEvent('playerBlip:onLeave', -1, playerId, lastjob.name)
                Player(playerId).state:set('joinBlip', nil, true)
            end            
        end
        Wait(500)
        local newCache = cachedPlayers[job.name]
        if newCache then
            SetPlayerCullingRadius(playerId, 15000.0)
            if not cachedPlayers[job.name][playerId] then
                cachedPlayers[job.name][playerId] = {}
            end
            cachedPlayers[job.name][playerId] = {
                source = playerId,
                name = xPlayer.getName(),
            }
            Wait(500)
            Player(playerId).state:set('joinBlip', {name = xPlayer.getName(), job = job.name, source = playerId}, true)
            TriggerLatentClientEvent('playerBlip:onJoin', playerId, 0, job.name, cachedPlayers[job.name])
        end
    end
end)
