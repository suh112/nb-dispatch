--[[
    nb-dispatch - Configuration
    Created by NullBound - Veyx (AJ)
]]

Config = {}

Config.Debug = false

-- 'auto' | 'esx' | 'qbcore' | 'qbox' | 'standalone'
-- auto: QBox -> QBCore -> ESX Legacy -> Standalone
Config.Framework = 'auto'
Config.FrameworkDetectTimeout = 15 -- seconds to wait for the framework resource to start

Config.DispatchKey = 'F9'        -- key to open dispatch (rebindable in FiveM settings). '' disables
Config.PanicKey = ''             -- optional panic key, '' = no key (use /panic or the export)
Config.DispatchCommand = 'dispatch'
Config.PanicCommand = 'panic'
Config.CallsignCommand = 'callsign'
Config.PursuitCommand = 'pursuit' -- authorized units can flag a pursuit at their position

Config.MaxActiveCalls = 100
Config.CallExpiration = 600      -- seconds until an active call is auto closed
Config.HistoryLimit = 100
Config.PanicCooldown = 10        -- seconds
Config.UnitUpdateInterval = 5    -- seconds, unit location refresh while at least one dispatch UI is open

Config.RequireDuty = true        -- QBCore / QBox: only on-duty players are dispatch units
Config.ShareUnitsAcrossDepartments = true
Config.AllowAssignedUnitsToClose = true
Config.AutoBlips = true          -- create a map blip on every new call for visible units
Config.AutoWaypointOnAccept = true
Config.PanicJobs = nil           -- nil = every enabled job of type 'police'; or { 'police', 'sheriff' }

-- Automatically raises a priority-1 call + full department alert when an on-duty
-- dispatch unit (police, EMS, or any configured job) dies.
Config.UnitDownAlert = {
    Enabled = true,
    Cooldown = 15, -- seconds, per unit - stops duplicate alerts from the same death
}

Config.Database = {
    Enabled = false,
    Driver = 'oxmysql',
}

Config.Postal = {
    Enabled = true,
    Resource = 'nearest-postal',
    Export = 'getPostal',
}

Config.Callsign = {
    AllowSelfSet = true,
    Prefix = 'NB',               -- default callsign = Prefix .. server id
    MaxLength = 8,
}

Config.Citizen911 = {
    Enabled = true,
    Command = '911',
    Cooldown = 60,               -- seconds per player
}

-- Jobs that use dispatch. Nothing is assumed: add / remove your own departments.
-- type: 'police' | 'medical' | 'fire' | 'other' (used for panic + default routing)
-- permissionGrades (optional): override of Config.GradePermissions for that job
Config.Jobs = {
    police = {
        enabled = true,
        label = 'Police',
        type = 'police',
        grades = {
            [0] = 'Officer',
            [1] = 'Senior Officer',
            [2] = 'Sergeant',
            [3] = 'Lieutenant',
            [4] = 'Chief',
        },
    },
    sheriff = {
        enabled = true,
        label = 'Sheriff',
        type = 'police',
    },
    state = {
        enabled = true,
        label = 'State Police',
        type = 'police',
    },
    fib = {
        enabled = false,
        label = 'FIB',
        type = 'police',
    },
    ambulance = {
        enabled = true,
        label = 'EMS',
        type = 'medical',
    },
}

-- Jobs that receive a call when it doesn't define its own list
Config.DefaultJobs = { 'police', 'sheriff', 'state' }

-- Permission levels (higher = more power)
Config.Permissions = {
    officer = 0,
    supervisor = 1,
    dispatcher = 2,
    command = 3,
    admin = 4,
}

-- Minimum job GRADE (number) required for each permission level.
-- Works the same on ESX Legacy / QBCore / QBox. Grade names are never used.
Config.GradePermissions = {
    officer = 0,
    supervisor = 2,
    dispatcher = 2,
    command = 3,
    admin = 4,
}
-- Anyone with ACE `nb-dispatch.admin` who is an authorized unit is treated as admin level.

-- Permission level required for each action
Config.ActionPermissions = {
    accept = 'officer',
    assignSelf = 'officer',
    assignOthers = 'supervisor',
    unassignOthers = 'supervisor',
    close = 'supervisor',
    addNote = 'officer',
    setStatus = 'officer',
    panic = 'officer',
    createCall = 'officer',
    createCallAt = 'dispatcher',  -- create a call at custom coordinates
    manageBlips = 'officer',
}

-- Server side rate limits: { max actions, per seconds }
Config.RateLimits = {
    default = { 10, 5 },
    createCall = { 6, 10 },
    panic = { 3, 10 },
    addNote = { 6, 10 },
    setCallsign = { 3, 30 },
    requestSync = { 5, 10 },
}

Config.UnitStatuses = {
    { id = 'available',    label = 'Available',    color = 'green',  selectable = true },
    { id = 'enroute',      label = 'En Route',     color = 'yellow', selectable = true },
    { id = 'onscene',      label = 'On Scene',     color = 'blue',   selectable = true },
    { id = 'busy',         label = 'Busy',         color = 'orange', selectable = true },
    { id = 'transporting', label = 'Transporting', color = 'grape',  selectable = true },
    { id = 'unavailable',  label = 'Unavailable',  color = 'gray',   selectable = true },
}

Config.AutomaticDispatch = {
    Gunshots = true,
    VehicleTheft = true,
    VehicleCrash = true,
    Assault = false,
    Pursuit = true,
}

-- Seconds. Enforced on the client AND on the server (per player), plus area dedupe
Config.AutomaticDispatchCooldowns = {
    Gunshots = 45,
    VehicleTheft = 90,
    VehicleCrash = 60,
    Assault = 60,
    Pursuit = 120,
}
Config.AutomaticAreaRadius = 120.0       -- same feature within this radius is merged while on cooldown
Config.IgnoreUnitsInAutoDispatch = true  -- authorized units never trigger automatic calls

Config.AutomaticSettings = {
    GunshotsIgnoreSilenced = true,
    CrashMinBodyDamage = 120.0,          -- body health lost in one sample
    CrashMinSpeedDropMph = 25.0,
    PursuitMinSpeedMph = 55.0,           -- wanted level > 0 + driving at least this fast
}

-- Native in-game (GTA soundset) alerts. The NUI also plays its own bundled
-- .mp3 alert tones independently of these - this toggle only controls the
-- native PlaySoundFrontend layer.
Config.Sounds = {
    NewCall = true,
    Priority1 = true,
    Panic = true,
    UnitDown = true,
}

Config.SoundBank = {
    NewCall   = { name = 'Event_Message_Purple', set = 'GTAO_FM_Events_Soundset', repeats = 1 },
    Priority1 = { name = 'Beep_Red', set = 'DLC_HEIST_HACKING_SNAKE_SOUNDS', repeats = 3 },
    Panic     = { name = 'Lose_1st', set = 'GTAO_FM_Events_Soundset', repeats = 4 },
    UnitDown  = { name = 'Lose_1st', set = 'GTAO_FM_Events_Soundset', repeats = 5 },
}

-- Blip defaults: sprite, color, scale, duration (seconds), flash
local PoliceBlip = { sprite = 161, color = 3, scale = 1.0, duration = 120, flash = false }

-- Call types (also usable via CreateCall({ type = 'store_robbery' }) )
Config.CallTypes = {
    officer_down        = { code = '10-13', title = 'Officer Down', priority = 1, blip = { sprite = 126, color = 1, scale = 1.2, duration = 180, flash = true } },
    robbery             = { code = '10-31', title = 'Robbery', priority = 1, blip = { sprite = 161, color = 1, scale = 1.0, duration = 150 } },
    shots_fired         = { code = '10-32', title = 'Shots Fired', priority = 1, blip = { sprite = 110, color = 1, scale = 1.0, duration = 120 } },
    vehicle_accident    = { code = '10-50', title = 'Vehicle Accident', priority = 2, blip = { sprite = 488, color = 17, scale = 1.0, duration = 120 } },
    suspicious_vehicle  = { code = '10-54', title = 'Suspicious Vehicle', priority = 3, blip = { sprite = 225, color = 5, scale = 0.9, duration = 120 } },
    intoxicated_driver  = { code = '10-55', title = 'Intoxicated Driver', priority = 2, blip = { sprite = 225, color = 47, scale = 1.0, duration = 120 } },
    suspicious_person   = { code = '10-56', title = 'Suspicious Person', priority = 3, blip = { sprite = 280, color = 5, scale = 0.9, duration = 120 } },
    vehicle_theft       = { code = 'GTA', title = 'Vehicle Theft', priority = 2, blip = { sprite = 380, color = 1, scale = 1.0, duration = 120 } },
    store_robbery       = { code = '10-31S', title = 'Store Robbery', priority = 1, blip = { sprite = 52, color = 1, scale = 1.1, duration = 180 } },
    bank_robbery        = { code = '10-90', title = 'Bank Robbery', priority = 1, blip = { sprite = 500, color = 1, scale = 1.2, duration = 300, flash = true } },
    jewelry_robbery     = { code = '10-31J', title = 'Jewelry Robbery', priority = 1, blip = { sprite = 617, color = 1, scale = 1.1, duration = 240 } },
    house_robbery       = { code = '10-31H', title = 'House Robbery', priority = 2, blip = { sprite = 40, color = 1, scale = 1.0, duration = 180 } },
    drug_activity       = { code = 'DRUG', title = 'Drug Activity', priority = 3, blip = { sprite = 51, color = 2, scale = 0.9, duration = 150 } },
    assault             = { code = 'ASLT', title = 'Assault', priority = 2, blip = { sprite = 280, color = 1, scale = 1.0, duration = 120 } },
    pursuit             = { code = '10-80', title = 'Pursuit', priority = 1, blip = { sprite = 225, color = 1, scale = 1.1, duration = 90, flash = true } },
    officer_panic       = { code = 'PANIC', title = 'Officer Panic', priority = 1, blip = { sprite = 126, color = 1, scale = 1.4, duration = 300, flash = true } },
    medical_emergency   = { code = '10-52', title = 'Medical Emergency', priority = 2, jobs = { 'ambulance' }, blip = { sprite = 153, color = 1, scale = 1.0, duration = 180 } },
    fire                = { code = '10-70', title = 'Fire', priority = 1, jobs = { 'ambulance' }, blip = { sprite = 436, color = 6, scale = 1.1, duration = 240 } },
    citizen_911         = { code = '911', title = 'Citizen 911 Call', priority = 2, blip = PoliceBlip },
    custom              = { code = 'CUSTOM', title = 'Custom Call', priority = 3, blip = PoliceBlip },
}

-- Messages shown in the UI as notifications
Config.Lang = {
    not_authorized = 'You are not an authorized dispatch unit.',
    no_permission = 'You do not have permission to do that.',
    rate_limited = 'Slow down. Too many requests.',
    invalid_data = 'Invalid data.',
    call_not_found = 'That call no longer exists.',
    call_closed = 'Call closed.',
    call_accepted = 'You accepted the call.',
    call_assigned = 'Unit assigned.',
    call_unassigned = 'Unit unassigned.',
    call_created = 'Call created.',
    note_added = 'Note added.',
    status_updated = 'Status updated.',
    unit_not_found = 'Unit not found or not eligible for this call.',
    panic_cooldown = 'Panic button is on cooldown.',
    panic_sent = 'Panic alert sent to all units.',
    callsign_set = 'Callsign updated.',
    callsign_invalid = 'Invalid callsign.',
    callsign_taken = 'Callsign already in use.',
    call_911_sent = 'Your 911 call has been sent.',
    call_911_cooldown = 'Please wait before calling 911 again.',
    disabled = 'This feature is disabled.',
    internal_error = 'Something went wrong.',
}

-- Standalone framework (no ESX / QBCore / QBox)
-- Default: jobs are granted through ACE permissions in server.cfg:
--   add_ace group.police nb-dispatch.job.police allow
--   add_ace group.police nb-dispatch.grade.police.2 allow     (grade 2 and below are also resolved)
--   add_principal identifier.license:xxxxxxxx group.police
-- You may replace Resolver to hook any custom system:  function(src) return { name='police', grade=2, label='Police', gradeLabel='Sergeant' } end
Config.Standalone = {
    MaxGrade = 10,
    Resolver = nil,
}
