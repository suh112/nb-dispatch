Framework.Adapters.qbcore = {}
local Adapter = Framework.Adapters.qbcore

local QBCore = nil

local function getQB()
    if QBCore then return QBCore end
    if GetResourceState('qb-core') ~= 'started' then return nil end
    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    if ok and core then QBCore = core end
    return QBCore
end

function Adapter.GetPlayer(src)
    local core = getQB()
    if not core then return nil end
    return core.Functions.GetPlayer(src)
end

function Adapter.GetJob(src)
    local Player = Adapter.GetPlayer(src)
    if not Player or not Player.PlayerData or not Player.PlayerData.job then return nil end
    local job = Player.PlayerData.job

    if Config.RequireDuty and job.onduty == false then
        return nil
    end

    return {
        name = job.name,
        label = job.label,
        grade = tonumber(job.grade and job.grade.level) or 0,
        gradeLabel = job.grade and job.grade.name,
    }
end

function Adapter.GetIdentifier(src)
    local Player = Adapter.GetPlayer(src)
    if Player and Player.PlayerData and Player.PlayerData.citizenid then
        return Player.PlayerData.citizenid
    end
    return tostring(src)
end

function Adapter.GetPlayerName(src)
    local Player = Adapter.GetPlayer(src)
    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        local info = Player.PlayerData.charinfo
        local full = Utils.Trim(string.format('%s %s', info.firstname or '', info.lastname or ''))
        if full ~= '' then return full end
    end
    return GetPlayerName(src)
end
