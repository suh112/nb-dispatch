local panicCooldowns = {}
local citizen911Cooldowns = {}
local unitDownCooldowns = {}

local function rateOk(src, action)
    local limits = Config.RateLimits[action] or Config.RateLimits.default
    return Utils.CheckRate(src .. ':' .. action, limits[1], limits[2])
end

local function notify(src, key, type_)
    TriggerClientEvent(Constants.Events.Notify, src, Config.Lang[key] or key, type_ or 'error')
end

local function guard(src, action)
    if not rateOk(src, action) then
        notify(src, 'rate_limited')
        return false
    end
    if not Permissions.HasPermission(src, action) then
        notify(src, Permissions.IsAuthorized(src) and 'no_permission' or 'not_authorized')
        return false
    end
    return true
end

CreateThread(function()
    Database.Init()
end)

AddEventHandler('playerJoining', function()
    local src = source
    SetTimeout(2000, function()
        if GetPlayerPing(src) then
            Units.Refresh(src)
        end
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    Units.Remove(src)
    panicCooldowns[src] = nil
    citizen911Cooldowns[src] = nil
    unitDownCooldowns[src] = nil
    Units.Broadcast()
end)

CreateThread(function()
    while true do
        Wait((Config.UnitUpdateInterval or 5) * 1000)
        for _, src in ipairs(Framework.GetOnlinePlayers()) do
            Units.Refresh(src)
        end
        Units.Broadcast()
    end
end)

CreateThread(function()
    while true do
        Wait(30000)
        Calls.ExpireStale()
    end
end)

RegisterNetEvent(Constants.Events.RequestSync, function()
    local src = source
    if not rateOk(src, 'requestSync') then return end

    Units.Refresh(src)

    if not Permissions.IsAuthorized(src) then
        TriggerClientEvent(Constants.Events.SyncMeta, src, { authorized = false })
        return
    end

    local unit = Units.Get(src)
    TriggerClientEvent(Constants.Events.SyncMeta, src, {
        authorized = true,
        permissionLevel = Permissions.GetLevel(src),
        permissionName = Permissions.LevelName(Permissions.GetLevel(src)),
        officer = unit,
        jobs = Config.Jobs,
        statuses = Config.UnitStatuses,
        callTypes = Config.CallTypes,
        actionPermissions = Config.ActionPermissions,
    })
    Calls.SyncToPlayer(src)
    TriggerClientEvent(Constants.Events.UpdateUnits, src, Units.GetAll())
end)

RegisterNetEvent(Constants.Events.CreateCall, function(data)
    local src = source
    if not guard(src, 'createCall') then return end
    if type(data) ~= 'table' then notify(src, 'invalid_data') return end

    local unit = Units.Get(src)
    local call, err = Calls.Create({
        type = data.type,
        title = data.title,
        description = data.description,
        priority = data.priority,
        coords = (Permissions.HasPermission(src, 'createCallAt') and data.coords) or (unit and unit.coords),
        jobs = data.jobs,
    }, { caller = unit and unit.callsign or 'Dispatcher', source = 'player' })

    if not call then
        notify(src, err or 'internal_error')
        return
    end

    notify(src, 'call_created', 'success')
end)

RegisterNetEvent(Constants.Events.AcceptCall, function(callId)
    local src = source
    if not guard(src, 'accept') then return end
    local ok, err = Calls.Accept(callId, src)
    if ok then
        notify(src, 'call_accepted', 'success')
    else
        notify(src, err)
    end
end)

RegisterNetEvent(Constants.Events.AssignCall, function(callId, targetSrc)
    local src = source
    targetSrc = tonumber(targetSrc)
    if not targetSrc then notify(src, 'invalid_data') return end

    local action = (targetSrc == src) and 'assignSelf' or 'assignOthers'
    if not guard(src, action) then return end

    local ok, err = Calls.Assign(callId, targetSrc)
    if ok then
        notify(src, 'call_assigned', 'success')
    else
        notify(src, err)
    end
end)

RegisterNetEvent(Constants.Events.UnassignCall, function(callId, targetSrc)
    local src = source
    targetSrc = tonumber(targetSrc)
    if not targetSrc then notify(src, 'invalid_data') return end

    local action = (targetSrc == src) and 'assignSelf' or 'unassignOthers'
    if not guard(src, action) then return end

    local ok, err = Calls.Unassign(callId, targetSrc)
    if ok then
        notify(src, 'call_unassigned', 'success')
    else
        notify(src, err)
    end
end)

RegisterNetEvent(Constants.Events.AddNote, function(callId, message)
    local src = source
    if not guard(src, 'addNote') then return end
    local ok, err = Calls.AddNote(callId, src, message)
    if ok then
        notify(src, 'note_added', 'success')
    else
        notify(src, err)
    end
end)

RegisterNetEvent(Constants.Events.CloseCall, function(callId)
    local src = source

    local call = Calls.Get(callId)
    if not call then notify(src, 'call_not_found') return end

    local isAssigned = Config.AllowAssignedUnitsToClose and Utils.TableContains(
        (function()
            local ids = {}
            for _, u in ipairs(call.assignedUnits) do ids[#ids + 1] = u.id end
            return ids
        end)(), src)

    if not isAssigned and not guard(src, 'close') then return end
    if not rateOk(src, 'default') then notify(src, 'rate_limited') return end

    local ok, err = Calls.Close(callId, src)
    if ok then
        notify(src, 'call_closed', 'success')
    else
        notify(src, err)
    end
end)

RegisterNetEvent(Constants.Events.UpdateUnitStatus, function(status)
    local src = source
    if not guard(src, 'setStatus') then return end
    if Units.SetStatus(src, status) then
        Units.Broadcast()
        notify(src, 'status_updated', 'success')
    else
        notify(src, 'invalid_data')
    end
end)

local function doSetCallsign(src, callsign)
    if not rateOk(src, 'setCallsign') then notify(src, 'rate_limited') return end
    if not Permissions.IsAuthorized(src) then notify(src, 'not_authorized') return end
    if not Config.Callsign.AllowSelfSet then notify(src, 'disabled') return end

    local ok, err = Units.SetCallsign(src, callsign)
    if ok then
        Units.Refresh(src)
        Units.Broadcast()
        notify(src, 'callsign_set', 'success')
    else
        notify(src, err)
    end
end

RegisterNetEvent(Constants.Events.SetCallsign, function(callsign)
    doSetCallsign(source, callsign)
end)

local function doPanic(src)
    local unit = Units.Get(src)
    if not unit then return false, 'not_authorized' end

    local jobCfg = Config.Jobs[unit.job]
    local allowedJobType = jobCfg and jobCfg.type == 'police'
    if Config.PanicJobs then
        allowedJobType = Utils.TableContains(Config.PanicJobs, unit.job)
    end
    if not allowedJobType then return false, 'not_authorized' end

    local now = os.time()
    if panicCooldowns[src] and (now - panicCooldowns[src]) < (Config.PanicCooldown or 10) then
        return false, 'panic_cooldown'
    end
    panicCooldowns[src] = now

    local call = Calls.Create({
        type = 'officer_panic',
        description = string.format('%s (%s) has triggered a panic alert.', unit.callsign, unit.name),
        coords = unit.coords,
        jobs = { unit.job },
    }, { caller = unit.callsign, source = 'panic' })

    for _, dst in ipairs(Framework.GetOnlinePlayers()) do
        local u = Units.Get(dst)
        if u and u.job == unit.job then
            TriggerClientEvent(Constants.Events.Panic_C, dst, {
                source = src,
                callsign = unit.callsign,
                name = unit.name,
                department = unit.department,
                coords = unit.coords,
                callId = call and call.id,
            })
        end
    end

    return true
end

RegisterNetEvent(Constants.Events.Panic, function()
    local src = source
    if not rateOk(src, 'panic') then notify(src, 'rate_limited') return end

    local ok, err = doPanic(src)
    if ok then
        notify(src, 'panic_sent', 'success')
    else
        notify(src, err)
    end
end)

local function doUnitDown(src, coords)
    if not Config.UnitDownAlert or not Config.UnitDownAlert.Enabled then return end

    local unit = Units.Get(src)
    if not unit then return end

    local now = os.time()
    if unitDownCooldowns[src] and (now - unitDownCooldowns[src]) < (Config.UnitDownAlert.Cooldown or 15) then
        return
    end
    unitDownCooldowns[src] = now

    local callCoords = (type(coords) == 'table' and type(coords.x) == 'number') and coords or unit.coords

    local call = Calls.Create({
        type = 'officer_down',
        description = string.format('%s (%s) is down and needs immediate assistance.', unit.callsign, unit.name),
        coords = callCoords,
        jobs = { unit.job },
    }, { caller = unit.callsign, source = 'unitdown' })

    for _, dst in ipairs(Framework.GetOnlinePlayers()) do
        local u = Units.Get(dst)
        if u and u.job == unit.job then
            TriggerClientEvent(Constants.Events.UnitDown_C, dst, {
                source = src,
                callsign = unit.callsign,
                name = unit.name,
                department = unit.department,
                coords = callCoords,
                callId = call and call.id,
            })
        end
    end
end

RegisterNetEvent(Constants.Events.UnitDown, function(coords)
    local src = source
    if not rateOk(src, 'default') then return end
    doUnitDown(src, coords)
end)

RegisterCommand(Config.PanicCommand, function(src)
    if src == 0 then return end
    doPanic(src)
end, false)

local function doCitizen911(src, message, coords)
    if not Config.Citizen911.Enabled then return end
    if type(coords) ~= 'table' or type(coords.x) ~= 'number' then return end

    local now = os.time()
    local last = citizen911Cooldowns[src]
    if last and (now - last) < (Config.Citizen911.Cooldown or 60) then
        notify(src, 'call_911_cooldown')
        return
    end
    citizen911Cooldowns[src] = now

    Calls.Create({
        type = 'citizen_911',
        description = tostring(message or 'No details provided.'):sub(1, 280),
        coords = coords,
        caller = Framework.GetPlayerName(src),
    }, { caller = Framework.GetPlayerName(src), source = 'citizen' })

    notify(src, 'call_911_sent', 'success')
end

RegisterNetEvent(Constants.Events.Citizen911, function(message, coords)
    doCitizen911(source, message, coords)
end)

RegisterCommand(Config.Citizen911.Command, function(src, args)
    if src == 0 then return end
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    doCitizen911(src, table.concat(args, ' '), Utils.VecToTable(coords))
end, false)

local autoDispatchTypeMap = {
    gunshots = 'shots_fired',
    vehicletheft = 'vehicle_theft',
    vehiclecrash = 'vehicle_accident',
    assault = 'assault',
    pursuit = 'pursuit',
}

RegisterNetEvent(Constants.Events.AutoDispatch, function(kind, coords)
    local src = source
    if not rateOk(src, 'default') then return end
    if type(coords) ~= 'table' or type(coords.x) ~= 'number' then return end

    local enabledKey = ({
        gunshots = 'Gunshots', vehicletheft = 'VehicleTheft', vehiclecrash = 'VehicleCrash',
        assault = 'Assault', pursuit = 'Pursuit',
    })[kind]
    if not enabledKey or not Config.AutomaticDispatch[enabledKey] then return end

    local callType = autoDispatchTypeMap[kind]
    if not callType then return end

    for _, c in pairs(Calls.GetAllActive()) do
        if c.source == 'automatic' and c.code == (Config.CallTypes[callType] and Config.CallTypes[callType].code) then
            if Utils.Distance(c.coords, coords) <= (Config.AutomaticAreaRadius or 120.0) then
                return
            end
        end
    end

    Calls.Create({
        type = callType,
        coords = coords,
        caller = 'Automatic System',
    }, { caller = 'Automatic System', source = 'automatic' })
end)

RegisterNetEvent(Constants.Events.PursuitFlag, function(coords)
    local src = source
    if not guard(src, 'createCall') then return end
    if type(coords) ~= 'table' then return end

    Calls.Create({
        type = 'pursuit',
        coords = coords,
        description = 'Pursuit flagged by a unit in progress.',
    }, { caller = (Units.Get(src) and Units.Get(src).callsign) or 'Unit', source = 'player' })
end)

RegisterCommand(Config.CallsignCommand, function(src, args)
    if src == 0 then return end
    doSetCallsign(src, table.concat(args, ' '))
end, false)

exports('CreateCall', function(data)
    return Calls.Create(data or {}, { caller = (data and data.caller) or 'Resource', source = 'resource' })
end)

exports('GetActiveCalls', function()
    return Calls.GetAllActive()
end)

exports('GetUnits', function()
    return Units.GetAll()
end)
