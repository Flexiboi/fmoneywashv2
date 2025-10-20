local MoneyWashZones = {}
local IsInZone = false
local IsWashing = false
local DanceScene = nil
local InTimeOut, TimeOutTime = false, 0
local Dancers = {}
local Props = {}
local ParticleFX = {}

local function RequestAnim(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(0)
    end
end

local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

local function IsDancing(ped)
    local num = 3
    for i = 0, num-1 do
        if IsEntityPlayingAnim(ped, 'mini@strip_club@pole_dance@pole_dance' .. i, 'pd_dance_0' .. i, 3) then
            return true
        end
    end
    for k, v in ipairs(Config.AcceptedDances) do
        if IsEntityPlayingAnim(ped, v.dict, v.anim, 3) then
            return true
        end
    end
    return false
end

local function GetNearestPole()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    for k, v in ipairs(Config.Poles) do
        if #(pedCoords - v.Coords) <= Config.PoleDistance then
            return v.Coords
        end
    end
end

local function CreateDancer(coords, model)
    LoadModel(model)
	local ped = CreatePed(0, model, coords.x, coords.y, coords.z, false, false)
	Dancers[#Dancers + 1] = ped
    SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    FreezeEntityPosition(ped, true)
    local SceneId = math.random(1, 3)
    local AnimDic = 'mini@strip_club@pole_dance@pole_dance' .. SceneId
    RequestAnim(AnimDic)
    TaskPlayAnim(ped, AnimDic, 'pd_dance_0' .. SceneId, 1.0, -1.0, -1, 1, 1, true, true, true)
end

local function IsNpcPole()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    for k, v in ipairs(Config.Poles) do
        if #(pedCoords - v.Coords) <= Config.PoleDistance then
            return v.IsNpc
        end
    end
    return false
end

local function PoleInRange()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    for k, v in ipairs(Config.Poles) do
        if #(pedCoords - v.Coords) <= Config.PoleDistance then
            return true
        end
    end
    return false
end

local function IsNearPole()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    for k, v in ipairs(Config.Poles) do
        if #(pedCoords - v.Coords) <= Config.PoleDistance then
            local closestPed = lib.getClosestPed(v.Coords, 2.0)
            local closestPlayer = lib.getClosestPlayer(v.Coords, 2.0, false)
            local targetSrc = GetPlayerServerId(closestPlayer)
            if (not IsPedAPlayer(closestPed) and v.IsNpc and IsDancing(closestPed)) or 
            (closestPlayer and IsPedAPlayer(closestPed) and targetSrc ~= -1 and not v.IsNpc and 
            (IsDancing(closestPed) or IsDancing(closestPlayer))) then
                return true, v.Coords
            else
                return false, nil
            end
        end
    end
end

RegisterNetEvent("sublime_moneywash:Client:RollMoney", function()
    if lib.callback.await("sublime_moneywash:Server:HasGotBlackMoney", 10000) then
        if lib.progressBar({
            duration = 1000 * Config.RoleTime,
            label = Language.progress.roling,
            anim = {
                dict = 'anim@amb@business@weed@weed_inspecting_high_dry@',
                clip = 'weed_inspecting_high_base_inspector',
            },
            prop = {
                model = 'sf_prop_sf_cash_roll_01a',
                bone = 60309,
                pos = {
                    x = 0.05,
                    y = 0.0,
                    z = 0.05
                },
                rot = {
                    x = 0.0,
                    y = 180.0,
                    z = 0.0
                },
            }
        }) then
            TriggerServerEvent("sublime_moneywash:Server:Roll")
        end
    else
        Config.Notify.client(Language.info.noblackmoney:format(Config.RoleStockAmount), 'info', 5000)
    end
end)

RegisterNetEvent("sublime_moneywash:Client:ThrowMoney", function()
    if IsWashing then return end
    if InTimeOut then return Config.Notify.client(Language.info.intimeout:format(math.floor(TimeOutTime / 60 + 0.5)), 'info', 5000) end
    
    local State, PoleCoords = IsNearPole()
    if State then
        IsWashing = true
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local boneIndex = GetPedBoneIndex(ped, 18905)
        LoadModel('prop_anim_cash_pile_01')
        local cashpile = CreateObject(GetHashKey("prop_cash_pile_01"), 0, 0, 0, true, true, true)
        local NetId = NetworkGetNetworkIdFromEntity(cashpile)
        Props[#Props + 1] = cashpile
        AttachEntityToEntity(cashpile, ped, boneIndex, 0.12, 0.028, 0.001, 0.00, 85.0, 50.0, true, true, false, true, 1, true)
        TriggerServerEvent("sublime_moneywash:Server:SyncParticles", NetworkGetNetworkIdFromEntity(Props[#Props]), "start")
        
        RequestAnim('anim@mp_player_intupperraining_cash')
        TaskPlayAnim(ped, 'anim@mp_player_intupperraining_cash', 'idle_a', 2.0, 2.0, -1, 51, 0, false, false, false)
        
        Wait(1000)
        
        CreateThread(function()
            while IsWashing do
                DisableControlAction(0, 24, true) -- Attack
                DisableControlAction(0, 25, true) -- Aim
                DisableControlAction(0, 142, true) -- MeleeAttackAlternate
                DisableControlAction(0, 106, true) -- VehicleMouseControlOverride    
                
                if IsControlPressed(0, 322) or IsControlPressed(0, 177) or IsControlPressed(0, 73) then -- ESC or BACKSPACE or X to cancel
                    ClearPedTasks(ped)
                    
                    TriggerServerEvent("sublime_moneywash:Server:SyncParticles", NetworkGetNetworkIdFromEntity(Props[#Props]), "stop")
                    if DoesEntityExist(cashpile) then
                        DeleteEntity(cashpile)
                        Props[#Props] = nil
                    end

                    InTimeOut = true
                    TimeOutTime = 60 * Config.ThrowMoneyTimeout
                    
                    CreateThread(function()
                        while TimeOutTime > 0 and InTimeOut do
                            Wait(1000)
                            TimeOutTime = TimeOutTime - 1
                        end
                        InTimeOut = false
                    end)
                    
                    IsWashing = false
                end
                Wait(0)
            end
        end)
        
        CreateThread(function()
            while IsWashing do
                Wait(1000)
                local currentState, _ = IsNearPole()
                if not currentState then
                    ClearPedTasks(ped)

                    TriggerServerEvent("sublime_moneywash:Server:SyncParticles", NetworkGetNetworkIdFromEntity(Props[#Props]), "stop")
                    if DoesEntityExist(cashpile) then
                        DeleteEntity(cashpile)
                        Props[#Props] = nil
                    end
                    IsWashing = false
                    return
                end
            end
        end)
        
        while lib.callback.await("sublime_moneywash:Server:HasGotRolls", false) and IsWashing do
            Wait(1000 * Config.RemoveMoneyTimer)
            if not IsWashing then break end
            
            if math.random(0, 100) <= Config.MiniGameChance.Throw then
                local success = Config.Minigames.Washing()
                if not success then
                    ClearPedTasks(ped)

                    TriggerServerEvent("sublime_moneywash:Server:SyncParticles", NetworkGetNetworkIdFromEntity(Props[#Props]), "stop")
                    if DoesEntityExist(cashpile) then
                        DeleteEntity(cashpile)
                        Props[#Props] = nil
                    end
                    InTimeOut = true
                    TimeOutTime = 60 * Config.ThrowMoneyTimeout
                    
                    CreateThread(function()
                        while TimeOutTime > 0 do
                            Wait(1000)
                            TimeOutTime = TimeOutTime - 1
                        end
                        InTimeOut = false
                    end)
                    
                    IsWashing = false
                    return
                end
            end
            
            TriggerServerEvent('sublime_moneywash:Server:GiveCleanCash')
        end
        
        TriggerServerEvent("sublime_moneywash:Server:SyncParticles", NetworkGetNetworkIdFromEntity(Props[#Props]), "stop")
        if DoesEntityExist(cashpile) then
            DeleteEntity(cashpile)
            Props[#Props] = nil
        end
        
        IsWashing = false
    end
end)

RegisterNetEvent("sublime_moneywash:Client:SyncParticles", function(NetId, state)
    if not IsInZone then return end
    if not NetId or NetId == 0 then return end

    if not NetworkDoesEntityExistWithNetworkId(NetId) then
        print(("[Moneywash] NetId %s does not exist on this client (state: %s)"):format(NetId, state))
        return
    end

    local cashpile = NetworkGetEntityFromNetworkId(NetId)
    if not cashpile or cashpile == 0 or not DoesEntityExist(cashpile) then
        print(("[Moneywash] Failed to resolve NetId %s to entity (state: %s)"):format(NetId, state))
        return
    end
    
    if state == "start" then
        lib.requestNamedPtfxAsset('scr_xs_celebration')
        UseParticleFxAsset('scr_xs_celebration')

        local fx = StartParticleFxLoopedOnEntity(
            'scr_xs_money_rain',
            cashpile,
            0.1, 0.0, 0.05, -- offset slightly forward
            0.0, 0.0, 0.0,  -- rotation must be 0
            1.0,
            false, false, false
        )

        if not ParticleFX then ParticleFX = {} end
        ParticleFX[NetId] = { fx = fx }
        
    elseif state == "stop" then
        if ParticleFX and ParticleFX[NetId] then
            StopParticleFxLooped(ParticleFX[NetId].fx, false)
            ParticleFX[NetId] = nil
        end
    end
end)

RegisterNetEvent(Config.Events.load, function()
    for k, v in ipairs(Config.Zones) do
        MoneyWashZones[#MoneyWashZones + 1] = PolyZone:Create(v, { name = 'sublime_moneywash:zone:'..k, debugPoly = Config.Debug })
        MoneyWashZones[#MoneyWashZones]:onPlayerInOut(function(isPointInside)
            IsInZone = isPointInside
            if isPointInside then
                local ped = PlayerPedId()
                local pedCoords = GetEntityCoords(ped)
                local PlayerData = GetPlayerData()
                exports['crm-radialmenu']:crm_add(
                    {
                        crm_id = "crm-striclub",
                        crm_title = Language.radial.menutitle,
                        crm_icon = "car",
                        crm_items = {
                            {
                                crm_id = 'sublime_moneywash:Client:ThrowMoney',
                                crm_title = Language.radial.throwmoney,
                                crm_icon = "money-bill",
                                crm_close = true,
                                crm_action = {crm_type = "crm-client", crm_event = "sublime_moneywash:Client:ThrowMoney", crm_args = {}},
                            },
                        },
                    }
                )
                if lib.table.contains(Config.StripJobs, PlayerData.job.name) then
                    exports['crm-radialmenu']:crm_add(
                        {
                            crm_menu = "crm-striclub",
                            crm_items = {
                                {
                                    crm_id = 'sublime_moneywash:Client:Dance',
                                    crm_title = Language.radial.dance,
                                    crm_icon = "person-walking",
                                    crm_close = true,
                                    crm_action = {crm_type = "crm-client", crm_event = "sublime_moneywash:Client:Dance", crm_args = {}},
                                },
                            },
                        }
                    )
                end

                for k, v in ipairs(Config.Poles) do
                    if #(pedCoords - v.Coords) <= 100 then
                        if v.IsNpc then
                            CreateDancer(v.Coords, v.Npc)
                        end
                    end
                end
            else
                for k, v in ipairs(Dancers) do
                    if DoesEntityExist(v) then
                        DeleteEntity(v)
                    end
                end
                exports['crm-radialmenu']:crm_remove(
                    {crm_menu = "crm-striclub", crm_items = {"sublime_moneywash:Client:ThrowMoney", "sublime_moneywash:Client:Dance"}}
                )
                exports['crm-radialmenu']:crm_remove("crm-striclub")
            end
        end)
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
    if not IsInZone then return end
    if lib.table.contains(Config.StripJobs, jobInfo.name) then
        exports['qb-radialmenu']:AddOption({
            menu = 'sublime_moneywash:Client:ThrowMoney',
            id = 'sublime_moneywash:Client:Dance',
            title = Language.radial.dance,
            icon = "person-walking",
            type = "client",
            event = 'sublime_moneywash:Client:Dance',
            shouldClose = true
        }, 'sublime_moneywash:Client:Dance')
    end
end)

RegisterNetEvent("sublime_moneywash:Client:Dance", function()
    if IsNpcPole() then return end
    if not PoleInRange() then return end
    local menu = {}
    local num = 3
    for i = 0, num-1 do
        menu[#menu+1] = {
            title = Language.menu.danceid:format(i+1),
            icon = "music",
            description = "",
            event = "sublime_moneywash:Client:StartDance",
            args = { id = i, dance = false, pole_dance = true},
        }
    end
    for k, v in ipairs(Config.AcceptedDances) do
        menu[#menu+1] = {
            title = Language.menu.danceid:format(#menu),
            icon = "music",
            description = "",
            event = "sublime_moneywash:Client:StartDance",
            args = { id = nil, dance = true, pole_dance = false, dict = v.dict, anim = v.anim },
        }
    end
    menu[#menu+1] = {
        title = Language.menu.stopdance,
        icon = "fa-solid fa-xmark",
        description = "",
        event = "sublime_moneywash:Client:StartDance",
        args = { id = i, dance = false },
    }
    lib.registerContext({
        id = 'moneywashdancemenu',
        title = Language.menu.choosedance,
        options = menu,
    })
    lib.showContext('moneywashdancemenu')
end)

RegisterNetEvent("sublime_moneywash:Client:StartDance", function(args)
    local ped = PlayerPedId()
    if args.pole_dance then
        local coords = GetNearestPole()
        if DanceScene then
            NetworkStopSynchronisedScene(DanceScene)
            DanceScene = nil
        end
        DanceScene = NetworkCreateSynchronisedScene(coords.x + 0.07, coords.y + 0.3,
        coords.z + 1.15, 0.0, 0.0, 0.0, 2, false, true, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(ped, DanceScene, 'mini@strip_club@pole_dance@pole_dance' .. (args.id+1),
        'pd_dance_0' .. (args.id+1), 1.5, -4.0, 1, 1, 1148846080, 0)
        NetworkStartSynchronisedScene(DanceScene)
    elseif args.dance then
        RequestAnim(args.dict)
        TaskPlayAnim(ped, args.dict, args.anim, 1.0, -1.0, -1, 1, 1, true, true, true)
    else
        NetworkStopSynchronisedScene(DanceScene)
        ClearPedTasks(ped)
        DanceScene = nil
    end
end)

function UnloadEvent()
    for k, v in ipairs(Dancers) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    for k, v in ipairs(Props) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    
    -- Clean up synced particles
    if ParticleFX then
        for pedNetId, data in pairs(ParticleFX) do
            StopParticleFxLooped(data.fx, false)
            if DoesEntityExist(data.object) then
                DeleteEntity(data.object)
            end
        end
        ParticleFX = {}
    end
    
    exports['qb-radialmenu']:RemoveOption('sublime_moneywash:Client:ThrowMoney')
    exports['qb-radialmenu']:RemoveOption('sublime_moneywash:Client:Dance')
    for k, v in ipairs(MoneyWashZones) do
        v:destroy()
    end
end

RegisterNetEvent(Config.Events.unload, function()
    UnloadEvent()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    UnloadEvent()
end)