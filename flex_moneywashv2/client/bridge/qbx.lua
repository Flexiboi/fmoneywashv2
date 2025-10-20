if GetResourceState('qbx_core') ~= 'started' then return end

function GetPlayerData()
    return exports.qbx_core:GetPlayerData()
end

function IsPlayerDeath(serverId)
    return exports.wasabi_ambulance:isPlayerDead(serverId)
end