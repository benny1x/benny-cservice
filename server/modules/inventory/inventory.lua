BennyCserviceInventory = BennyCserviceInventory or {}

local m_inventory_order = {
    'ox_inventory',
    'qb-inventory',
    'ps-inventory',
    'qs-inventory',
    'codem-inventory',
    'lj-inventory',
    'core_inventory',
    'origen_inventory',
}

function BennyCserviceInventory.GetProvider()
    if Config.m_inventory and Config.m_inventory ~= 'auto' then
        return Config.m_inventory
    end

    for m_index = 1, #m_inventory_order do
        local m_resource = m_inventory_order[m_index]

        if GetResourceState(m_resource) == 'started' then
            return m_resource
        end
    end

    return 'framework'
end

function BennyCserviceInventory.GetAllItems(m_source)
    local m_provider = BennyCserviceInventory.GetProvider()

    if m_provider == 'ox_inventory' then
        local m_items = exports.ox_inventory:GetInventoryItems(m_source) or {}
        local m_list = {}

        for _, m_item in pairs(m_items) do
            if m_item and m_item.name and (m_item.count or 0) > 0 then
                m_list[#m_list + 1] = {
                    m_name = m_item.name,
                    m_count = m_item.count,
                    m_metadata = m_item.metadata,
                    m_slot = m_item.slot,
                }
            end
        end

        return m_list
    end

    if m_provider == 'qb-inventory' then
        local m_player = BennyCserviceFramework.GetPlayer(m_source)

        if not m_player or not m_player.PlayerData or not m_player.PlayerData.items then
            return {}
        end

        local m_list = {}

        for _, m_item in pairs(m_player.PlayerData.items) do
            if m_item and m_item.name and (m_item.amount or 0) > 0 then
                m_list[#m_list + 1] = {
                    m_name = m_item.name,
                    m_count = m_item.amount,
                    m_metadata = m_item.info,
                    m_slot = m_item.slot,
                }
            end
        end

        return m_list
    end

    if m_provider == 'qs-inventory' then
        local m_ok, m_items = pcall(function()
            return exports['qs-inventory']:GetInventory(m_source)
        end)

        if not m_ok or type(m_items) ~= 'table' then
            return {}
        end

        local m_list = {}

        for _, m_item in pairs(m_items) do
            if m_item and m_item.name and (m_item.amount or m_item.count or 0) > 0 then
                m_list[#m_list + 1] = {
                    m_name = m_item.name,
                    m_count = m_item.amount or m_item.count,
                    m_metadata = m_item.info or m_item.metadata,
                    m_slot = m_item.slot,
                }
            end
        end

        return m_list
    end

    local m_player = BennyCserviceFramework.GetPlayer(m_source)

    if not m_player then
        return {}
    end

    if BennyCserviceFramework.Type == 'esx' then
        local m_inventory = m_player.getInventory and m_player.getInventory() or m_player.inventory or {}
        local m_list = {}

        for _, m_item in pairs(m_inventory) do
            if m_item and m_item.name and (m_item.count or 0) > 0 then
                m_list[#m_list + 1] = {
                    m_name = m_item.name,
                    m_count = m_item.count,
                    m_metadata = nil,
                    m_slot = nil,
                }
            end
        end

        return m_list
    end

    if m_player.PlayerData and m_player.PlayerData.items then
        local m_list = {}

        for _, m_item in pairs(m_player.PlayerData.items) do
            if m_item and m_item.name and (m_item.amount or 0) > 0 then
                m_list[#m_list + 1] = {
                    m_name = m_item.name,
                    m_count = m_item.amount,
                    m_metadata = m_item.info,
                    m_slot = m_item.slot,
                }
            end
        end

        return m_list
    end

    return {}
end

function BennyCserviceInventory.ClearAllItems(m_source)
    local m_provider = BennyCserviceInventory.GetProvider()
    local m_items = BennyCserviceInventory.GetAllItems(m_source)

    if m_provider == 'ox_inventory' then
        for _, m_item in ipairs(m_items) do
            exports.ox_inventory:RemoveItem(m_source, m_item.m_name, m_item.m_count, m_item.m_metadata, m_item.m_slot)
        end

        return true
    end

    if m_provider == 'qb-inventory' then
        for _, m_item in ipairs(m_items) do
            pcall(function()
                exports['qb-inventory']:RemoveItem(m_source, m_item.m_name, m_item.m_count, m_item.m_slot, 'benny-cservice')
            end)
        end

        return true
    end

    if m_provider == 'qs-inventory' then
        for _, m_item in ipairs(m_items) do
            pcall(function()
                exports['qs-inventory']:RemoveItem(m_source, m_item.m_name, m_item.m_count)
            end)
        end

        return true
    end

    local m_player = BennyCserviceFramework.GetPlayer(m_source)

    if not m_player then
        return false
    end

    if BennyCserviceFramework.Type == 'esx' then
        for _, m_item in ipairs(m_items) do
            m_player.removeInventoryItem(m_item.m_name, m_item.m_count)
        end

        return true
    end

    if m_player.Functions and m_player.Functions.RemoveItem then
        for _, m_item in ipairs(m_items) do
            m_player.Functions.RemoveItem(m_item.m_name, m_item.m_count, m_item.m_slot)
        end

        return true
    end

    return false
end

function BennyCserviceInventory.RestoreItems(m_source, m_items)
    if type(m_items) ~= 'table' or #m_items == 0 then
        return false
    end

    local m_provider = BennyCserviceInventory.GetProvider()

    if m_provider == 'ox_inventory' then
        for _, m_item in ipairs(m_items) do
            exports.ox_inventory:AddItem(m_source, m_item.m_name, m_item.m_count, m_item.m_metadata)
        end

        return true
    end

    if m_provider == 'qb-inventory' then
        for _, m_item in ipairs(m_items) do
            pcall(function()
                exports['qb-inventory']:AddItem(m_source, m_item.m_name, m_item.m_count, false, m_item.m_metadata, 'benny-cservice')
            end)
        end

        return true
    end

    if m_provider == 'qs-inventory' then
        for _, m_item in ipairs(m_items) do
            pcall(function()
                exports['qs-inventory']:AddItem(m_source, m_item.m_name, m_item.m_count, false, m_item.m_metadata)
            end)
        end

        return true
    end

    local m_player = BennyCserviceFramework.GetPlayer(m_source)

    if not m_player then
        return false
    end

    if BennyCserviceFramework.Type == 'esx' then
        for _, m_item in ipairs(m_items) do
            m_player.addInventoryItem(m_item.m_name, m_item.m_count)
        end

        return true
    end

    if m_player.Functions and m_player.Functions.AddItem then
        for _, m_item in ipairs(m_items) do
            m_player.Functions.AddItem(m_item.m_name, m_item.m_count, false, m_item.m_metadata)
        end

        return true
    end

    return false
end

function BennyCserviceInventory.HandleConfiscation(m_source)
    local m_mode = Config.m_items and Config.m_items.m_mode or 'none'

    if m_mode == 'none' then
        return nil
    end

    if BennyCserviceFramework.Type == 'custom' then
        if m_mode == 'store_return' then
            return BennyCserviceIntegrations.ConfiscateItems(m_source)
        end

        if m_mode == 'permanent_remove' then
            BennyCserviceIntegrations.RemoveAllItems(m_source)
            return nil
        end

        return nil
    end

    local m_items = BennyCserviceInventory.GetAllItems(m_source)

    if m_mode == 'permanent_remove' then
        BennyCserviceInventory.ClearAllItems(m_source)
        BennyCserviceDebug.Print(('permanently removed items from %s'):format(m_source))
        return nil
    end

    if m_mode == 'store_return' then
        BennyCserviceInventory.ClearAllItems(m_source)
        BennyCserviceDebug.Print(('stored %s items from %s'):format(#m_items, m_source))
        return m_items
    end

    return nil
end

function BennyCserviceInventory.HandleReturn(m_source, m_items)
    if type(m_items) ~= 'table' or #m_items == 0 then
        return false
    end

    if BennyCserviceFramework.Type == 'custom' then
        return BennyCserviceIntegrations.ReturnItems(m_source, m_items) == true
    end

    return BennyCserviceInventory.RestoreItems(m_source, m_items)
end

BennyCserviceDebug.Print(('inventory provider loaded (%s)'):format(BennyCserviceInventory.GetProvider()))
