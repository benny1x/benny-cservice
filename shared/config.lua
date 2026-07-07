Config = {}

Config.m_debug = true -- debug prints

Config.m_framework = 'auto' -- esx | qb | qbox | standalone | custom | auto

Config.m_inventory = 'auto' -- ox_inventory | qb-inventory | auto

Config.m_notify = 'auto' -- ox_lib | esx | qb | auto

Config.m_text_ui = {
    m_provider = 'benny-textui', -- benny-textui | ox_lib | okokTextUI | auto
    m_position = 'right-center', -- prompt position
    m_accent = 'orange', -- benny-textui accent
    m_key = 'E', -- interact key label
}

Config.m_locale = {
    m_sweep_prompt = 'Sweep the ground',
    m_garden_prompt = 'Pull weeds',
    m_tasks_remaining = '%s tasks remaining',
    m_comserv_started = 'You have been assigned %s community service tasks',
    m_comserv_completed = 'You have completed your community service',
    m_comserv_removed = 'Your community service has been cleared',
    m_comserv_forced_back = 'You cannot leave the community service area',
    m_no_permission = 'You do not have permission to do that',
    m_player_not_found = 'Player not found',
    m_invalid_amount = 'Invalid task amount',
    m_assigned = 'Assigned %s tasks to %s',
    m_already_in_comserv = 'That player is already in community service',
    m_comserv_added = 'You have been assigned %s more community service tasks',
    m_assigned_added = 'Added %s tasks to %s (%s remaining)',
    m_not_in_comserv = 'That player is not in community service',
    m_status = '%s has %s tasks remaining',
    m_task_done = 'Task complete, %s remaining',
    m_spot_cooldown = 'That spot needs a moment, find another one',
    m_hud_title = 'Community Service',
    m_hud_remaining = 'tasks remaining',
    m_hud_text_line = 'Community Service - %s tasks remaining',
    m_hud_text_progress = '%s / %s completed',
    m_cmd_assign_help = 'Assign community service to a player',
    m_cmd_remove_help = 'Remove a player from community service',
    m_cmd_check_help = 'Check how many community service tasks a player has left',
    m_cmd_param_id = 'Player server ID',
    m_cmd_param_tasks = 'Number of tasks',
}

function Config.GetLocale(m_key)
    return Config.m_locale[m_key] or m_key
end

function Config.GetTaskZone(m_task_type)
    local m_task = Config.m_tasks and Config.m_tasks[m_task_type]

    if m_task and m_task.m_zone then
        return m_task.m_zone
    end

    return Config.m_zone or {}
end

function Config.GetEnabledTaskTypes()
    local m_list = {}

    for m_task_id, m_task_cfg in pairs(Config.m_tasks or {}) do
        if m_task_cfg.m_enabled and m_task_cfg.m_locations and #m_task_cfg.m_locations > 0 then
            m_list[#m_list + 1] = m_task_id
        end
    end

    return m_list
end

function Config.PickRandomTaskType()
    local m_list = Config.GetEnabledTaskTypes()

    if #m_list == 0 then
        return 'm_sweep'
    end

    if #m_list == 1 then
        return m_list[1]
    end

    return m_list[math.random(1, #m_list)]
end

Config.m_commands = {
    m_assign = 'comserv', -- assign command
    m_remove = 'endcomserv', -- remove command
    m_check = 'checkcomserv', -- check command
}

Config.m_debug_commands = {
    m_enabled = true, -- debug commands on
    m_status = 'cserv_debug',
    m_force_start = 'cserv_debug_start',
    m_force_stop = 'cserv_debug_stop',
}

Config.m_permissions = {
    m_use_ace = true, -- ace permissions
    m_ace = {
        'command.comserv',
        'benny.cservice.admin',
    },
    m_groups = { -- admin groups
        'admin',
        'god',
        'superadmin',
    },
    m_jobs = { -- allowed jobs
        { m_job = 'police', m_min_grade = 2 },
        { m_job = 'sheriff', m_min_grade = 0 },
    },
    m_use_custom = false, -- use integrations.lua
}

Config.m_items = {
    m_mode = 'store_return', -- none | store_return | permanent_remove
}

Config.m_release = {
    m_mode = 'fixed_locations', -- fixed_locations | original_position
    m_use_random = true, -- random release point
    m_locations = {
        vec4(428.08, -980.14, 30.71, 91.14),
    },
}

Config.m_zone = {
    m_center = vec3(3680.0, 4968.0, 16.0), -- zone center
    m_radius = 85.0, -- zone radius
    m_teleport_height = 0.5, -- teleport z offset
    m_check_interval = 1000, -- anti leave check ms
    m_disable_weapons = true, -- strip weapons
    m_disable_vehicle = true, -- kick from vehicles
}

Config.m_markers = {
    m_enabled = true, -- show markers
    m_type = 2, -- marker type
    m_scale = vec3(0.4, 0.4, 0.4),
    m_color = { r = 255, g = 140, b = 0, a = 200 },
    m_height = 0.35, -- arrow height above ground
    m_bob = true,
    m_face_camera = false,
    m_rotate = true,
    m_draw_distance = 60.0,
    m_interact_distance = 1.8,
    m_waypoint = true, -- gps to nearest spot
}

Config.m_tasks_settings = {
    m_ground_snap = true, -- snap ped to ground
    m_ground_offset = 0.0, -- height tweak
    m_ground_tolerance = 4.0, -- max snap drift from config z
    m_spot_cooldown = 30, -- seconds before same spot reuse
    m_random_task = true, -- random sweep or garden on jailed
}

Config.m_tasks = {
    m_sweep = {
        m_enabled = true,
        m_label = 'Sweep',
        m_duration = 8000, -- task duration ms
        m_key = 38, -- E key
        m_icon = 'brush',
        m_zone = {
            m_center = vec3(3680.0, 4968.0, 16.0),
            m_radius = 85.0,
        },
        m_anim = {
            m_dict = 'amb@world_human_janitor@male@idle_a',
            m_clip = 'idle_a',
            m_flag = 49,
        },
        m_prop = {
            m_model = 'prop_tool_broom',
            m_bone = 28422,
            m_offset = vec3(-0.005, 0.0, 0.0),
            m_rotation = vec3(360.0, 360.0, 0.0),
        },
        m_locations = {
            vec4(3686.36, 4952.68, 19.1, 49.33),
            vec4(3689.9, 4947.39, 19.71, 219.61),
            vec4(3705.57, 4941.34, 22.24, 253.75),
            vec4(3703.03, 4932.11, 19.08, 118.26),
            vec4(3676.64, 4945.76, 17.34, 92.89),
            vec4(3670.53, 4953.95, 16.88, 48.36),
            vec4(3657.09, 4953.06, 15.22, 96.18),
            vec4(3656.14, 4949.78, 15.02, 139.69),
            vec4(3656.12, 4970.47, 12.56, 348.15),
            vec4(3659.35, 4979.99, 12.62, 323.58),
            vec4(3652.39, 4995.16, 12.46, 130.7),
            vec4(3641.02, 4996.03, 12.1, 81.42),
            vec4(3640.35, 5001.23, 12.49, 10.21),
            vec4(3636.61, 5003.34, 12.8, 78.24),
        },
    },
    m_garden = {
        m_enabled = true,
        m_label = 'Garden',
        m_duration = 7000,
        m_key = 38,
        m_icon = 'flower-2',
        m_zone = {
            m_center = vec3(2047.0, 4945.0, 41.0),
            m_radius = 45.0,
        },
        m_anim = {
            m_dict = 'amb@world_human_gardener_plant@male@base',
            m_clip = 'base',
            m_flag = 49,
        },
        m_prop = nil,
        m_locations = {
            vec4(2034.92, 4941.04, 41.08, 140.74),
            vec4(2039.69, 4947.12, 41.09, 336.66),
            vec4(2042.82, 4952.64, 41.09, 337.92),
            vec4(2043.41, 4957.85, 41.1, 232.23),
            vec4(2047.17, 4953.9, 41.08, 230.46),
            vec4(2051.05, 4949.85, 41.07, 74.28),
            vec4(2055.1, 4945.55, 41.07, 321.23),
            vec4(2062.19, 4939.08, 41.12, 19.39),
            vec4(2057.92, 4937.63, 41.12, 237.08),
        },
    },
}

Config.m_hud = {
    m_enabled = true, -- sentence hud
    m_style = 'panel', -- panel | text
    m_position = 'top-center', -- panel position
    m_accent = '#9B5CFF', -- panel accent
    m_accent_dark = '#7A2CFF', -- panel dark accent
    m_text = {
        m_x = 0.5, -- screen x
        m_y = 0.025, -- screen y
        m_scale = 0.42, -- gta text scale
        m_font = 4, -- gta font id
        m_line_gap = 0.028, -- second line offset
        m_show_progress = false, -- second line
    },
}
