BennyCserviceFramework = BennyCserviceFramework or {}

local function mDetectFramework()
    if Config.m_framework and Config.m_framework ~= 'auto' then
        return Config.m_framework
    end

    if GetResourceState('qbx_core') == 'started' then
        return 'qbox'
    end

    if GetResourceState('qb-core') == 'started' then
        return 'qb'
    end

    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end

    return 'standalone'
end

BennyCserviceFramework.Type = mDetectFramework()

function BennyCserviceFramework.GetPlayer(m_source)
    if BennyCserviceFramework.Type == 'custom' then
        return BennyCserviceIntegrations.GetPlayer(m_source)
    end

    if BennyCserviceFramework.Type == 'qbox' then
        return exports.qbx_core:GetPlayer(m_source)
    end

    if BennyCserviceFramework.Type == 'qb' then
        return exports['qb-core']:GetCoreObject().Functions.GetPlayer(m_source)
    end

    if BennyCserviceFramework.Type == 'esx' then
        return ESX.GetPlayerFromId(m_source)
    end

    return nil
end

function BennyCserviceFramework.GetIdentifier(m_source)
    if BennyCserviceFramework.Type == 'custom' then
        return BennyCserviceIntegrations.GetIdentifier(m_source)
    end

    local m_player = BennyCserviceFramework.GetPlayer(m_source)

    if BennyCserviceFramework.Type == 'esx' then
        return m_player and m_player.identifier or nil
    end

    if m_player and m_player.PlayerData then
        return m_player.PlayerData.citizenid or m_player.PlayerData.license
    end

    for m_index = 0, GetNumPlayerIdentifiers(m_source) - 1 do
        local m_id = GetPlayerIdentifier(m_source, m_index)

        if m_id and m_id:find('license:', 1, true) then
            return m_id
        end
    end

    return ('standalone:%s'):format(m_source)
end

function BennyCserviceFramework.GetCharacterName(m_source)
    if BennyCserviceFramework.Type == 'custom' then
        return BennyCserviceIntegrations.GetCharacterName(m_source)
    end

    local m_player = BennyCserviceFramework.GetPlayer(m_source)

    if not m_player then
        return GetPlayerName(m_source) or 'Unknown'
    end

    if BennyCserviceFramework.Type == 'esx' then
        return m_player.getName and m_player.getName() or 'Unknown'
    end

    local m_charinfo = m_player.PlayerData and m_player.PlayerData.charinfo

    if not m_charinfo then
        return GetPlayerName(m_source) or 'Unknown'
    end

    return ('%s %s'):format(m_charinfo.firstname or '', m_charinfo.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

function BennyCserviceFramework.GetJob(m_source)
    if BennyCserviceFramework.Type == 'custom' then
        return BennyCserviceIntegrations.GetJob(m_source)
    end

    local m_player = BennyCserviceFramework.GetPlayer(m_source)

    if not m_player then
        return nil, 0
    end

    if BennyCserviceFramework.Type == 'esx' then
        local m_job = m_player.getJob and m_player.getJob() or m_player.job

        if m_job then
            return m_job.name, m_job.grade or 0
        end

        return nil, 0
    end

    local m_job = m_player.PlayerData and m_player.PlayerData.job

    if m_job then
        return m_job.name, m_job.grade and (m_job.grade.level or m_job.grade) or 0
    end

    return nil, 0
end

function BennyCserviceFramework.GetGroup(m_source)
    if BennyCserviceFramework.Type == 'custom' then
        return BennyCserviceIntegrations.GetGroup(m_source)
    end

    local m_player = BennyCserviceFramework.GetPlayer(m_source)

    if not m_player then
        return nil
    end

    if BennyCserviceFramework.Type == 'qbox' then
        return m_player.PlayerData and m_player.PlayerData.group or nil
    end

    if BennyCserviceFramework.Type == 'qb' then
        local m_permission = m_player.PlayerData and m_player.PlayerData.permission

        if m_permission then
            return m_permission
        end

        if m_player.Functions and m_player.Functions.GetPermission then
            local m_perms = m_player.Functions.GetPermission()

            if type(m_perms) == 'table' then
                for m_group, m_allowed in pairs(m_perms) do
                    if m_allowed then
                        return m_group
                    end
                end
            end
        end
    end

    if BennyCserviceFramework.Type == 'esx' then
        return m_player.getGroup and m_player.getGroup() or nil
    end

    return nil
end

function BennyCserviceFramework.GetSourceByIdentifier(m_identifier)
    if BennyCserviceFramework.Type == 'qbox' then
        local m_player = exports.qbx_core:GetPlayerByCitizenId(m_identifier)
        return m_player and m_player.PlayerData and m_player.PlayerData.source or nil
    end

    if BennyCserviceFramework.Type == 'qb' then
        local m_player = exports['qb-core']:GetCoreObject().Functions.GetPlayerByCitizenId(m_identifier)
        return m_player and m_player.PlayerData and m_player.PlayerData.source or nil
    end

    if BennyCserviceFramework.Type == 'esx' then
        local m_player = ESX.GetPlayerFromIdentifier(m_identifier)
        return m_player and m_player.source or nil
    end

    if BennyCserviceFramework.Type == 'custom' then
        return nil
    end

    if m_identifier and m_identifier:find('standalone:', 1, true) then
        return tonumber(m_identifier:match('standalone:(%d+)'))
    end

    for _, m_source in ipairs(GetPlayers()) do
        m_source = tonumber(m_source)

        if BennyCserviceFramework.GetIdentifier(m_source) == m_identifier then
            return m_source
        end
    end

    return nil
end

function BennyCserviceFramework.Notify(m_source, m_message, m_type)
    local m_provider = Config.m_notify

    if m_provider == 'auto' then
        if GetResourceState('ox_lib') == 'started' then
            m_provider = 'ox_lib'
        elseif BennyCserviceFramework.Type == 'qbox' then
            m_provider = 'qbox'
        elseif BennyCserviceFramework.Type == 'qb' then
            m_provider = 'qb'
        elseif BennyCserviceFramework.Type == 'esx' then
            m_provider = 'esx'
        else
            m_provider = 'native'
        end
    end

    if m_provider == 'ox_lib' then
        TriggerClientEvent('ox_lib:notify', m_source, {
            description = m_message,
            type = m_type or 'inform',
        })
        return
    end

    if m_provider == 'qbox' then
        exports.qbx_core:Notify(m_source, m_message, m_type or 'inform')
        return
    end

    if m_provider == 'qb' then
        TriggerClientEvent('QBCore:Notify', m_source, m_message, m_type or 'primary')
        return
    end

    if m_provider == 'esx' then
        TriggerClientEvent('esx:showNotification', m_source, m_message)
        return
    end

    if BennyCserviceFramework.Type == 'custom' then
        BennyCserviceIntegrations.Notify(m_source, m_message, m_type)
        return
    end

    TriggerClientEvent('benny-cservice:client:notify', m_source, m_message, m_type or 'inform')
end

CreateThread(function()
    if BennyCserviceFramework.Type == 'esx' then
        while not ESX do
            TriggerEvent('esx:getSharedObject', function(m_obj)
                ESX = m_obj
            end)
            Wait(200)
        end
    end

    BennyCserviceDebug.Print(('server framework loaded (%s)'):format(BennyCserviceFramework.Type))
end)
