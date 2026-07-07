local m_active = false
local m_tasks_remaining = 0
local m_total_tasks = 0
local m_task_type = nil

local function mIsActive()
    return m_active
end

local function mTeleportToRelease(m_coords)
    if not m_coords then
        return
    end

    local m_ped = PlayerPedId()

    if IsPedInAnyVehicle(m_ped, false) then
        local m_vehicle = GetVehiclePedIsIn(m_ped, false)
        SetEntityCoords(m_vehicle, m_coords.x, m_coords.y, m_coords.z, false, false, false, false)
        SetEntityHeading(m_vehicle, m_coords.w or 0.0)
    else
        SetEntityCoords(m_ped, m_coords.x, m_coords.y, m_coords.z, false, false, false, false)
        SetEntityHeading(m_ped, m_coords.w or 0.0)
    end
end

local function mGetTaskZone(m_task_type)
    local m_zone = Config.GetTaskZone(m_task_type)
    local m_base = Config.m_zone or {}

    return {
        m_center = m_zone.m_center,
        m_radius = m_zone.m_radius,
        m_teleport_height = m_zone.m_teleport_height or m_base.m_teleport_height or 0.5,
        m_check_interval = m_zone.m_check_interval or m_base.m_check_interval or 1000,
        m_disable_weapons = m_base.m_disable_weapons,
        m_disable_vehicle = m_base.m_disable_vehicle,
    }
end

local function mTeleportToZone(m_task_type)
    local m_zone = mGetTaskZone(m_task_type)

    if not m_zone or not m_zone.m_center then
        return
    end

    local m_ped = PlayerPedId()
    SetEntityCoords(
        m_ped,
        m_zone.m_center.x,
        m_zone.m_center.y,
        m_zone.m_center.z + (m_zone.m_teleport_height or 0.5),
        false,
        false,
        false,
        false
    )
end

local function mApplyTaskState(m_data)
    m_task_type = m_data.m_task_type or m_task_type or 'm_sweep'
    BennyCserviceTasks.SetTaskType(m_task_type)
end

local function mStartComserv(m_data)
    m_active = true
    m_tasks_remaining = m_data.m_tasks_remaining or 0
    m_total_tasks = m_data.m_total_tasks or m_tasks_remaining
    mApplyTaskState(m_data)

    BennyCserviceTasks.ResetCompleted()

    local m_zone = mGetTaskZone(m_task_type)

    CreateThread(function()
        BennyCserviceMarkers.PreloadTaskLocations(m_task_type)
        mTeleportToZone(m_task_type)

        local m_task_cfg = Config.m_tasks and Config.m_tasks[m_task_type]
        local m_locations = m_task_cfg and m_task_cfg.m_locations or {}

        for m_index = 1, #m_locations do
            local m_location = m_locations[m_index]
            RequestCollisionAtCoord(m_location.x, m_location.y, m_location.z)
            Wait(0)
        end

        Wait(250)
        BennyCserviceMarkers.PreloadTaskLocations(m_task_type)
        BennyCserviceZone.Start(m_zone)
        BennyCserviceTasks.DrawLoop(mIsActive)
        BennyCserviceHud.Show(m_tasks_remaining, m_total_tasks)
        BennyCserviceDebug.Print(('comserv started (%s tasks, %s, %s spots)'):format(m_tasks_remaining, m_task_type, #m_locations))
    end)
end

local function mStopComserv(m_release_coords)
    m_active = false
    m_tasks_remaining = 0
    m_total_tasks = 0
    m_task_type = nil

    BennyCserviceZone.Stop()
    BennyCserviceTextUi.Hide()
    BennyCserviceHud.Hide()
    BennyCserviceTasks.ClearGuidance()
    BennyCserviceTasks.ResetCompleted()
    BennyCserviceTasks.SetTaskType(nil)
    BennyCserviceMarkers.ClearCache()

    if m_release_coords then
        mTeleportToRelease(m_release_coords)
    end

    BennyCserviceDebug.Print('comserv stopped')
end

RegisterNetEvent('benny-cservice:client:set_state', function(m_data)
    if not m_data or not m_data.m_active then
        return
    end

    m_tasks_remaining = m_data.m_tasks_remaining or m_tasks_remaining
    m_total_tasks = m_data.m_total_tasks or m_total_tasks

    if not m_active then
        mStartComserv(m_data)
        return
    end

    BennyCserviceHud.Update(m_tasks_remaining, m_total_tasks)
end)

RegisterNetEvent('benny-cservice:client:clear_state', function(m_release_coords)
    mStopComserv(m_release_coords)
end)

CreateThread(function()
    Wait(2000)
    TriggerServerEvent('benny-cservice:server:request_state')
    BennyCserviceDebug.Print('client main loaded')
end)

exports('IsInCommunityService', function()
    return m_active
end)

exports('GetTasksRemaining', function()
    return m_tasks_remaining
end)

exports('GetTaskType', function()
    return m_task_type
end)
