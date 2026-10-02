Framework = {}
Framework.name = 'standalone'
Framework.Adapters = {}
Framework.ready = false

local frameworkLabels = {
    esx = 'ESX Legacy',
    qbcore = 'QBCore',
    qbox = 'QBox',
    standalone = 'Standalone',
}

local function resourceReady(name)
    local state = GetResourceState(name)
    return state == 'started' or state == 'starting'
end

function Framework.Detect()
    local want = Config.Framework

    if want == 'auto' then
        if resourceReady('qbx_core') or resourceReady('qbox-core') then
            Framework.name = 'qbox'
        elseif resourceReady('qb-core') then
            Framework.name = 'qbcore'
        elseif resourceReady('es_extended') then
            Framework.name = 'esx'
        else
            Framework.name = 'standalone'
        end
    else
        Framework.name = want
    end

    local resourceForFramework = {
        qbox = (resourceReady('qbx_core') and 'qbx_core') or (resourceReady('qbox-core') and 'qbox-core') or nil,
        qbcore = resourceReady('qb-core') and 'qb-core' or nil,
        esx = resourceReady('es_extended') and 'es_extended' or nil,
    }

    if Framework.name ~= 'standalone' and not resourceForFramework[Framework.name] then
        print(('[nb-dispatch] %s was selected but its resource is not running, falling back to Standalone')
            :format(frameworkLabels[Framework.name] or Framework.name))
        Framework.name = 'standalone'
    end

    if not Framework.Adapters[Framework.name] then
        print(('[nb-dispatch] No adapter registered for "%s", falling back to Standalone'):format(Framework.name))
        Framework.name = 'standalone'
    end

    Framework.ready = true
    print(('[nb-dispatch] Framework detected: %s'):format(frameworkLabels[Framework.name] or Framework.name))
end

local function adapter()
    return Framework.Adapters[Framework.name]
end

function Framework.GetPlayer(src)
    local a = adapter()
    if not a or not a.GetPlayer then return nil end
    local ok, result = pcall(a.GetPlayer, src)
    if not ok then return nil end
    return result
end

function Framework.GetJob(src)
    local a = adapter()
    if not a or not a.GetJob then return nil end
    local ok, result = pcall(a.GetJob, src)
    if not ok or not result then return nil end
    return result
end

function Framework.GetIdentifier(src)
    local a = adapter()
    if not a or not a.GetIdentifier then return tostring(src) end
    local ok, result = pcall(a.GetIdentifier, src)
    if not ok or not result then return tostring(src) end
    return result
end

function Framework.GetPlayerName(src)
    local a = adapter()
    local ok, result
    if a and a.GetPlayerName then
        ok, result = pcall(a.GetPlayerName, src)
    end
    if not ok or not result or result == '' then
        return GetPlayerName(src) or ('Unit ' .. tostring(src))
    end
    return result
end

function Framework.GetOnlinePlayers()
    local players = {}
    for _, src in ipairs(GetPlayers()) do
        players[#players + 1] = tonumber(src)
    end
    return players
end

function Framework.IsPolice(src)
    local job = Framework.GetJob(src)
    if not job then return false end
    local jobCfg = Config.Jobs[job.name]
    return jobCfg ~= nil and jobCfg.enabled and jobCfg.type == 'police'
end

function Framework.GetGradeLabel(jobName, grade, fallback)
    local jobCfg = Config.Jobs[jobName]
    if jobCfg and jobCfg.grades and jobCfg.grades[grade] then
        return jobCfg.grades[grade]
    end
    return fallback or ('Grade ' .. tostring(grade or 0))
end

function Framework.IsDispatchJob(jobName)
    local jobCfg = Config.Jobs[jobName]
    return jobCfg ~= nil and jobCfg.enabled == true
end

AddEventHandler('onResourceStart', function(resourceName)
    if Config.Framework ~= 'auto' then return end
    if resourceName == 'qbx_core' or resourceName == 'qbox-core'
        or resourceName == 'qb-core' or resourceName == 'es_extended' then
        SetTimeout(500, Framework.Detect)
    end
end)

CreateThread(function()
    local waited = 0
    while waited < (Config.FrameworkDetectTimeout or 15) do
        if resourceReady('qbx_core') or resourceReady('qbox-core')
            or resourceReady('qb-core') or resourceReady('es_extended') then
            break
        end
        Wait(500)
        waited = waited + 0.5
    end
    Framework.Detect()
end)
