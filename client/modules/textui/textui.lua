BennyCserviceTextUi = BennyCserviceTextUi or {}

local m_active = false
local m_active_provider = nil

local m_fallback_order = {
    'ox_lib',
    'okokTextUI',
    'jg-textui',
    'cd_drawtextui',
    'native',
}

local function mIsResourceStarted(m_name)
    return GetResourceState(m_name) == 'started'
end

local function mDetectProvider()
    local m_cfg = Config.m_text_ui or {}
    local m_provider = m_cfg.m_provider or 'benny-textui'

    if m_provider == 'benny-textui' or m_provider == 'auto' then
        if mIsResourceStarted('benny-textui') then
            return 'benny-textui'
        end

        if m_provider == 'benny-textui' then
            m_provider = 'auto'
        end
    end

    if m_provider ~= 'auto' then
        return m_provider
    end

    for m_index = 1, #m_fallback_order do
        local m_name = m_fallback_order[m_index]

        if m_name == 'ox_lib' then
            if lib and lib.showTextUI then
                return 'ox_lib'
            end
        elseif m_name == 'native' then
            return 'native'
        elseif mIsResourceStarted(m_name) then
            return m_name
        end
    end

    return 'native'
end

function BennyCserviceTextUi.Show(m_data)
    local m_provider = mDetectProvider()
    local m_label = m_data.m_label or 'Interact'
    local m_key = m_data.m_key or Config.m_text_ui.m_key or 'E'

    if m_provider == 'benny-textui' then
        exports['benny-textui']:Show({
            mLabel = m_label,
            mKey = m_key,
            mIcon = m_data.m_icon or 'hand',
            mPosition = Config.m_text_ui.m_position or 'right-center',
            mAccent = Config.m_text_ui.m_accent or 'orange',
        })
        m_active = true
        m_active_provider = 'benny-textui'
        return true
    end

    if m_provider == 'ox_lib' and lib and lib.showTextUI then
        lib.showTextUI(('[%s] %s'):format(m_key, m_label), {
            position = Config.m_text_ui.m_position or 'right-center',
        })
        m_active = true
        m_active_provider = 'ox_lib'
        return true
    end

    if m_provider == 'okokTextUI' then
        exports['okokTextUI']:Open(('[%s] %s'):format(m_key, m_label), 'darkblue', 'left')
        m_active = true
        m_active_provider = 'okokTextUI'
        return true
    end

    if m_provider == 'jg-textui' then
        exports['jg-textui']:DrawText(m_label)
        m_active = true
        m_active_provider = 'jg-textui'
        return true
    end

    if m_provider == 'cd_drawtextui' then
        TriggerEvent('cd_drawtextui:ShowUI', 'show', ('[%s] %s'):format(m_key, m_label))
        m_active = true
        m_active_provider = 'cd_drawtextui'
        return true
    end

    m_active = true
    m_active_provider = 'native'
    return true
end

function BennyCserviceTextUi.Hide()
    if not m_active then
        return false
    end

    local m_provider = m_active_provider or mDetectProvider()

    if m_provider == 'benny-textui' then
        exports['benny-textui']:Hide()
    elseif m_provider == 'ox_lib' and lib and lib.hideTextUI then
        lib.hideTextUI()
    elseif m_provider == 'okokTextUI' then
        exports['okokTextUI']:Close()
    elseif m_provider == 'jg-textui' then
        exports['jg-textui']:HideText()
    elseif m_provider == 'cd_drawtextui' then
        TriggerEvent('cd_drawtextui:HideUI')
    end

    m_active = false
    m_active_provider = nil
    return true
end

function BennyCserviceTextUi.IsActive()
    return m_active
end

function BennyCserviceTextUi.GetProvider()
    return m_active_provider or mDetectProvider()
end

function BennyCserviceTextUi.DrawNative(m_label, m_key)
    SetTextComponentFormat('STRING')
    AddTextComponentString(('[%s] %s'):format(m_key or 'E', m_label))
    DisplayHelpTextFromStringLabel(0, false, true, -1)
end

CreateThread(function()
    BennyCserviceDebug.Print(('text ui provider (%s)'):format(mDetectProvider()))
end)
