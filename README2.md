# nb-dispatch v1.0.0

**Modern Multi-Framework FiveM Dispatch System**
Created by **NullBound - Veyx (AJ)**

A production-ready dispatch resource for FiveM with full **ESX Legacy**, **QBCore**, **QBox**, and **Standalone** support behind a single framework-agnostic bridge, a modern dark-themed React/TypeScript NUI, and a fully server-authoritative security model.

---

## ✨ Highlights

- 🔌 **Drop-in multi-framework support** — ESX Legacy, QBCore, QBox, or no framework at all. Auto-detected on boot, with safe fallback to Standalone if nothing is found.
- 🧩 **Clean bridge architecture** — the dispatch core never touches `ESX`/`QBCore`/`qbx_core` directly; everything routes through `Framework.*`.
- 🏢 **Fully configurable departments** — police, sheriff, state, FIB, EMS, or your own custom jobs, each with its own grades and permission overrides.
- 🚨 **18+ built-in call types** — from `10-13 Officer Down` to bank/store/jewelry robberies, pursuits, medical emergencies, and fires — plus custom calls.
- 🆘 **Panic button** — configurable cooldown, priority-1 broadcast, map blip, and full-screen alert for every unit in the department.
- 🤖 **Automatic dispatch** — gunshots, vehicle theft, crashes, and pursuits can raise calls on their own, with per-feature cooldowns and area dedupe so it never spams.
- 📞 **Citizen `/911` reporting** for players who aren't on-duty units.
- 🖥️ **Modern dispatch UI** — React + TypeScript + Vite, dashboard, call list/detail, unit roster, notes, search & filters, toast notifications.
- 🔒 **Server authoritative** — every action (accept, assign, close, panic, status change, callsign, note) is re-validated server-side: job, permission level, rate limit, ownership. The client is never trusted.
- 🗄️ **Optional `oxmysql` persistence** — fully functional in-memory with zero database setup; enable it when you want call history retained across restarts.
- 📦 **Clean export API** for other resources to create calls, pull active calls, or read online units.

---

## 📥 Installation

1. Drop `nb-dispatch` into your `resources` folder.
2. Build the UI once:
   ```bash
   cd nb-dispatch/web
   npm install
   npm run build
   ```
3. Add `ensure nb-dispatch` to your `server.cfg`.
4. (Optional) Run `sql/install.sql` and set `Config.Database.Enabled = true` if you want persistence.

Full setup instructions for each framework, permissions, exports, events, and troubleshooting are in [`README.md`](./README.md).

---

## ⚙️ Requirements

- FiveM server (recent artifact)
- Node.js 18+ / npm (build-time only, not required to run the resource)
- Optional: [`oxmysql`](https://github.com/overextended/oxmysql)
- Optional: a postal resource exporting `getPostal(coords)`

---

## 🔧 Configuration

Everything lives in `config.lua`:

```lua
Config.Framework = 'auto'   -- 'auto' | 'esx' | 'qbcore' | 'qbox' | 'standalone'
Config.Jobs = { police = { enabled = true, label = 'Police', type = 'police', grades = { ... } }, ... }
Config.Permissions = { officer = 0, supervisor = 1, dispatcher = 2, command = 3, admin = 4 }
Config.AutomaticDispatch = { Gunshots = true, VehicleTheft = true, VehicleCrash = true, Assault = false, Pursuit = true }
```

---

## 🧱 What's inside

```
nb-dispatch/
├── bridge/     ESX / QBCore / QBox / Standalone adapters behind one interface
├── client/     NUI bridge, blips, automatic dispatch detection
├── server/     Calls, units, permissions, optional database persistence
├── shared/     Constants & utilities
├── sql/        Optional oxmysql schema
├── web/        React + TypeScript + Vite dispatch UI
└── config.lua  Every configurable option, fully commented
```

---

## 📜 License / Credit

Please keep the **NullBound - Veyx (AJ)** attribution in the README, fxmanifest, and UI footer intact if you redistribute or modify this resource.

---

**Full Changelog**: initial release
