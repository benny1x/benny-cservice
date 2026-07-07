BennyCserviceZone = BennyCserviceZone or {}

local m_running = false
local m_last_violation = 0
local m_override = nil

function BennyCserviceZone.SetConfig(m_cfg)
    m_override = m_cfg
end

function BennyCserviceZone.ClearConfig()
    m_override = nil
end

local function mGetZoneConfig()
    if m_override then
        return m_override
    end

    return Config.m_zone or {}
end

function BennyCserviceZone.IsInside(m_coords)
    local m_cfg = mGetZoneConfig()

    if not m_cfg.m_center then
        return true
    end

    return #(m_coords - m_cfg.m_center) <= (m_cfg.m_radius or 85.0)
end

function BennyCserviceZone.GetReturnCoords()
    local m_cfg = mGetZoneConfig()
    local m_center = m_cfg.m_center or vec3(3680.0, 4968.0, 16.0)
    local m_height = m_cfg.m_teleport_height or Config.m_zone and Config.m_zone.m_teleport_height or 0.5

    return vec3(m_center.x, m_center.y, m_center.z + m_height)
end

function BennyCserviceZone.ForceBack()
    local m_ped = PlayerPedId()
    local m_coords = BennyCserviceZone.GetReturnCoords()

    if IsPedInAnyVehicle(m_ped, false) then
        local m_vehicle = GetVehiclePedIsIn(m_ped, false)
        SetEntityCoords(m_vehicle, m_coords.x, m_coords.y, m_coords.z, false, false, false, false)
        SetEntityHeading(m_vehicle, 0.0)
    else
        SetEntityCoords(m_ped, m_coords.x, m_coords.y, m_coords.z, false, false, false, false)
    end

    ClearPedTasksImmediately(m_ped)
end

function BennyCserviceZone.ApplyRestrictions()
    local m_cfg = mGetZoneConfig()
    local m_ped = PlayerPedId()

    if m_cfg.m_disable_weapons ~= false and (Config.m_zone and Config.m_zone.m_disable_weapons) then
        DisablePlayerFiring(PlayerId(), true)
        SetCurrentPedWeapon(m_ped, `WEAPON_UNARMED`, true)
    end

    if m_cfg.m_disable_vehicle ~= false and (Config.m_zone and Config.m_zone.m_disable_vehicle) then
        if IsPedInAnyVehicle(m_ped, false) then
            TaskLeaveVehicle(m_ped, GetVehiclePedIsIn(m_ped, false), 16)
        end
    end
end

function BennyCserviceZone.Start(m_zone)
    if m_zone then
        BennyCserviceZone.SetConfig(m_zone)
    end

    if m_running then
        return
    end

    m_running = true
    BennyCserviceDebug.Print('anti-leave zone started')

    CreateThread(function()
        while m_running do
            local m_cfg = mGetZoneConfig()
            local m_ped = PlayerPedId()
            local m_coords = GetEntityCoords(m_ped)

            BennyCserviceZone.ApplyRestrictions()

            if not BennyCserviceZone.IsInside(m_coords) then
                local m_now = GetGameTimer()

                if m_now - m_last_violation > 2500 then
                    m_last_violation = m_now
                    TriggerServerEvent('benny-cservice:server:zone_violation')
                end

                BennyCserviceZone.ForceBack()
            end

            Wait(m_cfg.m_check_interval or Config.m_zone and Config.m_zone.m_check_interval or 1000)
        end
    end)
end

function BennyCserviceZone.Stop()
    m_running = false
    BennyCserviceZone.ClearConfig()
    BennyCserviceDebug.Print('anti-leave zone stopped')
end

RegisterNetEvent('benny-cservice:client:force_back', function()
    BennyCserviceZone.ForceBack()
end)
