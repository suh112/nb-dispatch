# nb-dispatch

<p align="center">
  <img src="https://imgur.com/a/u9qE2jw" alt="nb-dispatch banner" width="100%">
</p>


Modern Multi-Framework FiveM Dispatch System

Created by **NullBound - Veyx (AJ)**

---

## Features

- Full dispatch system: calls, priorities, assignment, notes, blips, waypoints, history
- Works out of the box with **ESX Legacy**, **QBCore**, **QBox**, or **no framework at all** (Standalone)
- Clean framework abstraction - the dispatch logic never touches `ESX`/`QBCore`/`qbx_core` directly
- Fully configurable departments/jobs (police, sheriff, state, FIB, EMS, or your own)
- Grade based permission system (officer / supervisor / dispatcher / command / admin)
- Panic button with cooldown and automatic priority-1 call + blip
- Unit down alert - automatically raises a priority-1 call and full-department alert (screen flash + siren + bundled `.mp3` alarm) when an on-duty unit (police, EMS, or any configured job) dies
- Bundled `.mp3` alert tones played client-side through the NUI for every automatically detected illegal activity (gunshots, vehicle theft, crashes, pursuits), independent of in-game sound settings
- Optional automatic dispatch: gunshots, vehicle theft, crashes, pursuits
- Citizen `/911` reporting for non-unit players
- Modern dark dispatch UI (React + TypeScript + Vite + Mantine), red/blue emergency accents
- Server authoritative - every action (accept/assign/close/panic/status/etc.) is validated and rate limited server side
- Optional `oxmysql` persistence - the resource works fully in-memory if disabled
- Clean export API for other resources

---

## Requirements

- A recent FiveM server build
- Node.js 18+ and npm (only needed to **build** the UI, not to run the resource)
- Optional: [oxmysql](https://github.com/overextended/oxmysql) if you enable the database
- Optional: a postal resource exporting `getPostal(coords)` (e.g. `nearest-postal`) for postal codes

---

## Installation

1. Copy the `nb-dispatch` folder into your server's `resources` directory.
2. Build the UI once:

   ```bash
   cd nb-dispatch/web
   npm install
   npm run build
   ```

   This produces `web/build/index.html` + `web/build/assets/*`, which is what `fxmanifest.lua` serves as the NUI page.

3. Add to `server.cfg`:

   ```cfg
   ensure nb-dispatch
   ```

4. (Optional) If using the database, run `sql/install.sql` against your database and set `Config.Database.Enabled = true` in `config.lua`.

### ESX Legacy installation

No extra steps. Set `Config.Framework = 'auto'` (default) or `'esx'`. Make sure `es_extended` starts **before** `nb-dispatch` in `server.cfg`.

### QBCore installation

No extra steps. Set `Config.Framework = 'auto'` or `'qbcore'`. Make sure `qb-core` starts before `nb-dispatch`.

### QBox installation

No extra steps. Set `Config.Framework = 'auto'` or `'qbox'`. Works with either the `qbx_core` or `qbox-core` resource name. Make sure it starts before `nb-dispatch`.

### Standalone installation

Set `Config.Framework = 'standalone'` (or leave on `'auto'` with no framework running). Grant jobs/grades via ACE permissions in `server.cfg`:

```cfg
add_ace group.police nb-dispatch.job.police allow
add_ace group.police nb-dispatch.grade.police.2 allow
add_principal identifier.license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx group.police
```

A player with `nb-dispatch.job.police` but no explicit grade ace is treated as grade 0. You can fully replace this logic with `Config.Standalone.Resolver` (see `config.lua`).

---

## Configuration

Everything important lives in `config.lua`:

- `Config.Framework` - `'auto' | 'esx' | 'qbcore' | 'qbox' | 'standalone'`
- `Config.Jobs` - which departments use dispatch, their label/type/grades
- `Config.Permissions` / `Config.GradePermissions` / `Config.ActionPermissions` - who can do what
- `Config.CallTypes` - every built-in 10-code / call type, its default priority and blip
- `Config.AutomaticDispatch` / `Config.AutomaticDispatchCooldowns` - automatic call toggles & cooldowns
- `Config.Sounds` / `Config.SoundBank` - notification sounds
- `Config.Database` - optional oxmysql persistence
- `Config.RateLimits` - per-action server side rate limiting
- `Config.UnitDownAlert` - enable/disable and cooldown for the automatic unit-down alert

### Framework detection

With `Config.Framework = 'auto'`, on resource start (and whenever a framework resource starts later) the server checks, in order: QBox -> QBCore -> ESX Legacy -> Standalone, and prints:

```
[nb-dispatch] Framework detected: QBox
```

If a framework is explicitly selected but its resource isn't running, nb-dispatch automatically falls back to Standalone rather than erroring.

### Job configuration

Nothing assumes `police` is your only department:

```lua
Config.Jobs = {
    police  = { enabled = true, label = 'Police', type = 'police', grades = { ... } },
    sheriff = { enabled = true, label = 'Sheriff', type = 'police' },
    state   = { enabled = true, label = 'State Police', type = 'police' },
}
```

Add/remove/rename freely. A call's `jobs` list decides which departments see it (`Config.DefaultJobs` is used when a call doesn't specify its own).

### Permissions

Permission level is resolved purely from the player's numeric job **grade**, through `Config.GradePermissions` (or a per-job override via `jobCfg.permissionGrades`) - grade **names** are never used for security decisions, and the exact same config works identically across ESX, QBCore and QBox. `Config.ActionPermissions` maps each action (accept/assign/close/panic/...) to a required permission level.

---

## Database

Fully optional. With `Config.Database.Enabled = false` (default), nb-dispatch runs entirely in memory - calls, notes and history work normally, they just aren't persisted across a restart. Set it to `true` and run `sql/install.sql` once `oxmysql` is installed to log calls, notes and unit assignment history.

---

## Exports

### Server (trusted resource-to-resource calls)

```lua
local call = exports['nb-dispatch']:CreateCall({
    code = '10-31',
    title = 'Store Robbery',
    description = 'Store robbery in progress',
    priority = 1,
    coords = vector3(123.4, 456.7, 78.9),
    jobs = { 'police', 'sheriff' },
    blip = { sprite = 161, color = 1, scale = 1.0, duration = 120 },
})

exports['nb-dispatch']:GetActiveCalls()
exports['nb-dispatch']:GetUnits()
```

### Client (per-player)

```lua
exports['nb-dispatch']:OpenDispatch()
exports['nb-dispatch']:CloseDispatch()
exports['nb-dispatch']:PanicButton()
exports['nb-dispatch']:IsAuthorized()
```

---

## Events

```text
Server:
nb-dispatch:server:createCall
nb-dispatch:server:acceptCall
nb-dispatch:server:assignCall
nb-dispatch:server:unassignCall
nb-dispatch:server:closeCall
nb-dispatch:server:addNote
nb-dispatch:server:updateUnitStatus
nb-dispatch:server:panic
nb-dispatch:server:setCallsign
nb-dispatch:server:requestSync
nb-dispatch:server:autoDispatch
nb-dispatch:server:citizen911
nb-dispatch:server:pursuitFlag

Client:
nb-dispatch:client:updateCalls
nb-dispatch:client:updateUnits
nb-dispatch:client:newCall
nb-dispatch:client:panic
nb-dispatch:client:open
nb-dispatch:client:close
nb-dispatch:client:notify
nb-dispatch:client:syncMeta
```

All server events re-validate job, permission, rate limit and payload shape - the client is never trusted to supply its own permission level, callsign uniqueness, or call ownership.

---

## Commands

| Command | Description |
|---|---|
| `/dispatch` (or `F9`) | Toggle the dispatch UI |
| `/panic` | Trigger the panic button |
| `/callsign <text>` | Set your callsign |
| `/pursuit` | Flag a pursuit at your current position |
| `/911 <message>` | Citizen emergency report (non-units) |

---

## NUI development

```bash
cd web
npm install
npm start          # dev server on :3001, uses mock data (src/components/Dispatch/mockData.ts)
npm run build      # production build into web/build
```

`src/utils/fetchNui.ts` and `src/hooks/useNuiEvent.ts` are the NUI <-> Lua bridge. State lives in a small Zustand store (`src/store/dispatchStore.ts`). The UI never trusts itself for permissions - buttons may be visually enabled, but every mutating action is re-checked server side.

---

## Performance

- No `while true do` without a `Wait` - every loop sleeps appropriately
- Unit coordinate refresh is batched on a single `Config.UnitUpdateInterval` second timer, not per-frame
- Blips are created once per call and cleaned up automatically on close/expire/resource stop
- NUI pushes are event driven (new call / updated calls / updated units), not polled by the UI
- Automatic dispatch detection runs on cheap polling threads (250ms-2s) and is skipped entirely for on-duty units (`Config.IgnoreUnitsInAutoDispatch`)
- Vehicle theft detection uses the native `IsPedJacking` check rather than a lock-status heuristic, so it won't false-positive on key-system-locked owned vehicles

---

## Alerts & sounds

- **Illegal activity alerts** - every automatically raised call (gunshots, vehicle theft, crashes, pursuits, assault) plays a distinct `.mp3` alarm tone client-side through the NUI (`web/src/assets/sounds/alert_illegal.mp3`), in addition to the native in-game sound controlled by `Config.Sounds`/`Config.SoundBank`. Player/dispatcher/citizen-created calls play a softer chime instead.
- **Panic button** - full-screen red flash overlay + siren `.mp3` + native sound, broadcast to every online unit of the same department.
- **Unit down** - when an on-duty unit (`IsEntityDead` transition) dies, the server raises a priority-1 `officer_down` call for their department and broadcasts a full-screen alert (orange flash + `.mp3` + native sound) to every unit sharing that job. Toggle with `Config.UnitDownAlert.Enabled` / `.Cooldown`.
- NUI alert sounds keep playing even while the dispatch panel is closed, since the NUI page stays loaded in the background - only its visibility/focus toggles.

---

## Security

- Every mutating action is validated server side: job, permission level, callsign/unit ownership, call existence, and a per-action rate limit
- A client can never close calls it's not permitted to, assign/unassign other units without supervisor permission, fake its job, or bypass the panic cooldown
- `CreateCall` with custom `coords` (dispatcher-only) still requires the `dispatcher` permission level; everyone else's calls are pinned to their own position

---

## Troubleshooting

- **UI is blank / "Framework detected: Standalone" when you expected otherwise** - make sure your framework resource (`es_extended`, `qb-core`, `qbx_core`/`qbox-core`) is listed **before** `nb-dispatch` in `server.cfg`, or set `Config.Framework` explicitly.
- **"web/build/index.html not found"** - you need to run `npm install && npm run build` inside `web/` once; the build output isn't committed.
- **Postal shows N/A** - install a postal resource and point `Config.Postal.Resource` / `Config.Postal.Export` at it, or disable with `Config.Postal.Enabled = false`.
- **Database errors** - confirm `oxmysql` is started and `sql/install.sql` has been executed; otherwise leave `Config.Database.Enabled = false`.

---

nb-dispatch - Created by **NullBound - Veyx (AJ)**
