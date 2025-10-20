Config = {}
Config.Debug = false -- Enable Debugging

Config.Lang = 'nl' -- Language For the Script

Config.Events = {
    unload = 'QBCore:Client:OnPlayerUnload',
    load = 'QBCore:Client:OnPlayerLoaded',
}

Config.Notify = {
    client = function(msg, type, time)
        lib.notify({
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
    server = function(src, msg, type, time)
        lib.notify(src, {
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
}

Config.PoliceJobs = {
    'police',
    'bcso',
}

Config.PoliceAlert = function(coords, message) -- Police Alert Function
    exports.tk_dispatch:addCall({
        title = message,
        code = "40-25",
        priority = 'Priority 3',
        coords = coords,
        showLocation = true,
        showGender = false,
        playSound = true,
        blip = {
            color = 1,
            sprite = 51,
            scale = 0.8,
        },
        jobs = {'police'}
    })
end

Config.XPSystem = true -- Enable XP System
Config.MinXPNeeded = {
    CarWash = 1000, -- XP Needed To Start The Car Moneywash
}
Config.XPGain = {
    Strip = 1, -- XP Gained For The Strip Moneywash
    CarWash = 10, -- XP Gained For The Car Moneywash
}
Config.XPCheck = function(src, minxp)
    -- return exports.sublime_skills:GetPlayerXP(src, 'moneywash')
    return exports.sublime_skills:getSkillLevel(src, 'moneywash')
end
Config.XPAdd = function(src, amount)
    -- return exports.sublime_skills:IncreasePlayerXP(src, 'moneywash', amount)
    return exports.sublime_skills:addXp(src, 'moneywash', amount)
end

Config.StripJobs = {'police'} -- Jobs Counting As StripJobs
Config.AcceptedDances = { -- Accepted Dances For The Strip Moneywash
    [1] = {
        dict = 'mini@strip_club@private_dance@idle',
        anim = 'priv_dance_idle',
    },
    [2] = {
        dict = 'mini@strip_club@private_dance@part1',
        anim = 'priv_dance_p1',
    },
    [3] = {
        dict = 'mini@strip_club@private_dance@part2',
        anim = 'priv_dance_p2',
    },
    [4] = {
        dict = 'mini@strip_club@private_dance@part3',
        anim = 'priv_dance_p3',
    },
    [5] = {
        dict = 'oddjobs@assassinate@multi@yachttarget@lapdance',
        anim = 'yacht_ld_f',
    },
}

Config.Items = {
    Roles = 'rolls', -- Item Needed To Throw
    BlackMoney = 'blackmoney', -- Item Needed To Role A Stack Of Money To Throw
}

Config.Zones = {
    { -- Unicorn
        vec2(100.41, -1319.96),
        vec2(81.44, -1289.22),
        vec2(140.94, -1266.21),
        vec2(153.20, -1288.45)
    },
    { -- Malibu
        vec2(118.16, -582.06),
        vec2(297.19, -654.31),
        vec2(269.19, -745.42),
        vec2(77.33, -692.92)
    },
}

Config.PoleDistance = 5.0 -- Distancecheck To The Poles
Config.Poles = {
    -- [1] = { -- Unicorn
    --     IsNpc = true, -- True = Spawn The Npc, False = Player / Job Based
    --     Npc = 'u_m_y_pogo_01',
    --     Coords = vec3(112.58683013916,-1287.0506591797,27.593685150146),
    -- },
    [1] = { -- Malibu Right
        IsNpc = true, -- True = Spawn The Npc, False = Player / Job Based
        Npc = 'csb_stripper_01',
        Coords = vector3(126.7826, -652.5077, 28.0553),
    },
    [2] = { -- Malibu Left
        IsNpc = true, -- True = Spawn The Npc, False = Player / Job Based
        Npc = 'a_f_m_soucent_02',
        Coords = vector3(130.9143, -641.3276, 28.0346),
    },
}

Config.RoleStockAmount = 500 -- Amount Of BlackMoney You Need To Role 1 MoneyRole
Config.RoleTime = 2 -- Time In Seconds To Role The Money
Config.RemoveMoneyTimer = math.random(15, 20) -- Time In Seconds To Remove The Money After Throwing It
Config.ThrowMoneyTimeout = 1 -- Time In Minutes While In Timeout After Failing The Minigame
Config.RolesNeeded = 10 -- Amount of rolls to wash or 1 by default
Config.MoneyPerRole = math.random(400, 425) -- Amount Of Money You Get Per Role
Config.MiniGameChance = {
    Throw = 80, -- Chance Lower Before The Washing Minigame
}

Config.Minigames = {
    Washing = function() -- When Connecting The CardReader To The Phone
        local p = promise:new()
        local success = exports["sublime_minigamebridge"]:StartMinigame('aimlab', math.random(1,2))
        p:resolve(success)
        return Citizen.Await(p)
    end,
}