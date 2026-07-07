BennyCserviceCommands = BennyCserviceCommands or {}

function BennyCserviceCommands.Register(m_handlers)
    local m_cmds = Config.m_commands or {}

    lib.addCommand(m_cmds.m_assign or 'comserv', {
        help = Config.GetLocale('m_cmd_assign_help'),
        params = {
            { name = 'id', type = 'playerId', help = Config.GetLocale('m_cmd_param_id') },
            { name = 'tasks', type = 'number', help = Config.GetLocale('m_cmd_param_tasks') },
        },
    }, function(m_source, m_args)
        if m_source == 0 then
            print('[benny-cservice] use this command in-game')
            return
        end

        if not BennyCservicePermissions.CanManage(m_source) then
            BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_no_permission'), 'error')
            return
        end

        local m_target = m_args.id
        local m_amount = m_args.tasks

        if not m_target then
            BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_player_not_found'), 'error')
            return
        end

        if not m_amount or m_amount < 1 then
            BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_invalid_amount'), 'error')
            return
        end

        m_handlers.m_assign(m_source, m_target, math.floor(m_amount))
    end)

    lib.addCommand(m_cmds.m_remove or 'endcomserv', {
        help = Config.GetLocale('m_cmd_remove_help'),
        params = {
            { name = 'id', type = 'playerId', help = Config.GetLocale('m_cmd_param_id'), optional = true },
        },
    }, function(m_source, m_args)
        if m_source == 0 then
            print('[benny-cservice] use this command in-game')
            return
        end

        if not BennyCservicePermissions.CanManage(m_source) then
            BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_no_permission'), 'error')
            return
        end

        local m_target = m_args.id or m_source

        if not m_target or GetPlayerPing(m_target) <= 0 then
            BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_player_not_found'), 'error')
            return
        end

        m_handlers.m_remove(m_source, m_target)
    end)

    lib.addCommand(m_cmds.m_check or 'checkcomserv', {
        help = Config.GetLocale('m_cmd_check_help'),
        params = {
            { name = 'id', type = 'playerId', help = Config.GetLocale('m_cmd_param_id'), optional = true },
        },
    }, function(m_source, m_args)
        if m_source == 0 then
            print('[benny-cservice] use this command in-game')
            return
        end

        if not BennyCservicePermissions.CanManage(m_source) then
            BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_no_permission'), 'error')
            return
        end

        local m_target = m_args.id or m_source

        if not m_target or GetPlayerPing(m_target) <= 0 then
            BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_player_not_found'), 'error')
            return
        end

        m_handlers.m_check(m_source, m_target)
    end)

    BennyCserviceDebug.Print('commands registered')
end

function BennyCserviceCommands.RegisterDebug(m_handlers)
    local m_cfg = Config.m_debug_commands

    if not Config.m_debug or not m_cfg or not m_cfg.m_enabled then
        return
    end

    lib.addCommand(m_cfg.m_status or 'cserv_debug', {
        help = 'Debug community service state',
        params = {},
    }, function(m_source)
        if m_source == 0 then
            print('[benny-cservice] debug status requested from console')
            return
        end

        m_handlers.m_debug_status(m_source)
    end)

    lib.addCommand(m_cfg.m_force_start or 'cserv_debug_start', {
        help = 'Debug assign community service to yourself',
        params = {
            { name = 'tasks', type = 'number', help = Config.GetLocale('m_cmd_param_tasks'), optional = true },
        },
    }, function(m_source, m_args)
        if m_source == 0 then
            return
        end

        m_handlers.m_debug_start(m_source, m_args.tasks or 3)
    end)

    lib.addCommand(m_cfg.m_force_stop or 'cserv_debug_stop', {
        help = 'Debug clear your community service',
        params = {},
    }, function(m_source)
        if m_source == 0 then
            return
        end

        m_handlers.m_debug_stop(m_source)
    end)
end
