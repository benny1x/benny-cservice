BennyCservicePermissions = BennyCservicePermissions or {}

local function mHasAce(m_source)
    local m_cfg = Config.m_permissions

    if not m_cfg or not m_cfg.m_use_ace then
        return false
    end

    local m_aces = m_cfg.m_ace or {}

    for m_index = 1, #m_aces do
        if IsPlayerAceAllowed(m_source, m_aces[m_index]) then
            return true
        end
    end

    return false
end

local function mHasGroup(m_source)
    local m_cfg = Config.m_permissions
    local m_group = BennyCserviceFramework.GetGroup(m_source)

    if not m_group or not m_cfg or not m_cfg.m_groups then
        return false
    end

    m_group = m_group:lower()

    for m_index = 1, #m_cfg.m_groups do
        if m_cfg.m_groups[m_index]:lower() == m_group then
            return true
        end
    end

    return false
end

local function mHasJob(m_source)
    local m_cfg = Config.m_permissions

    if not m_cfg or not m_cfg.m_jobs then
        return false
    end

    local m_job, m_grade = BennyCserviceFramework.GetJob(m_source)

    if not m_job then
        return false
    end

    m_job = m_job:lower()

    for m_index = 1, #m_cfg.m_jobs do
        local m_entry = m_cfg.m_jobs[m_index]

        if m_entry.m_job:lower() == m_job and m_grade >= (m_entry.m_min_grade or 0) then
            return true
        end
    end

    return false
end

function BennyCservicePermissions.CanManage(m_source)
    if not m_source or GetPlayerPing(m_source) <= 0 then
        return false
    end

    if Config.m_permissions and Config.m_permissions.m_use_custom then
        return BennyCserviceIntegrations.HasPermission(m_source) == true
    end

    if mHasAce(m_source) then
        return true
    end

    if mHasGroup(m_source) then
        return true
    end

    if mHasJob(m_source) then
        return true
    end

    return false
end
