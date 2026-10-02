Blips = {}

local activeBlips = {}

local function safeRemove(callId)
    local entry = activeBlips[callId]
    if not entry then return end
    if DoesBlipExist(entry.handle) then
        RemoveBlip(entry.handle)
    end
    activeBlips[callId] = nil
end

function Blips.Create(callId, coords, blipCfg)
    if activeBlips[callId] then return activeBlips[callId].handle end
    if not coords then return nil end

    local blip = AddBlipForCoord(coords.x + 0.0, coords.y + 0.0, (coords.z or 0.0) + 0.0)

    blipCfg = blipCfg or {}
    SetBlipSprite(blip, blipCfg.sprite or 161)
    SetBlipColour(blip, blipCfg.color or 1)
    SetBlipScale(blip, blipCfg.scale or 1.0)
    SetBlipAsShortRange(blip, false)
    SetBlipDisplay(blip, 4)
    if blipCfg.flash then
        SetBlipFlashes(blip, true)
    end

    local duration = (blipCfg.duration or 120) * 1000
    activeBlips[callId] = { handle = blip, expiresAt = GetGameTimer() + duration }

    return blip
end

function Blips.Remove(callId)
    safeRemove(callId)
end

function Blips.RemoveAll()
    for callId in pairs(activeBlips) do
        safeRemove(callId)
    end
end

function Blips.Sync(calls)
    local seen = {}
    for _, call in ipairs(calls or {}) do
        seen[call.id] = true
        if Config.AutoBlips and not activeBlips[call.id] and call.blip then
            Blips.Create(call.id, call.coords, call.blip)
        end
    end

    for callId in pairs(activeBlips) do
        if not seen[callId] then
            safeRemove(callId)
        end
    end
end

CreateThread(function()
    while true do
        Wait(5000)
        local now = GetGameTimer()
        for callId, entry in pairs(activeBlips) do
            if now >= entry.expiresAt then
                safeRemove(callId)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Blips.RemoveAll()
end)
