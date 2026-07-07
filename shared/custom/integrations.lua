BennyCserviceIntegrations = BennyCserviceIntegrations or {}

function BennyCserviceIntegrations.GetPlayer(m_source)
    return nil
end

function BennyCserviceIntegrations.GetIdentifier(m_source)
    return nil
end

function BennyCserviceIntegrations.GetCharacterName(m_source)
    return GetPlayerName(m_source) or 'Unknown'
end

function BennyCserviceIntegrations.HasPermission(m_source)
    return false
end

function BennyCserviceIntegrations.GetJob(m_source)
    return nil, 0
end

function BennyCserviceIntegrations.GetGroup(m_source)
    return nil
end

function BennyCserviceIntegrations.Notify(m_source, m_message, m_type)
    TriggerClientEvent('benny-cservice:client:notify', m_source, m_message, m_type or 'inform')
end

function BennyCserviceIntegrations.ConfiscateItems(m_source)
    return nil
end

function BennyCserviceIntegrations.ReturnItems(m_source, m_items)
    return false
end

function BennyCserviceIntegrations.RemoveAllItems(m_source)
    return false
end
