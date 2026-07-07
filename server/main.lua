local m_active = {}
local m_last_complete = {}

local function mEncodeItems(m_items)
    if type(m_items) ~= 'table' or #m_items == 0 then
        return nil
    end

    return json.encode(m_items)
end

local function mDecodeItems(m_json)
    if not m_json or m_json == '' then
        return nil
    end

    local m_ok, m_items = pcall(json.decode, m_json)

    if m_ok and type(m_items) == 'table' then
        return m_items
    end

    return nil
end

local function mGetPlayerCoords(m_source)
    local m_ped = GetPlayerPed(m_source)

    if not m_ped or m_ped == 0 then
        return 0.0, 0.0, 0.0, 0.0
    end

    local m_coords = GetEntityCoords(m_ped)
    local m_heading = GetEntityHeading(m_ped)

    return m_coords.x, m_coords.y, m_coords.z, m_heading
end

local function mBuildReleaseCoords(m_row)
    local m_cfg = Config.m_release or {}

    if m_cfg.m_mode == 'original_position' and m_row then
        return {
            x = m_row.original_x,
            y = m_row.original_y,
            z = m_row.original_z,
            w = m_row.original_w,
        }
    end

    local m_locations = m_cfg.m_locations or {}

    if #m_locations == 0 then
        return { x = 428.08, y = -980.14, z = 30.71, w = 91.14 }
    end

    local m_pick = m_locations[1]

    if m_cfg.m_use_random then
        m_pick = m_locations[math.random(1, #m_locations)]
    end

    return {
        x = m_pick.x,
        y = m_pick.y,
        z = m_pick.z,
        w = m_pick.w,
    }
end

local function mSendState(m_source, m_data)
    TriggerClientEvent('benny-cservice:client:set_state', m_source, m_data)
end

local function mClearState(m_source, m_release_coords)
    m_active[m_source] = nil
    TriggerClientEvent('benny-cservice:client:clear_state', m_source, m_release_coords)
end

local function mLoadPlayerState(m_source)
    local m_identifier = BennyCserviceFramework.GetIdentifier(m_source)

    if not m_identifier then
        return
    end

    local m_row = BennyCserviceDatabase.GetByIdentifier(m_identifier)

    if not m_row or (m_row.tasks_remaining or 0) <= 0 then
        return
    end

    m_active[m_source] = {
        m_identifier = m_identifier,
        m_tasks_remaining = m_row.tasks_remaining,
        m_total_tasks = m_row.total_tasks,
        m_task_type = m_row.task_type or 'm_sweep',
        m_items = mDecodeItems(m_row.items_json),
    }

    mSendState(m_source, {
        m_active = true,
        m_tasks_remaining = m_row.tasks_remaining,
        m_total_tasks = m_row.total_tasks,
        m_task_type = m_row.task_type or 'm_sweep',
    })

    BennyCserviceDebug.Print(('restored comserv for %s (%s tasks left)'):format(m_source, m_row.tasks_remaining))
end

local function mAssignComserv(m_source, m_target, m_amount, m_admin_source)
    local m_identifier = BennyCserviceFramework.GetIdentifier(m_target)

    if not m_identifier then
        BennyCserviceFramework.Notify(m_admin_source, Config.GetLocale('m_player_not_found'), 'error')
        return false
    end

    local m_state = m_active[m_target]
    local m_existing = BennyCserviceDatabase.GetByIdentifier(m_identifier)
    local m_already_in = m_state ~= nil or (m_existing and (m_existing.tasks_remaining or 0) > 0)

    if m_already_in then
        local m_current_remaining = m_state and m_state.m_tasks_remaining or (m_existing and m_existing.tasks_remaining or 0)
        local m_current_total = m_state and m_state.m_total_tasks or (m_existing and m_existing.total_tasks or m_current_remaining)
        local m_new_remaining = m_current_remaining + m_amount
        local m_new_total = m_current_total + m_amount

        BennyCserviceDatabase.UpdateTasks(m_identifier, m_new_remaining, m_new_total)

        if m_state then
            m_state.m_tasks_remaining = m_new_remaining
            m_state.m_total_tasks = m_new_total
        else
            m_active[m_target] = {
                m_identifier = m_identifier,
                m_tasks_remaining = m_new_remaining,
                m_total_tasks = m_new_total,
                m_task_type = m_existing and m_existing.task_type or 'm_sweep',
                m_items = mDecodeItems(m_existing and m_existing.items_json),
            }
        end

        mSendState(m_target, {
            m_active = true,
            m_tasks_remaining = m_new_remaining,
            m_total_tasks = m_new_total,
            m_task_type = m_state and m_state.m_task_type or (m_existing and m_existing.task_type) or 'm_sweep',
        })

        BennyCserviceFramework.Notify(m_target, Config.GetLocale('m_comserv_added'):format(m_amount), 'inform')
        BennyCserviceFramework.Notify(
            m_admin_source,
            Config.GetLocale('m_assigned_added'):format(
                m_amount,
                BennyCserviceFramework.GetCharacterName(m_target),
                m_new_remaining
            ),
            'success'
        )

        BennyCserviceDebug.Print(('added %s tasks to %s by %s (%s remaining)'):format(m_amount, m_target, m_admin_source, m_new_remaining))
        return true
    end

    local m_task_type = 'm_sweep'

    if Config.m_tasks_settings and Config.m_tasks_settings.m_random_task ~= false then
        m_task_type = Config.PickRandomTaskType()
    end

    local m_x, m_y, m_z, m_w = mGetPlayerCoords(m_target)
    local m_items = BennyCserviceInventory.HandleConfiscation(m_target)

    BennyCserviceDatabase.Upsert(m_identifier, {
        m_tasks_remaining = m_amount,
        m_total_tasks = m_amount,
        m_original_x = m_x,
        m_original_y = m_y,
        m_original_z = m_z,
        m_original_w = m_w,
        m_items_json = mEncodeItems(m_items),
        m_task_type = m_task_type,
    })

    m_active[m_target] = {
        m_identifier = m_identifier,
        m_tasks_remaining = m_amount,
        m_total_tasks = m_amount,
        m_task_type = m_task_type,
        m_items = m_items,
    }

    mSendState(m_target, {
        m_active = true,
        m_tasks_remaining = m_amount,
        m_total_tasks = m_amount,
        m_task_type = m_task_type,
    })

    BennyCserviceFramework.Notify(m_target, Config.GetLocale('m_comserv_started'):format(m_amount), 'inform')
    BennyCserviceFramework.Notify(
        m_admin_source,
        Config.GetLocale('m_assigned'):format(m_amount, BennyCserviceFramework.GetCharacterName(m_target)),
        'success'
    )

    BennyCserviceDebug.Print(('assigned %s tasks to %s by %s'):format(m_amount, m_target, m_admin_source))
    return true
end

local function mReleasePlayer(m_source, m_notify, m_admin_source)
    local m_state = m_active[m_source]
    local m_identifier = m_state and m_state.m_identifier or BennyCserviceFramework.GetIdentifier(m_source)
    local m_row = m_identifier and BennyCserviceDatabase.GetByIdentifier(m_identifier) or nil

    if not m_state and (not m_row or (m_row.tasks_remaining or 0) <= 0) then
        if m_admin_source then
            BennyCserviceFramework.Notify(m_admin_source, Config.GetLocale('m_not_in_comserv'), 'error')
        end

        return false
    end

    local m_items = m_state and m_state.m_items or mDecodeItems(m_row and m_row.items_json)

    if Config.m_items and Config.m_items.m_mode == 'store_return' then
        BennyCserviceInventory.HandleReturn(m_source, m_items)
    end

    if m_identifier then
        BennyCserviceDatabase.Delete(m_identifier)
    end

    local m_release_coords = mBuildReleaseCoords(m_row)
    mClearState(m_source, m_release_coords)

    if m_notify then
        BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_comserv_completed'), 'success')
    end

    if m_admin_source then
        BennyCserviceFramework.Notify(
            m_admin_source,
            Config.GetLocale('m_comserv_removed'),
            'success'
        )
    end

    BennyCserviceDebug.Print(('released %s from comserv'):format(m_source))
    return true
end

RegisterNetEvent('benny-cservice:server:complete_task', function(m_task_id, m_location_index)
    local m_source = source
    local m_state = m_active[m_source]

    if not m_state or (m_state.m_tasks_remaining or 0) <= 0 then
        return
    end

    if type(m_task_id) ~= 'string' or type(m_location_index) ~= 'number' then
        BennyCserviceDebug.Warn(('invalid task completion from %s'):format(m_source))
        return
    end

    local m_task_cfg = Config.m_tasks and Config.m_tasks[m_task_id]

    if not m_task_cfg or not m_task_cfg.m_enabled then
        return
    end

    if m_state.m_task_type and m_state.m_task_type ~= m_task_id then
        BennyCserviceDebug.Warn(('wrong task type from %s'):format(m_source))
        return
    end

    local m_locations = m_task_cfg.m_locations or {}

    if not m_locations[m_location_index] then
        BennyCserviceDebug.Warn(('invalid location index from %s'):format(m_source))
        return
    end

    local m_ped = GetPlayerPed(m_source)

    if not m_ped or m_ped == 0 then
        return
    end

    local m_coords = GetEntityCoords(m_ped)
    local m_location = m_locations[m_location_index]
    local m_distance = #(m_coords - vec3(m_location.x, m_location.y, m_location.z))
    local m_max_distance = (Config.m_markers and Config.m_markers.m_interact_distance or 1.8) + 1.5

    if m_distance > m_max_distance then
        BennyCserviceDebug.Warn(('task completion too far from %s (%.2f)'):format(m_source, m_distance))
        return
    end

    local m_zone = Config.GetTaskZone(m_state.m_task_type or m_task_id)

    if m_zone and m_zone.m_center then
        local m_zone_distance = #(m_coords - m_zone.m_center)

        if m_zone_distance > (m_zone.m_radius or 85.0) + 5.0 then
            BennyCserviceDebug.Warn(('task completion outside zone from %s'):format(m_source))
            return
        end
    end

    local m_cooldown = math.max(1, math.floor((m_task_cfg.m_duration or 8000) / 1000) - 1)
    local m_now = os.time()

    if m_last_complete[m_source] and (m_now - m_last_complete[m_source]) < m_cooldown then
        BennyCserviceDebug.Warn(('task completion cooldown from %s'):format(m_source))
        return
    end

    m_last_complete[m_source] = m_now

    m_state.m_tasks_remaining = m_state.m_tasks_remaining - 1
    BennyCserviceDatabase.UpdateTasks(m_state.m_identifier, m_state.m_tasks_remaining)

    if m_state.m_tasks_remaining <= 0 then
        mReleasePlayer(m_source, true)
        return
    end

    mSendState(m_source, {
        m_active = true,
        m_tasks_remaining = m_state.m_tasks_remaining,
        m_total_tasks = m_state.m_total_tasks,
        m_task_type = m_state.m_task_type,
    })

    BennyCserviceFramework.Notify(
        m_source,
        Config.GetLocale('m_task_done'):format(m_state.m_tasks_remaining),
        'inform'
    )
end)

RegisterNetEvent('benny-cservice:server:request_state', function()
    mLoadPlayerState(source)
end)

RegisterNetEvent('benny-cservice:server:zone_violation', function()
    local m_source = source
    local m_state = m_active[m_source]

    if not m_state then
        return
    end

    BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_comserv_forced_back'), 'error')
    TriggerClientEvent('benny-cservice:client:force_back', m_source)
end)

AddEventHandler('playerJoining', function()
    local m_source = source
    SetTimeout(5000, function()
        if GetPlayerPing(m_source) > 0 then
            mLoadPlayerState(m_source)
        end
    end)
end)

AddEventHandler('playerDropped', function()
    m_active[source] = nil
    m_last_complete[source] = nil
end)

local function mRegisterCommands()
    BennyCserviceCommands.Register({
        m_assign = function(m_source, m_target, m_amount)
            mAssignComserv(m_source, m_target, m_amount, m_source)
        end,
        m_remove = function(m_source, m_target)
            mReleasePlayer(m_target, true, m_source)
        end,
        m_check = function(m_source, m_target)
            local m_state = m_active[m_target]
            local m_remaining = m_state and m_state.m_tasks_remaining or 0

            if m_remaining <= 0 then
                local m_identifier = BennyCserviceFramework.GetIdentifier(m_target)
                local m_row = m_identifier and BennyCserviceDatabase.GetByIdentifier(m_identifier) or nil
                m_remaining = m_row and m_row.tasks_remaining or 0
            end

            if m_remaining <= 0 then
                BennyCserviceFramework.Notify(m_source, Config.GetLocale('m_not_in_comserv'), 'error')
                return
            end

            BennyCserviceFramework.Notify(
                m_source,
                Config.GetLocale('m_status'):format(BennyCserviceFramework.GetCharacterName(m_target), m_remaining),
                'inform'
            )
        end,
    })
end

local function mRegisterDebugCommands()
    BennyCserviceCommands.RegisterDebug({
        m_debug_status = function(m_source)
            local m_state = m_active[m_source]
            BennyCserviceFramework.Notify(
                m_source,
                m_state and ('debug active: %s tasks left'):format(m_state.m_tasks_remaining) or 'debug inactive',
                'inform'
            )
        end,
        m_debug_start = function(m_source, m_amount)
            mAssignComserv(m_source, m_source, m_amount, m_source)
        end,
        m_debug_stop = function(m_source)
            mReleasePlayer(m_source, true, m_source)
        end,
    })
end

exports('IsInCommunityService', function(m_source)
    local m_state = m_active[m_source]
    return m_state ~= nil and (m_state.m_tasks_remaining or 0) > 0
end)

exports('GetTasksRemaining', function(m_source)
    local m_state = m_active[m_source]
    return m_state and m_state.m_tasks_remaining or 0
end)

exports('AssignCommunityService', function(m_admin_source, m_target, m_amount)
    if not BennyCservicePermissions.CanManage(m_admin_source) then
        return false
    end

    return mAssignComserv(m_admin_source, m_target, m_amount, m_admin_source)
end)

exports('RemoveCommunityService', function(m_admin_source, m_target)
    if not BennyCservicePermissions.CanManage(m_admin_source) then
        return false
    end

    return mReleasePlayer(m_target, true, m_admin_source)
end)

CreateThread(function()
    BennyCserviceDatabase.Init()
    mRegisterCommands()
    mRegisterDebugCommands()

    local m_rows = BennyCserviceDatabase.GetAllActive()

    for _, m_row in ipairs(m_rows) do
        local m_source = BennyCserviceFramework.GetSourceByIdentifier(m_row.identifier)

        if m_source then
            mLoadPlayerState(m_source)
        end
    end

    BennyCserviceDebug.Print('server main loaded')
end)
