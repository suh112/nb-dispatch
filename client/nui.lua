RegisterNUICallback('close', function(_, cb)
    CloseDispatch()
    cb({ ok = true })
end)

RegisterNUICallback('requestSync', function(_, cb)
    TriggerServerEvent(Constants.Events.RequestSync)
    cb({ ok = true })
end)

RegisterNUICallback('acceptCall', function(data, cb)
    TriggerServerEvent(Constants.Events.AcceptCall, data.callId)
    cb({ ok = true })
end)

RegisterNUICallback('assignCall', function(data, cb)
    TriggerServerEvent(Constants.Events.AssignCall, data.callId, data.unitId)
    cb({ ok = true })
end)

RegisterNUICallback('unassignCall', function(data, cb)
    TriggerServerEvent(Constants.Events.UnassignCall, data.callId, data.unitId)
    cb({ ok = true })
end)

RegisterNUICallback('closeCall', function(data, cb)
    TriggerServerEvent(Constants.Events.CloseCall, data.callId)
    cb({ ok = true })
end)

RegisterNUICallback('addNote', function(data, cb)
    TriggerServerEvent(Constants.Events.AddNote, data.callId, data.message)
    cb({ ok = true })
end)

RegisterNUICallback('setStatus', function(data, cb)
    TriggerServerEvent(Constants.Events.UpdateUnitStatus, data.status)
    cb({ ok = true })
end)

RegisterNUICallback('setCallsign', function(data, cb)
    TriggerServerEvent(Constants.Events.SetCallsign, data.callsign)
    cb({ ok = true })
end)

RegisterNUICallback('createCall', function(data, cb)
    TriggerServerEvent(Constants.Events.CreateCall, data)
    cb({ ok = true })
end)

RegisterNUICallback('panic', function(_, cb)
    TriggerServerEvent(Constants.Events.Panic)
    cb({ ok = true })
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    if data and data.coords then
        SetNewWaypoint(data.coords.x + 0.0, data.coords.y + 0.0)
    end
    cb({ ok = true })
end)

RegisterNUICallback('removeWaypoint', function(_, cb)
    local blip = GetFirstBlipInfoId(8)
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
    cb({ ok = true })
end)

RegisterNUICallback('createBlip', function(data, cb)
    if data and data.callId and data.coords then
        Blips.Create(data.callId, data.coords, data.blip)
    end
    cb({ ok = true })
end)

RegisterNUICallback('removeBlip', function(data, cb)
    if data and data.callId then
        Blips.Remove(data.callId)
    end
    cb({ ok = true })
end)

RegisterNUICallback('copyCoords', function(_, cb)

    cb({ ok = true })
end)
