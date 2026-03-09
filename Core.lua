-- WeakAuras_SecurityManager - Core.lua
-- Autor: Tecro

WASecurityManager = WASecurityManager or {}
WASecurityManager.version = "1.0.0"
WASecurityManager.hooked  = false

-- SetLocale hier definiert (Locales.lua liefert nur die Daten-Tabelle)
function WASecurityManager.SetLocale(lang)
    local locs = WASecurityManager_Locales
    if not locs then
        WASecurityManager.L = {}
        return
    end
    WASecurityManager.L = locs[lang] or locs["enUS"]
end

-- Sofort mit enUS initialisieren damit L nie nil ist
WASecurityManager.SetLocale("enUS")

-- ============================================================
-- Verwaltete Funktionen
-- desc wird zur Laufzeit aus der Locale geladen (L["DESC_key"])
-- ============================================================
WASecurityManager.MANAGED_FUNCTIONS = {
    { key = "pcall",                   category = "Lua"    },
    { key = "xpcall",                  category = "Lua"    },
    { key = "loadstring",              category = "Lua"    },
    { key = "getfenv",                 category = "Lua"    },
    { key = "setfenv",                 category = "Lua"    },
    { key = "RunScript",               category = "System" },
    { key = "securecall",              category = "System" },
    { key = "DeleteCursorItem",        category = "System", default = false },
    { key = "EnumerateFrames",         category = "System" },
    { key = "DevTools_DumpCommand",    category = "System" },
    { key = "EditMacro",               category = "Makro",  default = false },
    { key = "CreateMacro",             category = "Makro"  },
    { key = "SetBindingMacro",         category = "Makro"  },
    { key = "ChatEdit_SendText",       category = "Chat"   },
    { key = "ChatEdit_ActivateChat",   category = "Chat"   },
    { key = "ChatEdit_ParseText",      category = "Chat"   },
    { key = "ChatEdit_OnEnterPressed", category = "Chat"   },
    { key = "SendMail",                category = "Handel" },
    { key = "AcceptTrade",             category = "Handel" },
    { key = "SetTradeMoney",           category = "Handel" },
    { key = "AddTradeMoney",           category = "Handel" },
    { key = "PickupTradeMoney",        category = "Handel" },
    { key = "PickupPlayerMoney",       category = "Handel" },
    { key = "SetSendMailMoney",        category = "Handel" },
    { key = "GuildDisband",            category = "Gilde"  },
    { key = "GuildUninvite",           category = "Gilde"  },
    { key = "hash_SlashCmdList",       category = "Slash"  },
    { key = "RegisterNewSlashCommand", category = "Slash"  },
}

-- Standard-Werte
local DEFAULTS = {}
for _, entry in ipairs(WASecurityManager.MANAGED_FUNCTIONS) do
    DEFAULTS[entry.key] = (entry.default == false) and false or true
end

-- ============================================================
-- Patched Environment
-- ============================================================
local function CreatePatchedEnv(origEnv)
    return setmetatable({}, {
        __index = function(t, k)
            if k == "_G" then return t end
            if WASecurityManagerDB[k] == false then
                local realVal = rawget(_G, k)
                if realVal ~= nil then return realVal end
            end
            return origEnv[k]
        end,
        __newindex = function(t, k, v)
            origEnv[k] = v
        end,
        __metatable = false
    })
end

local patchedFuncs = setmetatable({}, { __mode = "k" })

local function InstallHook()
    if not WeakAuras or type(WeakAuras.LoadFunction) ~= "function" then
        return false, "WeakAuras.LoadFunction not found"
    end
    if type(getfenv) ~= "function" then
        return false, "getfenv not available (server restriction)"
    end
    if type(setfenv) ~= "function" then
        return false, "setfenv not available (server restriction)"
    end
    if WASecurityManager.hooked then
        return true, nil
    end

    local origLoadFunction = WeakAuras.LoadFunction
    WeakAuras.LoadFunction = function(str, id)
        local func = origLoadFunction(str, id)
        if func and type(func) == "function" and not patchedFuncs[func] then
            local ok, origEnv = pcall(getfenv, func)
            if ok and origEnv and origEnv ~= _G then
                local patchedEnv = CreatePatchedEnv(origEnv)
                local setOk = pcall(setfenv, func, patchedEnv)
                if setOk then
                    patchedFuncs[func] = true
                end
            end
        end
        return func
    end

    WASecurityManager.hooked = true
    return true, nil
end

-- ============================================================
-- Public API
-- ============================================================
function WASecurityManager.SetBlocked(key, blocked)
    WASecurityManagerDB[key] = blocked
end

function WASecurityManager.SetAllBlocked(blocked)
    for _, entry in ipairs(WASecurityManager.MANAGED_FUNCTIONS) do
        WASecurityManagerDB[entry.key] = blocked
    end
end

function WASecurityManager.Reconnect()
    WASecurityManager.hooked = false
    local ok, err = InstallHook()
    WASecurityManager.lastError = err
    return ok, err
end

-- ============================================================
-- ADDON_LOADED
-- ============================================================
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "WeakAuras_SecurityManager" then return end
    self:UnregisterEvent("ADDON_LOADED")

    -- SavedVariables initialisieren
    WASecurityManagerDB = WASecurityManagerDB or {}

    -- Sprache laden (default: enUS)
    if not WASecurityManagerDB.locale then
        WASecurityManagerDB.locale = "enUS"
    end
    WASecurityManager.SetLocale(WASecurityManagerDB.locale)

    -- Defaults setzen
    for key, defaultVal in pairs(DEFAULTS) do
        if WASecurityManagerDB[key] == nil then
            WASecurityManagerDB[key] = defaultVal
        end
    end

    -- Hook installieren
    local L = WASecurityManager.L
    local ok, err = InstallHook()
    WASecurityManager.lastError = err

    if ok then
        DEFAULT_CHAT_FRAME:AddMessage(L.MSG_LOADED)
    else
        DEFAULT_CHAT_FRAME:AddMessage(L.MSG_ERROR .. (err or "?") .. "|r")
    end
end)

-- ============================================================
-- Slash-Befehl
-- ============================================================
SLASH_WASEC1 = "/wasec"
SlashCmdList["WASEC"] = function()
    if WASecurityManager.ToggleUI then
        WASecurityManager.ToggleUI()
    end
end
