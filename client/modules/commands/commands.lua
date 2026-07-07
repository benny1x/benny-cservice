CreateThread(function()
    local m_cmds = Config.m_commands or {}

    TriggerEvent('chat:addSuggestion', '/' .. (m_cmds.m_assign or 'comserv'), Config.GetLocale('m_cmd_assign_help'), {
        { name = 'id', help = Config.GetLocale('m_cmd_param_id') },
        { name = 'tasks', help = Config.GetLocale('m_cmd_param_tasks') },
    })

    TriggerEvent('chat:addSuggestion', '/' .. (m_cmds.m_remove or 'endcomserv'), Config.GetLocale('m_cmd_remove_help'), {
        { name = 'id', help = Config.GetLocale('m_cmd_param_id') },
    })

    TriggerEvent('chat:addSuggestion', '/' .. (m_cmds.m_check or 'checkcomserv'), Config.GetLocale('m_cmd_check_help'), {
        { name = 'id', help = Config.GetLocale('m_cmd_param_id') },
    })

    local m_debug = Config.m_debug_commands

    if Config.m_debug and m_debug and m_debug.m_enabled then
        TriggerEvent('chat:addSuggestion', '/' .. (m_debug.m_force_start or 'cserv_debug_start'), 'Debug assign community service to yourself', {
            { name = 'tasks', help = Config.GetLocale('m_cmd_param_tasks') },
        })

        TriggerEvent('chat:addSuggestion', '/' .. (m_debug.m_force_stop or 'cserv_debug_stop'), 'Debug clear your community service')
        TriggerEvent('chat:addSuggestion', '/' .. (m_debug.m_status or 'cserv_debug'), 'Debug community service state')
    end
end)
