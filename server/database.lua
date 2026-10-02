Database = {}

local function available()
    return Config.Database.Enabled
        and Config.Database.Driver == 'oxmysql'
        and GetResourceState('oxmysql') == 'started'
        and MySQL ~= nil
end

function Database.Init()
    if not available() then
        if Config.Database.Enabled then
            print('[nb-dispatch] Database.Enabled is true but oxmysql was not found - running without persistence')
        end
        return
    end

    MySQL.ready(function()
        Utils.Debug('oxmysql ready, dispatch persistence enabled')
    end)
end

function Database.InsertCall(call)
    if not available() then return end

    MySQL.insert(
        'INSERT INTO nb_dispatch_calls (call_id, code, title, description, priority, coords, postal, status, jobs, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, FROM_UNIXTIME(?))',
        {
            call.id, call.code, call.title, call.description, call.priority,
            json.encode(call.coords), call.postal, call.status, json.encode(call.jobs), call.createdAt,
        }
    )
end

function Database.UpdateCall(call)
    if not available() then return end

    MySQL.update(
        'UPDATE nb_dispatch_calls SET status = ?, assigned_units = ?, notes = ?, closed_at = ? WHERE call_id = ?',
        {
            call.status,
            json.encode(call.assignedUnits),
            json.encode(call.notes),
            call.status == 'closed' and os.time() or nil,
            call.id,
        }
    )
end

function Database.InsertNote(callId, note)
    if not available() then return end

    MySQL.insert(
        'INSERT INTO nb_dispatch_notes (call_id, author, author_source, message, created_at) VALUES (?, ?, ?, ?, FROM_UNIXTIME(?))',
        { callId, note.author, note.authorSource, note.message, note.createdAt }
    )
end

function Database.InsertUnitHistory(unit, callId, action)
    if not available() then return end

    MySQL.insert(
        'INSERT INTO nb_dispatch_unit_history (call_id, unit_source, callsign, job, action, created_at) VALUES (?, ?, ?, ?, ?, FROM_UNIXTIME(?))',
        { callId, unit.id, unit.callsign, unit.job, action, os.time() }
    )
end
