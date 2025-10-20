lib.callback.register("sublime_moneywash:Server:HasGotRolls", function(source)
    local src = source
    return HasInvGotItem(src, 'count', Config.Items.Roles, nil, 1)
end)

lib.callback.register("sublime_moneywash:Server:HasGotBlackMoney", function(source)
    local src = source
    return HasInvGotItem(src, 'count', Config.Items.BlackMoney, nil, Config.RoleStockAmount)
end)

RegisterServerEvent("sublime_moneywash:Server:Roll", function()
    local src = source
    if HasInvGotItem(src, 'count', Config.Items.BlackMoney, nil, Config.RoleStockAmount) then
        if RemoveItem(src, Config.Items.BlackMoney, Config.RoleStockAmount, nil) then
            AddItem(src, Config.Items.Roles, 1, nil)
        end
    end
end)

RegisterServerEvent("sublime_moneywash:Server:GiveCleanCash", function()
    local src = source
    local itemcount = GetItemCount(src, Config.Items.Roles, nil)
    if itemcount >= Config.RolesNeeded then
        if HasInvGotItem(src, 'count', Config.Items.Roles, nil, Config.RolesNeeded) then
            if RemoveItem(src, Config.Items.Roles, Config.RolesNeeded, nil) then
                AddMoney(src, 'cash', Config.MoneyPerRole*Config.RolesNeeded, Language.info.moneywashreason)
                if Config.XPSystem then
                    Config.XPAdd(src, Config.XPGain.Strip*Config.RolesNeeded)
                end
            end
        else
            if RemoveItem(src, Config.Items.Roles, 1, nil) then
                AddMoney(src, 'cash', Config.MoneyPerRole, Language.info.moneywashreason)
                if Config.XPSystem then
                    Config.XPAdd(src, Config.XPGain.Strip)
                end
            end
        end
    elseif HasInvGotItem(src, 'count', Config.Items.Roles, nil, 1) then
        if RemoveItem(src, Config.Items.Roles, 1, nil) then
            AddMoney(src, 'cash', Config.MoneyPerRole, Language.info.moneywashreason)
            if Config.XPSystem then
                Config.XPAdd(src, Config.XPGain.Strip)
            end
        end
    end
end)

RegisterNetEvent("sublime_moneywash:Server:SyncParticles", function(NetId, state)
    TriggerClientEvent("sublime_moneywash:Client:SyncParticles", -1, NetId, state)
end)

lib.callback.register("sublime_moneywash:Server:HasXP", function(source, amount)
    return Config.XPCheck(source, 'moneywash') >= amount
end)