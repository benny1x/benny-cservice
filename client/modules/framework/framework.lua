BennyCserviceClientFramework = BennyCserviceClientFramework or {}

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

BennyCserviceClientFramework.Type = mDetectFramework()

CreateThread(function()
    if BennyCserviceClientFramework.Type == 'esx' then
        while not ESX do
            TriggerEvent('esx:getSharedObject', function(m_obj)
                ESX = m_obj
            end)
            Wait(200)
        end
    end

    BennyCserviceDebug.Print(('client framework loaded (%s)'):format(BennyCserviceClientFramework.Type))
end)
