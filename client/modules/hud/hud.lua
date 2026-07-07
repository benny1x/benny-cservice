BennyCserviceHud = BennyCserviceHud or {}

local m_visible = false
local m_text_running = false
local m_text_remaining = 0
local m_text_total = 0

local function mGetStyle()
    local m_hud = Config.m_hud or {}
    return m_hud.m_style or 'panel'
end

local function mIsPanelStyle()
    return mGetStyle() == 'panel'
end

local function mDrawTextLine(m_text, m_x, m_y, m_scale, m_font)
    SetTextFont(m_font or 4)
    SetTextScale(m_scale, m_scale)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(m_text)
    DrawText(m_x, m_y)
end

local function mStopText()
    m_text_running = false
end

local function mStartText()
    if m_text_running then
        return
    end

    m_text_running = true

    CreateThread(function()
        local m_cfg = Config.m_hud and Config.m_hud.m_text or {}

        while m_text_running do
            local m_line_one = Config.GetLocale('m_hud_text_line'):format(m_text_remaining)
            local m_line_two = Config.GetLocale('m_hud_text_progress'):format(
                math.max(0, m_text_total - m_text_remaining),
                m_text_total
            )

            mDrawTextLine(
                m_line_one,
                m_cfg.m_x or 0.5,
                m_cfg.m_y or 0.025,
                m_cfg.m_scale or 0.42,
                m_cfg.m_font or 4
            )

            if m_cfg.m_show_progress == true then
                mDrawTextLine(
                    m_line_two,
                    m_cfg.m_x or 0.5,
                    (m_cfg.m_y or 0.025) + (m_cfg.m_line_gap or 0.028),
                    (m_cfg.m_scale or 0.42) - 0.06,
                    m_cfg.m_font or 4
                )
            end

            Wait(0)
        end
    end)
end

local function mUpdateTextState(m_tasks_remaining, m_total_tasks)
    m_text_remaining = m_tasks_remaining or 0
    m_text_total = m_total_tasks or m_tasks_remaining or 0
end

local function mBuildPayload(m_tasks_remaining, m_total_tasks)
    local m_hud = Config.m_hud or {}

    return {
        m_tasks_remaining = m_tasks_remaining or 0,
        m_total_tasks = m_total_tasks or m_tasks_remaining or 0,
        m_title = Config.GetLocale('m_hud_title'),
        m_remaining_label = Config.GetLocale('m_hud_remaining'),
        m_accent = m_hud.m_accent,
        m_accent_dark = m_hud.m_accent_dark,
    }
end

local function mHidePanel()
    SendNUIMessage({ m_action = 'hud_hide' })
end

local function mShowPanel(m_tasks_remaining, m_total_tasks)
    SendNUIMessage({
        m_action = 'hud_show',
        m_data = mBuildPayload(m_tasks_remaining, m_total_tasks),
    })
end

local function mUpdatePanel(m_tasks_remaining, m_total_tasks)
    SendNUIMessage({
        m_action = m_visible and 'hud_update' or 'hud_show',
        m_data = mBuildPayload(m_tasks_remaining, m_total_tasks),
    })
end

function BennyCserviceHud.Show(m_tasks_remaining, m_total_tasks)
    if not Config.m_hud or not Config.m_hud.m_enabled then
        return
    end

    m_visible = true

    if mIsPanelStyle() then
        mStopText()
        mShowPanel(m_tasks_remaining, m_total_tasks)
        return
    end

    mHidePanel()
    mUpdateTextState(m_tasks_remaining, m_total_tasks)
    mStartText()
end

function BennyCserviceHud.Update(m_tasks_remaining, m_total_tasks)
    if not Config.m_hud or not Config.m_hud.m_enabled then
        return
    end

    m_visible = true

    if mIsPanelStyle() then
        mUpdatePanel(m_tasks_remaining, m_total_tasks)
        return
    end

    mUpdateTextState(m_tasks_remaining, m_total_tasks)

    if not m_text_running then
        mStartText()
    end
end

function BennyCserviceHud.Hide()
    m_visible = false
    mHidePanel()
    mStopText()
end

function BennyCserviceHud.IsVisible()
    return m_visible
end
