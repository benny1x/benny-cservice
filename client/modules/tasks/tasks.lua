BennyCserviceTasks = BennyCserviceTasks or {}

local m_busy = false
local m_active_task_type = nil
local m_cooldowns = {}

local function mSpotKey(m_task_id, m_location_index)
    return ('%s:%s'):format(m_task_id, m_location_index)
end

local function mGetSpotCooldownMs()
    local m_seconds = Config.m_tasks_settings and Config.m_tasks_settings.m_spot_cooldown or 30
    return math.max(1, m_seconds) * 1000
end

local function mLoadAnimDict(m_dict)
    if HasAnimDictLoaded(m_dict) then
        return true
    end

    RequestAnimDict(m_dict)

    local m_timeout = GetGameTimer() + 5000

    while not HasAnimDictLoaded(m_dict) do
        if GetGameTimer() > m_timeout then
            return false
        end

        Wait(10)
    end

    return true
end

local function mLoadModel(m_model)
    local m_hash = type(m_model) == 'string' and joaat(m_model) or m_model

    if HasModelLoaded(m_hash) then
        return m_hash
    end

    RequestModel(m_hash)

    local m_timeout = GetGameTimer() + 5000

    while not HasModelLoaded(m_hash) do
        if GetGameTimer() > m_timeout then
            return nil
        end

        Wait(10)
    end

    return m_hash
end

local function mAttachProp(m_ped, m_prop_cfg)
    if not m_prop_cfg or not m_prop_cfg.m_model then
        return nil
    end

    local m_hash = mLoadModel(m_prop_cfg.m_model)

    if not m_hash then
        return nil
    end

    local m_coords = GetEntityCoords(m_ped)
    local m_object = CreateObject(m_hash, m_coords.x, m_coords.y, m_coords.z, true, true, false)
    local m_bone = GetPedBoneIndex(m_ped, m_prop_cfg.m_bone or 28422)
    local m_offset = m_prop_cfg.m_offset or vec3(0.0, 0.0, 0.0)
    local m_rotation = m_prop_cfg.m_rotation or vec3(0.0, 0.0, 0.0)

    AttachEntityToEntity(
        m_object,
        m_ped,
        m_bone,
        m_offset.x, m_offset.y, m_offset.z,
        m_rotation.x, m_rotation.y, m_rotation.z,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(m_hash)
    return m_object
end

local function mGetLocaleKey(m_task_id)
    if m_task_id == 'm_sweep' then
        return 'm_sweep_prompt'
    end

    if m_task_id == 'm_garden' then
        return 'm_garden_prompt'
    end

    return 'm_sweep_prompt'
end

function BennyCserviceTasks.SetTaskType(m_task_type)
    m_active_task_type = m_task_type
end

function BennyCserviceTasks.GetTaskType()
    return m_active_task_type
end

function BennyCserviceTasks.ResetCompleted()
    m_cooldowns = {}
end

function BennyCserviceTasks.SetSpotCooldown(m_task_id, m_location_index)
    m_cooldowns[mSpotKey(m_task_id, m_location_index)] = GetGameTimer() + mGetSpotCooldownMs()
end

function BennyCserviceTasks.IsSpotOnCooldown(m_task_id, m_location_index)
    local m_key = mSpotKey(m_task_id, m_location_index)
    local m_expires = m_cooldowns[m_key]

    if not m_expires then
        return false
    end

    if GetGameTimer() >= m_expires then
        m_cooldowns[m_key] = nil
        return false
    end

    return true
end

function BennyCserviceTasks.IsBusy()
    return m_busy
end

function BennyCserviceTasks.GetActiveLocations()
    local m_list = {}
    local m_task_id = m_active_task_type or 'm_sweep'
    local m_task_cfg = Config.m_tasks and Config.m_tasks[m_task_id]

    if not m_task_cfg or not m_task_cfg.m_enabled or not m_task_cfg.m_locations then
        return m_list
    end

    for m_index, m_location in ipairs(m_task_cfg.m_locations) do
        if not BennyCserviceTasks.IsSpotOnCooldown(m_task_id, m_index) then
            m_list[#m_list + 1] = {
                m_task_id = m_task_id,
                m_index = m_index,
                m_location = m_location,
                m_cfg = m_task_cfg,
            }
        end
    end

    return m_list
end

local function mResolveGroundCoords(m_location)
    local m_settings = Config.m_tasks_settings or {}
    local m_x = m_location.x
    local m_y = m_location.y
    local m_z = m_location.z
    local m_offset = m_settings.m_ground_offset or 0.0

    if m_settings.m_ground_snap ~= false then
        m_z = BennyCserviceMarkers.GetGroundZ(m_x, m_y, m_z) + m_offset
    else
        m_z = m_z + m_offset
    end

    return m_x, m_y, m_z
end

function BennyCserviceTasks.Perform(m_task_id, m_location_index, m_task_cfg, m_location)
    if m_busy then
        return false
    end

    if BennyCserviceTasks.IsSpotOnCooldown(m_task_id, m_location_index) then
        BennyCserviceNotify.Show(Config.GetLocale('m_spot_cooldown'), 'error')
        return false
    end

    m_busy = true
    BennyCserviceTextUi.Hide()

    local m_ped = PlayerPedId()
    local m_anim = m_task_cfg.m_anim or {}
    local m_prop_object = nil
    local m_success = false

    local m_x, m_y, m_z = mResolveGroundCoords(m_location)

    SetEntityCoords(m_ped, m_x, m_y, m_z, false, false, false, false)
    SetEntityHeading(m_ped, m_location.w or 0.0)
    FreezeEntityPosition(m_ped, true)

    if m_anim.m_dict and m_anim.m_clip and mLoadAnimDict(m_anim.m_dict) then
        m_prop_object = mAttachProp(m_ped, m_task_cfg.m_prop)
        TaskPlayAnim(m_ped, m_anim.m_dict, m_anim.m_clip, 8.0, -8.0, -1, m_anim.m_flag or 49, 0.0, false, false, false)
    end

    if lib and lib.progressBar then
        m_success = lib.progressBar({
            duration = m_task_cfg.m_duration or 8000,
            label = m_task_cfg.m_label or 'Working',
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
        }) == true
    else
        Wait(m_task_cfg.m_duration or 8000)
        m_success = true
    end

    ClearPedTasks(m_ped)
    FreezeEntityPosition(m_ped, false)

    if m_prop_object and DoesEntityExist(m_prop_object) then
        DeleteEntity(m_prop_object)
    end

    if m_success then
        BennyCserviceTasks.SetSpotCooldown(m_task_id, m_location_index)
        TriggerServerEvent('benny-cservice:server:complete_task', m_task_id, m_location_index)
    end

    m_busy = false
    return m_success
end

function BennyCserviceTasks.GetNearestSpot()
    local m_locations = BennyCserviceTasks.GetActiveLocations()
    local m_nearest = nil
    local m_nearest_distance = nil

    for m_index = 1, #m_locations do
        local m_entry = m_locations[m_index]
        local m_distance = BennyCserviceMarkers.GetHorizontalDistance(m_entry.m_location)

        if not m_nearest_distance or m_distance < m_nearest_distance then
            m_nearest = m_entry
            m_nearest_distance = m_distance
        end
    end

    return m_nearest, m_nearest_distance
end

function BennyCserviceTasks.GetNearest()
    local m_locations = BennyCserviceTasks.GetActiveLocations()
    local m_nearest = nil
    local m_nearest_distance = nil
    local m_interact_distance = Config.m_markers and Config.m_markers.m_interact_distance or 1.8
    local m_draw_distance = Config.m_markers and Config.m_markers.m_draw_distance or 60.0

    for m_index = 1, #m_locations do
        local m_entry = m_locations[m_index]
        local m_distance = BennyCserviceMarkers.GetHorizontalDistance(m_entry.m_location)

        if m_distance <= m_draw_distance then
            if not m_nearest_distance or m_distance < m_nearest_distance then
                m_nearest = m_entry
                m_nearest_distance = m_distance
            end
        end
    end

    if m_nearest and m_nearest_distance and m_nearest_distance <= m_interact_distance then
        return m_nearest, m_nearest_distance
    end

    return nil, m_nearest_distance
end

function BennyCserviceTasks.ClearGuidance()
    if IsWaypointActive() then
        SetWaypointOff()
    end
end

function BennyCserviceTasks.DrawLoop(m_active)
    CreateThread(function()
        local m_last_prompt_key = nil
        local m_last_waypoint_key = nil
        local m_last_available_count = nil

        while m_active() do
            local m_marker_cfg = Config.m_markers or {}
            local m_draw_distance = m_marker_cfg.m_draw_distance or 60.0
            local m_locations = BennyCserviceTasks.GetActiveLocations()
            local m_nearest = BennyCserviceTasks.GetNearest()
            local m_guidance = m_marker_cfg.m_waypoint ~= false

            if m_last_available_count == 0 and #m_locations > 0 then
                m_last_waypoint_key = nil
                BennyCserviceDebug.Print(('spots available again (%s active)'):format(#m_locations))
            end

            m_last_available_count = #m_locations

            if m_guidance and #m_locations > 0 then
                local m_target = BennyCserviceTasks.GetNearestSpot()
                local m_waypoint_key = m_target and ('%s:%s'):format(m_target.m_task_id, m_target.m_index) or nil

                if m_waypoint_key and m_last_waypoint_key ~= m_waypoint_key then
                    SetNewWaypoint(m_target.m_location.x, m_target.m_location.y)
                    m_last_waypoint_key = m_waypoint_key
                    BennyCserviceDebug.Print(('waypoint set to %s spot %s'):format(m_target.m_task_id, m_target.m_index))
                end
            elseif m_guidance and m_last_waypoint_key then
                BennyCserviceTasks.ClearGuidance()
                m_last_waypoint_key = nil
            end

            for m_index = 1, #m_locations do
                local m_entry = m_locations[m_index]
                local m_distance = BennyCserviceMarkers.GetHorizontalDistance(m_entry.m_location)

                if m_distance <= m_draw_distance then
                    BennyCserviceMarkers.Draw(m_entry.m_location, m_marker_cfg)
                end
            end

            if m_nearest and not BennyCserviceTasks.IsBusy() then
                local m_key = m_nearest.m_cfg.m_key or 38
                local m_label = Config.GetLocale(mGetLocaleKey(m_nearest.m_task_id))
                local m_prompt_key = ('%s:%s'):format(m_nearest.m_task_id, m_nearest.m_index)

                if m_last_prompt_key ~= m_prompt_key then
                    BennyCserviceTextUi.Show({
                        m_label = m_label,
                        m_key = Config.m_text_ui and Config.m_text_ui.m_key or 'E',
                        m_icon = m_nearest.m_cfg.m_icon or 'hand',
                    })
                    m_last_prompt_key = m_prompt_key
                end

                if BennyCserviceTextUi.GetProvider() == 'native' then
                    BennyCserviceTextUi.DrawNative(m_label, Config.m_text_ui and Config.m_text_ui.m_key or 'E')
                end

                if IsControlJustReleased(0, m_key) then
                    BennyCserviceTasks.Perform(
                        m_nearest.m_task_id,
                        m_nearest.m_index,
                        m_nearest.m_cfg,
                        m_nearest.m_location
                    )
                    m_last_prompt_key = nil
                end
            else
                if m_last_prompt_key then
                    BennyCserviceTextUi.Hide()
                    m_last_prompt_key = nil
                end
            end

            Wait(0)
        end

        BennyCserviceTextUi.Hide()
        BennyCserviceTasks.ClearGuidance()
    end)
end
