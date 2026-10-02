RegisterNetEvent(Constants.Events.UpdateCalls, function(calls)
    Blips.Sync(calls)
end)

RegisterNetEvent(Constants.Events.NewCall, function(call)
    if Config.AutoBlips and call.blip then
        Blips.Create(call.id, call.coords, call.blip)
    end
end)
