Permissions = {}

function Permissions.GetLevel(src)
    if IsPlayerAceAllowed(src, 'nb-dispatch.admin') then
        return Config.Permissions.admin
    end

    local job = Framework.GetJob(src)
    if not job then return nil end

    local jobCfg = Config.Jobs[job.name]
    if not jobCfg or not jobCfg.enabled then return nil end

    local gradeReq = jobCfg.permissionGrades or Config.GradePermissions
    local grade = tonumber(job.grade) or 0

    if grade >= (gradeReq.command or math.huge) then return Config.Permissions.command end
    if grade >= (gradeReq.dispatcher or math.huge) then return Config.Permissions.dispatcher end
    if grade >= (gradeReq.supervisor or math.huge) then return Config.Permissions.supervisor end
    if grade >= (gradeReq.officer or 0) then return Config.Permissions.officer end

    return nil
end

function Permissions.IsAuthorized(src)
    return Permissions.GetLevel(src) ~= nil
end

function Permissions.HasPermission(src, action)
    local level = Permissions.GetLevel(src)
    if level == nil then return false end

    local requiredName = Config.ActionPermissions[action]
    if not requiredName then return true end

    local required = Config.Permissions[requiredName]
    if not required then return true end

    return level >= required
end

function Permissions.LevelName(level)
    for name, value in pairs(Config.Permissions) do
        if value == level then return name end
    end
    return 'officer'
end
