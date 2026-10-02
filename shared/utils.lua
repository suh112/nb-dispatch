Utils = {}

local idCounter = 0

function Utils.GenerateId(prefix)
    idCounter = idCounter + 1
    local rand = math.random(100, 999)
    return string.format('%s-%d%d', prefix or 'C', GetGameTimer() % 100000, rand + idCounter % 1000)
end

function Utils.Distance(a, b)
    if not a or not b then return 999999.0 end
    local dx, dy, dz = (a.x - b.x), (a.y - b.y), (a.z - b.z)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Utils.VecToTable(vec)
    return { x = vec.x, y = vec.y, z = vec.z }
end

function Utils.GetPostal(coords)
    if not coords or not Config.Postal.Enabled then return nil end
    local resource = Config.Postal.Resource
    if resource and GetResourceState(resource) == 'started' then
        local ok, result = pcall(function()
            return exports[resource][Config.Postal.Export](nil, coords)
        end)
        if ok and result then return tostring(result) end
    end
    return nil
end

Utils._buckets = {}
function Utils.CheckRate(key, limit, window)
    limit = limit or 10
    window = window or 5
    local now = GetGameTimer() / 1000.0
    local bucket = Utils._buckets[key]
    if not bucket or (now - bucket.windowStart) >= window then
        bucket = { count = 0, windowStart = now }
        Utils._buckets[key] = bucket
    end
    bucket.count = bucket.count + 1
    return bucket.count <= limit
end

function Utils.DeepCopy(tbl)
    if type(tbl) ~= 'table' then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = Utils.DeepCopy(v)
    end
    return copy
end

function Utils.TableContains(tbl, value)
    if not tbl then return false end
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function Utils.Trim(s)
    if type(s) ~= 'string' then return s end
    return s:match('^%s*(.-)%s*$')
end

function Utils.Debug(...)
    if Config.Debug then
        print('[nb-dispatch]', ...)
    end
end
