Calls = {}

local calls = {}
local history = {}
local callCountActive = 0

local function trimHistory()
    while #history > (Config.HistoryLimit or 100) do
        table.remove(history, 1)
    end
end

local function countActive()
    local n = 0
    for _, c in pairs(calls) do
        if c.status ~= 'closed' then n = n + 1 end
    end
    return n
end

function Calls.Get(id)
    return calls[id]
end

function Calls.GetAllActive()
    local list = {}
    for _, c in pairs(calls) do
        if c.status ~= 'closed' then list[#list + 1] = c end
    end
    table.sort(list, function(a, b)
        if a.priority ~= b.priority then return a.priority < b.priority end
        return a.createdAt < b.createdAt
    end)
    return list
end

function Calls.GetHistory()
    return history
end

function Calls.GetVisibleFor(src)
    local unit = Units.Get(src)
    if not unit then return {} end

    local list = {}
    for _, c in pairs(calls) do
        if c.status ~= 'closed' and Utils.TableContains(c.jobs, unit.job) then
            list[#list + 1] = c
        end
    end
    table.sort(list, function(a, b)
        if a.priority ~= b.priority then return a.priority < b.priority end
        return a.createdAt < b.createdAt
    end)
    return list
end

function Calls.SyncToPlayer(src)
    if not Permissions.IsAuthorized(src) then return end
    TriggerClientEvent(Constants.Events.UpdateCalls, src, Calls.GetVisibleFor(src))
end

function Calls.SyncAll()
    for _, src in ipairs(Framework.GetOnlinePlayers()) do
        Calls.SyncToPlayer(src)
    end
end

local function notifyNewCall(call)
    for _, src in ipairs(Framework.GetOnlinePlayers()) do
        local unit = Units.Get(src)
        if unit and Utils.TableContains(call.jobs, unit.job) then
            TriggerClientEvent(Constants.Events.NewCall, src, call)
        end
    end
end

function Calls.Create(data, meta)
    data = data or {}
    meta = meta or {}

    if countActive() >= (Config.MaxActiveCalls or 100) then
        return nil, 'max_calls'
    end

    local typeCfg = data.type and Config.CallTypes[data.type] or nil
    local now = os.time()
    local id = Utils.GenerateId('C')

    local coords = data.coords or (typeCfg and typeCfg.coords) or { x = 0.0, y = 0.0, z = 0.0 }

    local call = {
        id = id,
        code = data.code or (typeCfg and typeCfg.code) or 'N/A',
        title = data.title or (typeCfg and typeCfg.title) or 'Dispatch Call',
        description = data.description or '',
        priority = tonumber(data.priority) or (typeCfg and typeCfg.priority) or 3,
        coords = coords,
        postal = data.postal or Utils.GetPostal(coords),
        street = data.street or '',
        caller = data.caller or meta.caller or 'Unknown',
        callerPhone = data.callerPhone or '',
        createdAt = now,
        expiresAt = now + (tonumber(data.expiration) or Config.CallExpiration or 600),
        status = 'pending',
        assignedUnits = {},
        notes = {},
        blip = data.blip or (typeCfg and typeCfg.blip) or nil,
        jobs = data.jobs or (typeCfg and typeCfg.jobs) or Config.DefaultJobs,
        department = data.department or (typeCfg and typeCfg.department) or nil,
        source = meta.source,
    }

    if call.priority < 1 then call.priority = 1 end
    if call.priority > 4 then call.priority = 4 end

    calls[id] = call
    Database.InsertCall(call)
    Calls.SyncAll()
    notifyNewCall(call)

    return call
end

function Calls.Accept(id, src)
    local call = calls[id]
    if not call then return false, 'call_not_found' end
    local unit = Units.Get(src)
    if not unit or not Utils.TableContains(call.jobs, unit.job) then
        return false, 'not_authorized'
    end

    if call.status == 'pending' then
        call.status = 'active'
    end

    Database.UpdateCall(call)
    Calls.SyncAll()
    return true, call
end

local function addAssignedUnit(call, src)
    for _, u in ipairs(call.assignedUnits) do
        if u.id == src then return false end
    end
    local unit = Units.Get(src)
    if not unit then return false end
    table.insert(call.assignedUnits, {
        id = unit.id,
        callsign = unit.callsign,
        name = unit.name,
        job = unit.job,
    })
    return true
end

function Calls.Assign(id, targetSrc, byCall)
    local call = calls[id]
    if not call then return false, 'call_not_found' end
    local unit = Units.Get(targetSrc)
    if not unit or not Utils.TableContains(call.jobs, unit.job) then
        return false, 'unit_not_found'
    end

    if call.status == 'pending' then call.status = 'active' end
    addAssignedUnit(call, targetSrc)
    Units.SetCurrentCall(targetSrc, id)
    Database.UpdateCall(call)
    Database.InsertUnitHistory(unit, id, 'assigned')
    Calls.SyncAll()
    Units.Broadcast()
    return true, call
end

function Calls.Unassign(id, targetSrc)
    local call = calls[id]
    if not call then return false, 'call_not_found' end

    for i, u in ipairs(call.assignedUnits) do
        if u.id == targetSrc then
            table.remove(call.assignedUnits, i)
            break
        end
    end

    local unit = Units.Get(targetSrc)
    if unit and unit.currentCall == id then
        Units.SetCurrentCall(targetSrc, nil)
    end

    Database.UpdateCall(call)
    Calls.SyncAll()
    Units.Broadcast()
    return true, call
end

function Calls.AddNote(id, src, message)
    local call = calls[id]
    if not call then return false, 'call_not_found' end
    message = Utils.Trim(message or '')
    if message == '' or #message > 280 then return false, 'invalid_data' end

    local unit = Units.Get(src)
    local note = {
        id = Utils.GenerateId('N'),
        author = unit and unit.callsign or Framework.GetPlayerName(src),
        authorSource = src,
        message = message,
        createdAt = os.time(),
    }

    table.insert(call.notes, note)
    Database.InsertNote(id, note)
    Database.UpdateCall(call)
    Calls.SyncAll()
    return true, call
end

function Calls.Close(id, src)
    local call = calls[id]
    if not call then return false, 'call_not_found' end

    call.status = 'closed'
    call.closedAt = os.time()
    call.closedBy = src and (Units.Get(src) and Units.Get(src).callsign or Framework.GetPlayerName(src)) or 'System'

    for _, u in ipairs(call.assignedUnits) do
        local unit = Units.Get(u.id)
        if unit and unit.currentCall == id then
            Units.SetCurrentCall(u.id, nil)
        end
    end

    table.insert(history, call)
    trimHistory()
    calls[id] = nil

    Database.UpdateCall(call)
    Calls.SyncAll()
    Units.Broadcast()
    return true, call
end

function Calls.ExpireStale()
    local now = os.time()
    local toClose = {}
    for id, call in pairs(calls) do
        if call.status ~= 'closed' and #call.assignedUnits == 0 and now >= call.expiresAt then
            toClose[#toClose + 1] = id
        end
    end
    for _, id in ipairs(toClose) do
        Calls.Close(id, nil)
    end
end
