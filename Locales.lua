-- WeakAuras_SecurityManager - Locales.lua
-- Autor: Tecro

WASecurityManager = WASecurityManager or {}

local locales = {
    -- ============================================================
    enUS = {
        -- UI General
        TITLE          = "|cff9900ffWeakAuras|r Security Manager",
        BTN_BLOCK_ALL  = "|cffff6666Block All|r",
        BTN_ALLOW_ALL  = "|cff66ff66Allow All|r",
        BTN_RECONNECT  = "Reconnect",
        BTN_CLOSE      = "Close",
        TOGGLE_BLOCKED = "BLOCKED",
        TOGGLE_ALLOWED = "ALLOWED",
        HINT_TEXT      = "|cffff8800[!]|r Changes apply instantly (no reload needed). Only unlock trusted WeakAuras!",
        STATUS_ACTIVE  = "|cff00ff00[ACTIVE]|r Hook installed - changes apply instantly.",
        STATUS_ERROR   = "|cffff4444[ERROR]|r ",
        -- Chat messages
        MSG_LOADED        = "|cff9900ffWeakAuras Security Manager|r: |cff00ff00Active|r - /wasec to open.",
        MSG_ERROR         = "|cff9900ffWeakAuras Security Manager|r: |cffff4444ERROR - ",
        MSG_RECONNECTED   = "|cff9900ffWASec|r: |cff00ff00Successfully connected.|r",
        MSG_RECONNECT_ERR = "|cff9900ffWASec|r: |cffff4444Error - ",
        -- Categories
        CAT_Lua    = "Lua",
        CAT_System = "System",
        CAT_Makro  = "Macro",
        CAT_Chat   = "Chat",
        CAT_Handel = "Trade / Mail",
        CAT_Gilde  = "Guild",
        CAT_Slash  = "Slash",
        -- Function descriptions
        DESC_pcall                  = "Error handling (often needed in WAs)",
        DESC_xpcall                 = "Extended error handling",
        DESC_loadstring             = "Dynamic Lua code loading",
        DESC_getfenv                = "Read Lua environment",
        DESC_setfenv                = "Set Lua environment",
        DESC_RunScript              = "Execute Lua script directly",
        DESC_securecall             = "Secure function call",
        DESC_DeleteCursorItem       = "Delete item on cursor",
        DESC_EnumerateFrames        = "Enumerate all UI frames",
        DESC_DevTools_DumpCommand   = "DevTools dump command",
        DESC_EditMacro              = "Edit macros",
        DESC_CreateMacro            = "Create macros",
        DESC_SetBindingMacro        = "Set keybind for macro",
        DESC_ChatEdit_SendText      = "Send chat message",
        DESC_ChatEdit_ActivateChat  = "Activate chat input",
        DESC_ChatEdit_ParseText     = "Parse chat text",
        DESC_ChatEdit_OnEnterPressed= "Simulate chat Enter key",
        DESC_SendMail               = "Send mail",
        DESC_AcceptTrade            = "Accept trade",
        DESC_SetTradeMoney          = "Set trade money",
        DESC_AddTradeMoney          = "Add trade money",
        DESC_PickupTradeMoney       = "Pick up trade money",
        DESC_PickupPlayerMoney      = "Pick up player gold",
        DESC_SetSendMailMoney       = "Put gold in mail",
        DESC_GuildDisband           = "Disband guild",
        DESC_GuildUninvite          = "Kick player from guild",
        DESC_hash_SlashCmdList      = "Slash command list",
        DESC_RegisterNewSlashCommand= "Register new slash command",
    },
    -- ============================================================
    deDE = {
        -- UI General
        TITLE          = "|cff9900ffWeakAuras|r Security Manager",
        BTN_BLOCK_ALL  = "|cffff6666Alles blockieren|r",
        BTN_ALLOW_ALL  = "|cff66ff66Alle erlauben|r",
        BTN_RECONNECT  = "Neu verbinden",
        BTN_CLOSE      = "Schliessen",
        TOGGLE_BLOCKED = "BLOCKIERT",
        TOGGLE_ALLOWED = "ERLAUBT",
        HINT_TEXT      = "|cffff8800[!]|r Aenderungen wirken sofort (kein Reload noetig). Nur vertrauenswuerdige WeakAuras entsperren!",
        STATUS_ACTIVE  = "|cff00ff00[AKTIV]|r Hook installiert - Aenderungen wirken sofort.",
        STATUS_ERROR   = "|cffff4444[FEHLER]|r ",
        -- Chat messages
        MSG_LOADED        = "|cff9900ffWeakAuras Security Manager|r: |cff00ff00Aktiv|r - /wasec zum Oeffnen.",
        MSG_ERROR         = "|cff9900ffWeakAuras Security Manager|r: |cffff4444FEHLER - ",
        MSG_RECONNECTED   = "|cff9900ffWASec|r: |cff00ff00Erfolgreich verbunden.|r",
        MSG_RECONNECT_ERR = "|cff9900ffWASec|r: |cffff4444Fehler - ",
        -- Categories
        CAT_Lua    = "Lua",
        CAT_System = "System",
        CAT_Makro  = "Makro",
        CAT_Chat   = "Chat",
        CAT_Handel = "Handel / Post",
        CAT_Gilde  = "Gilde",
        CAT_Slash  = "Slash",
        -- Function descriptions
        DESC_pcall                  = "Fehlerbehandlung (oft in WAs benoetigt)",
        DESC_xpcall                 = "Erweiterte Fehlerbehandlung",
        DESC_loadstring             = "Dynamisches Laden von Lua-Code",
        DESC_getfenv                = "Lua-Environment lesen",
        DESC_setfenv                = "Lua-Environment setzen",
        DESC_RunScript              = "Lua-Script direkt ausfuehren",
        DESC_securecall             = "Sicherer Funktionsaufruf",
        DESC_DeleteCursorItem       = "Item am Cursor loeschen",
        DESC_EnumerateFrames        = "Alle UI-Frames aufzaehlen",
        DESC_DevTools_DumpCommand   = "DevTools Dump-Befehl",
        DESC_EditMacro              = "Makros bearbeiten",
        DESC_CreateMacro            = "Makros erstellen",
        DESC_SetBindingMacro        = "Tastenbindung fuer Makro setzen",
        DESC_ChatEdit_SendText      = "Chat-Nachricht senden",
        DESC_ChatEdit_ActivateChat  = "Chat-Eingabe aktivieren",
        DESC_ChatEdit_ParseText     = "Chat-Text parsen",
        DESC_ChatEdit_OnEnterPressed= "Chat Enter-Taste simulieren",
        DESC_SendMail               = "Post senden",
        DESC_AcceptTrade            = "Handel annehmen",
        DESC_SetTradeMoney          = "Handelsgeld setzen",
        DESC_AddTradeMoney          = "Handelsgeld hinzufuegen",
        DESC_PickupTradeMoney       = "Handelsgeld aufnehmen",
        DESC_PickupPlayerMoney      = "Spielergold aufnehmen",
        DESC_SetSendMailMoney       = "Geld in Post legen",
        DESC_GuildDisband           = "Gilde aufloesen",
        DESC_GuildUninvite          = "Spieler aus Gilde werfen",
        DESC_hash_SlashCmdList      = "Slash-Befehlsliste",
        DESC_RegisterNewSlashCommand= "Neuen Slash-Befehl registrieren",
    },
}

-- Aktive Locale laden (wird nach SavedVariables-Init in Core.lua gesetzt)
function WASecurityManager.SetLocale(lang)
    local chosen = locales[lang] or locales["enUS"]
    WASecurityManager.L = chosen
end

-- Default: enUS (wird von Core.lua ueberschrieben sobald DB geladen ist)
WASecurityManager.SetLocale("enUS")
