Units = {}

local unitsTable = {}
local callsigns = {}

local function defaultCallsign(src)
    return string.format('%s-%d', Config.Callsign.Prefix, src)
end

local function buildUnit(src)
    local job = Framework.GetJob(src)
    if not job then return nil end

    local jobCfg = Config.Jobs[job.name]
    if not jobCfg or not jobCfg.enabled then return nil end

    local ped = GetPlayerPed(src)
    local coords = { x = 0.0, y = 0.0, z = 0.0 }
    if ped and ped ~= 0 then
        local ok, c = pcall(GetEntityCoords, ped)
        if ok and c then coords = { x = c.x, y = c.y, z = c.z } end
    end

    local existing = unitsTable[src]

    return {
        id = src,
        callsign = callsigns[src] or defaultCallsign(src),
        name = Framework.GetPlayerName(src),
        job = job.name,
        jobLabel = jobCfg.label,
        department = jobCfg.type or 'other',
        grade = job.grade,
        gradeLabel = Framework.GetGradeLabel(job.name, job.grade, job.gradeLabel),
        status = existing and existing.status or 'available',
        currentCall = existing and existing.currentCall or nil,
        coords = coords,
        lastUpdate = os.time(),
    }
end

function Units.Refresh(src)
    local unit = buildUnit(src)
    if unit then
        unitsTable[src] = unit
    else
        unitsTable[src] = nil
    end
    return unit
end

function Units.RefreshCoordsOnly(src)
    local unit = unitsTable[src]
    if not unit then return end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end
    local ok, c = pcall(GetEntityCoords, ped)
    if ok and c then
        unit.coords = { x = c.x, y = c.y, z = c.z }
        unit.lastUpdate = os.time()
    end
end

function Units.Remove(src)
    unitsTable[src] = nil
    callsigns[src] = nil
end

function Units.Get(src)
    return unitsTable[src]
end

function Units.GetAll()
    local list = {}
    for _, unit in pairs(unitsTable) do
        list[#list + 1] = unit
    end
    table.sort(list, function(a, b) return a.callsign < b.callsign end)
    return list
end

function Units.SetStatus(src, status)
    local unit = unitsTable[src]
    if not unit then return false end

    local valid = false
    for _, s in ipairs(Config.UnitStatuses) do
        if s.id == status then valid = true break end
    end
    if not valid then return false end

    unit.status = status
    unit.lastUpdate = os.time()
    return true
end

function Units.SetCurrentCall(src, callId)
    local unit = unitsTable[src]
    if unit then unit.currentCall = callId end
end

function Units.SetCallsign(src, callsign)
    callsign = Utils.Trim(callsign or '')
    if callsign == '' or #callsign > (Config.Callsign.MaxLength or 8) then
        return false, 'callsign_invalid'
    end

    for existingSrc, existingCallsign in pairs(callsigns) do
        if existingSrc ~= src and existingCallsign:lower() == callsign:lower() then
            return false, 'callsign_taken'
        end
    end

    callsigns[src] = callsign
    if unitsTable[src] then unitsTable[src].callsign = callsign end
    return true
end

function Units.IsEligible(src, jobsFilter)
    local unit = unitsTable[src]
    if not unit then return false end
    if not jobsFilter or #jobsFilter == 0 then return true end
    return Utils.TableContains(jobsFilter, unit.job)
end

function Units.CountAvailable()
    local count = 0
    for _, unit in pairs(unitsTable) do
        if unit.status == 'available' then count = count + 1 end
    end
    return count
end

function Units.CountOnline()
    local count = 0
    for _ in pairs(unitsTable) do count = count + 1 end
    return count
end

function Units.Broadcast()
    local payload = Units.GetAll()
    for _, src in ipairs(Framework.GetOnlinePlayers()) do
        if Permissions.IsAuthorized(src) then
            TriggerClientEvent(Constants.Events.UpdateUnits, src, payload)
        end
    end
end
