Framework.Adapters.standalone = {}
local Adapter = Framework.Adapters.standalone

function Adapter.GetPlayer(src)
    return { source = src }
end

function Adapter.GetJob(src)
    if Config.Standalone.Resolver then
        local ok, result = pcall(Config.Standalone.Resolver, src)
        if ok then return result end
    end

    for jobName, jobCfg in pairs(Config.Jobs) do
        if jobCfg.enabled and IsPlayerAceAllowed(src, 'nb-dispatch.job.' .. jobName) then
            local grade = 0
            local maxGrade = Config.Standalone.MaxGrade or 10
            for g = maxGrade, 0, -1 do
                if IsPlayerAceAllowed(src, string.format('nb-dispatch.grade.%s.%d', jobName, g)) then
                    grade = g
                    break
                end
            end
            return {
                name = jobName,
                label = jobCfg.label,
                grade = grade,
                gradeLabel = Framework.GetGradeLabel(jobName, grade),
            }
        end
    end

    return nil
end

function Adapter.GetIdentifier(src)
    return GetPlayerIdentifierByType(src, 'license') or tostring(src)
end

function Adapter.GetPlayerName(src)
    return GetPlayerName(src)
end
