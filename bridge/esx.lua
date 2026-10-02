Framework.Adapters.esx = {}
local Adapter = Framework.Adapters.esx

local ESX = nil

local function getESX()
    if ESX then return ESX end
    if GetResourceState('es_extended') ~= 'started' then return nil end
    local ok, shared = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)
    if ok and shared then ESX = shared end
    return ESX
end

function Adapter.GetPlayer(src)
    local core = getESX()
    if not core then return nil end
    return core.GetPlayerFromId(src)
end

function Adapter.GetJob(src)
    local xPlayer = Adapter.GetPlayer(src)
    if not xPlayer or not xPlayer.job then return nil end
    return {
        name = xPlayer.job.name,
        label = xPlayer.job.label,
        grade = tonumber(xPlayer.job.grade) or 0,
        gradeLabel = xPlayer.job.grade_label or xPlayer.job.grade_name,
    }
end

function Adapter.GetIdentifier(src)
    local xPlayer = Adapter.GetPlayer(src)
    if xPlayer and xPlayer.identifier then return xPlayer.identifier end
    return GetPlayerIdentifierByType(src, 'license') or tostring(src)
end

function Adapter.GetPlayerName(src)
    local xPlayer = Adapter.GetPlayer(src)
    if xPlayer and xPlayer.getName then
        local ok, name = pcall(function() return xPlayer.getName() end)
        if ok and name and name ~= '' then return name end
    end
    return GetPlayerName(src)
end
