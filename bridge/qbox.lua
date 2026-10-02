Framework.Adapters.qbox = {}
local Adapter = Framework.Adapters.qbox

local function getExportResource()
    if GetResourceState('qbx_core') == 'started' then return 'qbx_core' end
    if GetResourceState('qbox-core') == 'started' then return 'qbox-core' end
    return nil
end

function Adapter.GetPlayer(src)
    local resourceName = getExportResource()
    if not resourceName then return nil end
    local ok, player = pcall(function()
        return exports[resourceName]:GetPlayer(src)
    end)
    if not ok then return nil end
    return player
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
