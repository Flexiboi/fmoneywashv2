if GetResourceState('qbx_core') ~= 'started' then return end

function RemoveItem(src, item, amount, info)
    return exports.ox_inventory:RemoveItem(src, item, amount, info)
end

function AddItem(src, item, amount, info)
    return exports.ox_inventory:AddItem(src, item, amount, info)
end

function HasInvGotItem(inv, search, item, metadata, amount)
    if type(amount) == "boolean" then return end
    if exports.ox_inventory:Search(inv, search, item) >= amount then
        return true
    else
        return false
    end
end

function GetItemCount(inv, item, metadata)
    return exports.ox_inventory:Search(inv, 'count', item, metadata) or 0
end

function GetInvItems(inv)
    return exports.ox_inventory:GetInventoryItems(inv)
end

function AddMoney(src, AddType, amount, reason)
    return exports.qbx_core:AddMoney(src, AddType, amount, reason or '')
end

function RegisterStash(id, slots, maxWeight)
    exports.ox_inventory:RegisterStash(id, id, slots, maxWeight)
end

function ClearStash(id)
    exports.ox_inventory:ClearInventory(id, 'false')
end