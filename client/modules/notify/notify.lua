BennyCserviceNotify = BennyCserviceNotify or {}

function BennyCserviceNotify.Show(m_message, m_type)
    local m_provider = Config.m_notify

    if m_provider == 'auto' then
        if GetResourceState('ox_lib') == 'started' then
            m_provider = 'ox_lib'
        elseif BennyCserviceClientFramework.Type == 'qbox' then
            m_provider = 'qbox'
        elseif BennyCserviceClientFramework.Type == 'qb' then
            m_provider = 'qb'
        elseif BennyCserviceClientFramework.Type == 'esx' then
            m_provider = 'esx'
        else
            m_provider = 'native'
        end
    end

    if m_provider == 'ox_lib' and lib and lib.notify then
        lib.notify({
            description = m_message,
            type = m_type or 'inform',
        })
        return
    end

    if m_provider == 'qb' then
        TriggerEvent('QBCore:Notify', m_message, m_type or 'primary')
        return
    end

    if m_provider == 'esx' and ESX and ESX.ShowNotification then
        ESX.ShowNotification(m_message)
        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(m_message)
    EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent('benny-cservice:client:notify', function(m_message, m_type)
    BennyCserviceNotify.Show(m_message, m_type)
end)
