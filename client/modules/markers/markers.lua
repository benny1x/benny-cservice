BennyCserviceMarkers = BennyCserviceMarkers or {}

local m_ground_cache = {}

local function mGetGroundTolerance()
    local m_settings = Config.m_tasks_settings or {}
    return m_settings.m_ground_tolerance or 4.0
end

function BennyCserviceMarkers.ClearCache()
    m_ground_cache = {}
end

function BennyCserviceMarkers.PreloadTaskLocations(m_task_type)
    local m_task_cfg = Config.m_tasks and Config.m_tasks[m_task_type]

    if not m_task_cfg or not m_task_cfg.m_locations then
        return
    end

    BennyCserviceMarkers.ClearCache()

    for m_index = 1, #m_task_cfg.m_locations do
        local m_location = m_task_cfg.m_locations[m_index]
        RequestCollisionAtCoord(m_location.x, m_location.y, m_location.z)
        BennyCserviceMarkers.GetGroundZ(m_location.x, m_location.y, m_location.z, true)
    end

    BennyCserviceDebug.Print(('preloaded %s marker ground samples for %s'):format(#m_task_cfg.m_locations, m_task_type))
end

function BennyCserviceMarkers.GetGroundZ(m_x, m_y, m_z, m_force_sample)
    local m_key = ('%.1f:%.1f'):format(m_x, m_y)

    if not m_force_sample and m_ground_cache[m_key] then
        return m_ground_cache[m_key]
    end

    RequestCollisionAtCoord(m_x, m_y, m_z)

    local m_probe_z = m_z + 50.0
    local m_found, m_ground_z = GetGroundZFor_3dCoord(m_x, m_y, m_probe_z, false)

    if not m_found then
        m_found, m_ground_z = GetGroundZFor_3dCoord(m_x, m_y, m_probe_z, true)
    end

    if m_found then
        if math.abs(m_ground_z - m_z) > mGetGroundTolerance() then
            BennyCserviceDebug.Warn(('ground snap rejected at %.1f, %.1f (probe %.2f, hint %.2f)'):format(m_x, m_y, m_ground_z, m_z))
            m_ground_z = m_z
        end

        m_ground_cache[m_key] = m_ground_z
        return m_ground_z
    end

    m_ground_cache[m_key] = m_z
    return m_z
end

function BennyCserviceMarkers.ResolveZ(m_coords)
    local m_settings = Config.m_tasks_settings or {}

    if m_settings.m_ground_snap == false then
        return m_coords.z + (m_settings.m_ground_offset or 0.0)
    end

    return BennyCserviceMarkers.GetGroundZ(m_coords.x, m_coords.y, m_coords.z) + (m_settings.m_ground_offset or 0.0)
end

function BennyCserviceMarkers.GetHorizontalDistance(m_coords)
    local m_ped_coords = GetEntityCoords(PlayerPedId())
    return #(vec2(m_ped_coords.x, m_ped_coords.y) - vec2(m_coords.x, m_coords.y))
end

function BennyCserviceMarkers.Draw(m_coords, m_cfg)
    m_cfg = m_cfg or Config.m_markers or {}

    if not m_cfg.m_enabled then
        return
    end

    local m_z = BennyCserviceMarkers.ResolveZ(m_coords)
    local m_height = m_cfg.m_height or 0.35
    local m_scale = m_cfg.m_scale or vec3(0.4, 0.4, 0.4)
    local m_color = m_cfg.m_color or { r = 255, g = 140, b = 0, a = 200 }

    DrawMarker(
        m_cfg.m_type or 2,
        m_coords.x, m_coords.y, m_z + m_height,
        0.0, 0.0, 0.0,
        0.0, 180.0, 0.0,
        m_scale.x, m_scale.y, m_scale.z,
        m_color.r, m_color.g, m_color.b, m_color.a,
        m_cfg.m_bob == true,
        m_cfg.m_face_camera == true,
        2,
        m_cfg.m_rotate == true,
        nil,
        nil,
        false
    )
end

function BennyCserviceMarkers.GetDistance(m_coords)
    local m_z = BennyCserviceMarkers.ResolveZ(m_coords)
    return #(GetEntityCoords(PlayerPedId()) - vec3(m_coords.x, m_coords.y, m_z))
end

function BennyCserviceMarkers.IsNear(m_coords, m_distance)
    return BennyCserviceMarkers.GetDistance(m_coords) <= (m_distance or 1.8)
end
