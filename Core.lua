-- WeakAuras_SecurityManager - Core.lua
-- Autor: Tecro
--
-- Ansatz: WeakAuras.LoadFunction wird gewrappt. Jede kompilierte WA-Funktion
-- bekommt eine neue Umgebung (setfenv), deren __index-Metamethode dynamisch
-- in WASecurityManagerDB nachschaut ob eine Funktion erlaubt ist.
-- Kein debug-Namespace noetig.

WASecurityManager = WASecurityManager or {}
WASecurityManager.version = "1.0.0"
WASecurityManager.hooked = false

-- ============================================================
-- Verwaltete Funktionen (nur WA-geblockte, wir koennen sie entsperren)
-- ============================================================
WASecurityManager.MANAGED_FUNCTIONS = {
    -- Lua Utilities (oft von WeakAuras benoetigt fuer Fehlerbehandlung)
    { key = "pcall",      category = "Lua",    desc = "Fehlerbehandlung (oft in WAs benoetigt)" },
    { key = "xpcall",     category = "Lua",    desc = "Erweiterte Fehlerbehandlung" },
    { key = "loadstring", category = "Lua",    desc = "Dynamisches Laden von Lua-Code" },
    { key = "getfenv",    category = "Lua",    desc = "Lua-Environment lesen" },
    { key = "setfenv",    category = "Lua",    desc = "Lua-Environment setzen" },
    -- WoW System
    { key = "RunScript",             category = "System",  desc = "Lua-Script direkt ausfuehren" },
    { key = "securecall",            category = "System",  desc = "Sicherer Funktionsaufruf" },
    { key = "DeleteCursorItem",      category = "System",  desc = "Item am Cursor loeschen",        default = false },
    { key = "EnumerateFrames",       category = "System",  desc = "Alle UI-Frames aufzaehlen" },
    { key = "DevTools_DumpCommand",  category = "System",  desc = "DevTools Dump-Befehl" },
    -- Makros
    { key = "EditMacro",       category = "Makro", desc = "Makros bearbeiten",                      default = false },
    { key = "CreateMacro",     category = "Makro", desc = "Makros erstellen" },
    { key = "SetBindingMacro", category = "Makro", desc = "Tastenbindung fuer Makro setzen" },
    -- Chat
    { key = "ChatEdit_SendText",       category = "Chat", desc = "Chat-Nachricht senden" },
    { key = "ChatEdit_ActivateChat",   category = "Chat", desc = "Chat-Eingabe aktivieren" },
    { key = "ChatEdit_ParseText",      category = "Chat", desc = "Chat-Text parsen" },
    { key = "ChatEdit_OnEnterPressed", category = "Chat", desc = "Chat Enter-Taste simulieren" },
    -- Handel / Post
    { key = "SendMail",          category = "Handel", desc = "Post senden" },
    { key = "AcceptTrade",       category = "Handel", desc = "Handel annehmen" },
    { key = "SetTradeMoney",     category = "Handel", desc = "Handelsgeld setzen" },
    { key = "AddTradeMoney",     category = "Handel", desc = "Handelsgeld hinzufuegen" },
    { key = "PickupTradeMoney",  category = "Handel", desc = "Handelsgeld aufnehmen" },
    { key = "PickupPlayerMoney", category = "Handel", desc = "Spielergold aufnehmen" },
    { key = "SetSendMailMoney",  category = "Handel", desc = "Geld in Post legen" },
    -- Gilde
    { key = "GuildDisband",  category = "Gilde", desc = "Gilde aufloesen" },
    { key = "GuildUninvite", category = "Gilde", desc = "Spieler aus Gilde werfen" },
    -- Slash
    { key = "hash_SlashCmdList",       category = "Slash", desc = "Slash-Befehlsliste" },
    { key = "RegisterNewSlashCommand", category = "Slash", desc = "Neuen Slash-Befehl registrieren" },
}

-- Standard: alles blockiert, ausser Eintraege mit default = false
local DEFAULTS = {}
for _, entry in ipairs(WASecurityManager.MANAGED_FUNCTIONS) do
    DEFAULTS[entry.key] = (entry.default == false) and false or true
end

-- ============================================================
-- Patched Environment Factory
-- Erstellt eine neue Umgebung die UEBER der WA-Sandbox liegt.
-- Fuer erlaubte Funktionen (DB[k] == false) wird _G[k] zurueckgegeben,
-- alles andere geht durch die originale WA-Umgebung.
-- ============================================================
local function CreatePatchedEnv(origEnv)
    return setmetatable({}, {
        __index = function(t, k)
            -- _G soll auf unsere Wrapper-Env zeigen (wie WA es macht)
            if k == "_G" then return t end
            -- Erlaubte Funktionen direkt aus _G holen (umgeht WA-Block)
            if WASecurityManagerDB[k] == false then
                local realVal = rawget(_G, k)
                if realVal ~= nil then
                    return realVal
                end
            end
            -- Alles andere: originale WA-Umgebung (mit Blocks, aura_env, etc.)
            return origEnv[k]
        end,
        __newindex = function(t, k, v)
            -- Schreibzugriffe an originale WA-Env delegieren
            origEnv[k] = v
        end,
        __metatable = false
    })
end

-- ============================================================
-- Hook installieren
-- ============================================================
-- Schwache Tabelle: verfolgt welche Funktionen bereits gepatcht wurden.
-- __mode = "k" damit GC die Eintraege raeumen kann wenn WA sie freigibt.
local patchedFuncs = setmetatable({}, { __mode = "k" })

local function InstallHook()
    if not WeakAuras or type(WeakAuras.LoadFunction) ~= "function" then
        return false, "WeakAuras.LoadFunction nicht gefunden"
    end

    -- getfenv / setfenv pruefen
    if type(getfenv) ~= "function" then
        return false, "getfenv nicht verfuegbar (Server sperrt diese Funktion)"
    end
    if type(setfenv) ~= "function" then
        return false, "setfenv nicht verfuegbar (Server sperrt diese Funktion)"
    end

    -- Bereits gehooked?
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
-- Einstellungen zuruecksetzen (fuer UI-Buttons)
-- ============================================================
function WASecurityManager.SetBlocked(key, blocked)
    WASecurityManagerDB[key] = blocked
    -- Aenderung wirkt sofort: naechste Ausfuehrung einer WA liest DB neu
end

function WASecurityManager.SetAllBlocked(blocked)
    for _, entry in ipairs(WASecurityManager.MANAGED_FUNCTIONS) do
        WASecurityManagerDB[entry.key] = blocked
    end
end

-- ============================================================
-- ADDON_LOADED Handler
-- ============================================================
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "WeakAuras_SecurityManager" then return end
    self:UnregisterEvent("ADDON_LOADED")

    -- SavedVariables initialisieren
    WASecurityManagerDB = WASecurityManagerDB or {}
    for key, defaultVal in pairs(DEFAULTS) do
        if WASecurityManagerDB[key] == nil then
            WASecurityManagerDB[key] = defaultVal
        end
    end

    -- Hook installieren
    local ok, err = InstallHook()
    WASecurityManager.lastError = err

    if ok then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cff9900ffWeakAuras Security Manager|r: |cff00ff00Aktiv|r - /wasec zum Oeffnen.")
    else
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cff9900ffWeakAuras Security Manager|r: |cffff4444FEHLER - " .. (err or "Unbekannt") .. "|r")
    end
end)

-- Re-Hook Funktion fuer den UI-Button
function WASecurityManager.Reconnect()
    WASecurityManager.hooked = false  -- Reset damit Hook neu installiert wird
    local ok, err = InstallHook()
    WASecurityManager.lastError = err
    return ok, err
end

-- ============================================================
-- Slash-Befehl
-- ============================================================
SLASH_WASEC1 = "/wasec"
SlashCmdList["WASEC"] = function()
    if WASecurityManager.ToggleUI then
        WASecurityManager.ToggleUI()
    end
end
