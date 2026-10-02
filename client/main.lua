local dispatchOpen = false
local isAuthorized = false
local lastMeta = nil

local function setNuiFocus(hasFocus)
    SetNuiFocus(hasFocus, hasFocus)
end

function OpenDispatch()
    if dispatchOpen then return end
    dispatchOpen = true
    setNuiFocus(true)
    TriggerServerEvent(Constants.Events.RequestSync)
    SendNUIMessage({ action = Constants.NuiActions.Open })
end

function CloseDispatch()
    if not dispatchOpen then return end
    dispatchOpen = false
    setNuiFocus(false)
    SendNUIMessage({ action = Constants.NuiActions.Close })
end

RegisterNetEvent(Constants.Events.Open, OpenDispatch)
RegisterNetEvent(Constants.Events.Close, CloseDispatch)

RegisterCommand(Config.DispatchCommand, function()
    if dispatchOpen then CloseDispatch() else OpenDispatch() end
end, false)

if Config.DispatchKey ~= '' then
    RegisterKeyMapping(Config.DispatchCommand, 'Open nb-dispatch', 'keyboard', Config.DispatchKey)
end

if Config.PanicKey ~= '' then
    RegisterCommand(Config.PanicCommand .. '_key', function()
        exports[Constants.ResourceName]:PanicButton()
    end, false)
    RegisterKeyMapping(Config.PanicCommand .. '_key', 'nb-dispatch Panic Button', 'keyboard', Config.PanicKey)
end

RegisterCommand(Config.PursuitCommand, function()
    local ped = PlayerPedId()
    TriggerServerEvent(Constants.Events.PursuitFlag, Utils.VecToTable(GetEntityCoords(ped)))
end, false)

RegisterNetEvent(Constants.Events.SyncMeta, function(meta)
    lastMeta = meta
    isAuthorized = meta.authorized == true
    SendNUIMessage({ action = Constants.NuiActions.SyncMeta, data = meta })
end)

RegisterNetEvent(Constants.Events.UpdateCalls, function(calls)
    SendNUIMessage({ action = Constants.NuiActions.UpdateCalls, data = calls })
end)

RegisterNetEvent(Constants.Events.UpdateUnits, function(units)
    SendNUIMessage({ action = Constants.NuiActions.UpdateUnits, data = units })
end)

RegisterNetEvent(Constants.Events.NewCall, function(call)
    SendNUIMessage({ action = Constants.NuiActions.NewCall, data = call })
    PlayDispatchSound(call.priority == 1 and 'Priority1' or 'NewCall')
end)

RegisterNetEvent(Constants.Events.Panic_C, function(data)
    SendNUIMessage({ action = Constants.NuiActions.Panic, data = data })
    PlayDispatchSound('Panic')
end)

RegisterNetEvent(Constants.Events.Notify, function(message, type_)
    SendNUIMessage({ action = Constants.NuiActions.Notify, data = { message = message, type = type_ } })
end)

CreateThread(function()
    Wait(2000)
    TriggerServerEvent(Constants.Events.RequestSync)
    while true do
        Wait(60000)
        TriggerServerEvent(Constants.Events.RequestSync)
    end
end)

function PlayDispatchSound(key)
    if not Config.Sounds[key] then return end
    local snd = Config.SoundBank[key]
    if not snd then return end

    local repeats = snd.repeats or 1
    local delay = 0
    for i = 1, repeats do
        SetTimeout(delay, function()
            PlaySoundFrontend(-1, snd.name, snd.set, true)
        end)
        delay = delay + 350
    end
end

exports('OpenDispatch', OpenDispatch)
exports('CloseDispatch', CloseDispatch)
exports('PanicButton', function()
    TriggerServerEvent(Constants.Events.Panic)
end)
exports('IsAuthorized', function() return isAuthorized end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if dispatchOpen then CloseDispatch() end
end)
