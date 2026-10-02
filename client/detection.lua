local lastTrigger = {
    gunshots = 0,
    vehicletheft = 0,
    vehiclecrash = 0,
    assault = 0,
    pursuit = 0,
}

local localIsUnit = false
RegisterNetEvent(Constants.Events.SyncMeta, function(meta)
    localIsUnit = meta.authorized == true
end)

local function cooldownOk(key)
    if Config.IgnoreUnitsInAutoDispatch and localIsUnit then return false end
    local cooldown = (Config.AutomaticDispatchCooldowns[({
        gunshots = 'Gunshots', vehicletheft = 'VehicleTheft', vehiclecrash = 'VehicleCrash',
        assault = 'Assault', pursuit = 'Pursuit',
    })[key]]) or 60
    local now = GetGameTimer() / 1000.0
    if (now - lastTrigger[key]) < cooldown then return false end
    lastTrigger[key] = now
    return true
end

local function send(key, coords)
    TriggerServerEvent(Constants.Events.AutoDispatch, key, Utils.VecToTable(coords))
end

if Config.AutomaticDispatch.Gunshots then
    CreateThread(function()
        while true do
            Wait(400)
            local ped = PlayerPedId()
            local _, weapon = GetCurrentPedWeapon(ped, true)
            if weapon and weapon ~= GetHashKey('WEAPON_UNARMED') and IsPedShooting(ped) and not IsPedInAnyVehicle(ped, false) then
                local silenced = HasPedGotWeaponComponent and HasPedGotWeaponComponent(ped, weapon, GetHashKey('COMPONENT_AT_AR_SUPP_02'))
                if not (Config.AutomaticSettings.GunshotsIgnoreSilenced and silenced) then
                    if cooldownOk('gunshots') then
                        send('gunshots', GetEntityCoords(ped))
                    end
                end
            end
        end
    end)
end

if Config.AutomaticDispatch.VehicleTheft then
    CreateThread(function()
        while true do
            Wait(500)
            local ped = PlayerPedId()
            if IsPedJacking(ped) then
                if cooldownOk('vehicletheft') then
                    send('vehicletheft', GetEntityCoords(ped))
                end
            end
        end
    end)
end

if Config.AutomaticDispatch.VehicleCrash then
    CreateThread(function()
        local lastHealth, lastSpeed = nil, 0.0
        while true do
            Wait(500)
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                local health = GetVehicleBodyHealth(veh)
                local speed = GetEntitySpeed(veh) * 2.236936

                if lastHealth then
                    local healthDrop = lastHealth - health
                    local speedDrop = lastSpeed - speed
                    if healthDrop >= (Config.AutomaticSettings.CrashMinBodyDamage or 120.0)
                        and speedDrop >= (Config.AutomaticSettings.CrashMinSpeedDropMph or 25.0) then
                        if cooldownOk('vehiclecrash') then
                            send('vehiclecrash', GetEntityCoords(ped))
                        end
                    end
                end

                lastHealth, lastSpeed = health, speed
            else
                lastHealth, lastSpeed = nil, 0.0
            end
        end
    end)
end

if Config.AutomaticDispatch.Pursuit then
    CreateThread(function()
        while true do
            Wait(2000)
            local ped = PlayerPedId()
            local wanted = GetPlayerWantedLevel(PlayerId())
            if wanted > 0 then
                local speed = 0.0
                if IsPedInAnyVehicle(ped, false) then
                    speed = GetEntitySpeed(GetVehiclePedIsIn(ped, false)) * 2.236936
                end
                if speed >= (Config.AutomaticSettings.PursuitMinSpeedMph or 55.0) then
                    if cooldownOk('pursuit') then
                        send('pursuit', GetEntityCoords(ped))
                    end
                end
            end
        end
    end)
end

if Config.AutomaticDispatch.Assault then
    CreateThread(function()
        while true do
            Wait(500)
            local ped = PlayerPedId()
            if IsPedInMeleeCombat(ped) then
                if cooldownOk('assault') then
                    send('assault', GetEntityCoords(ped))
                end
            end
        end
    end)
end
