# WeakAuras Security Manager

A standalone WoW addon for **WOTLK 3.3.5a** that lets you manage WeakAuras' sandbox security settings in-game — no file editing required.

## What it does

WeakAuras blocks certain Lua and WoW API functions inside WeakAura scripts to protect users from malicious code. This addon lets you selectively **allow or block** those functions through a simple in-game UI, instead of manually editing `AuraEnvironment.lua` every time WeakAuras updates.

## Why use it

- You have a useful WeakAura that requires a blocked function (e.g. `pcall` for error handling)
- You don't want to manually patch WeakAuras files after every update
- You want full control over which functions are accessible in WA scripts

## How it works

The addon hooks into `WeakAuras.LoadFunction` and wraps every compiled WeakAura function with a custom environment. That environment checks your saved settings at runtime — no reload needed when you change a toggle.

No WeakAuras files are modified. The addon works entirely on its own.

## Compatibility

- WoW **3.3.5a** (Interface 30300)
- Tested on **Ascension Reborn** (Bronzebeard)
- Requires **WeakAuras** (listed as dependency)

## Installation

1. Copy the `WeakAuras_SecurityManager` folder into your `Interface/AddOns/` directory
2. Reload WoW or use `/reload`
3. Done — the addon loads automatically alongside WeakAuras

To update WeakAuras in the future: just update WeakAuras normally. This addon stays untouched.

## Usage

```
/wasec
```

Opens the Security Manager window. From there you can:

- Toggle individual functions between **BLOCKED** and **ALLOWED**
- Use **Block All** to restore maximum security
- Use **Allow All** to unlock everything
- Use **Reconnect** if the hook was lost (e.g. after a UI error)

Changes apply **instantly** — no reload required.

## Managed Functions

| Category | Functions |
|----------|-----------|
| Lua | `pcall`, `xpcall`, `loadstring`, `getfenv`, `setfenv` |
| System | `RunScript`, `securecall`, `DeleteCursorItem`, `EnumerateFrames`, `DevTools_DumpCommand` |
| Macro | `EditMacro`, `CreateMacro`, `SetBindingMacro` |
| Chat | `ChatEdit_SendText`, `ChatEdit_ActivateChat`, `ChatEdit_ParseText`, `ChatEdit_OnEnterPressed` |
| Trade / Mail | `SendMail`, `AcceptTrade`, `SetTradeMoney`, `AddTradeMoney`, `PickupTradeMoney`, `PickupPlayerMoney`, `SetSendMailMoney` |
| Guild | `GuildDisband`, `GuildUninvite` |
| Slash | `hash_SlashCmdList`, `RegisterNewSlashCommand` |

## Security Notice

Unlocking functions like `SendMail`, `AcceptTrade` or `GuildDisband` allows any active WeakAura to use them. Only unlock what you actually need, and only import WeakAuras from sources you trust.

## Author

Tecro
