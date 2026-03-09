-- WeakAuras_SecurityManager - UI.lua
-- Autor: Tecro

local WINDOW_W = 500
local WINDOW_H = 580
local ROW_H    = 26
local CAT_H    = 26
local CAT_PAD  = 8

-- ============================================================
-- Hilfsfunktionen
-- ============================================================
local function SetBackdropSimple(frame, br, bg, bb, ba, er, eg, eb)
    frame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(br or 0.08, bg or 0.08, bb or 0.08, ba or 0.95)
    frame:SetBackdropBorderColor(er or 0.3, eg or 0.3, eb or 0.3, 1)
end

local function MakeBtn(parent, w, h, text, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(w, h)
    SetBackdropSimple(btn, 0.12, 0.12, 0.12, 1)
    local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetAllPoints()
    lbl:SetText(text)
    btn._lbl = lbl
    btn:SetScript("OnClick", onClick)
    btn:SetScript("OnEnter", function(s) s:SetBackdropColor(0.22, 0.22, 0.28, 1) end)
    btn:SetScript("OnLeave", function(s) s:SetBackdropColor(0.12, 0.12, 0.12, 1) end)
    return btn
end

-- ============================================================
-- Haupt-Fenster
-- ============================================================
local win = CreateFrame("Frame", "WASecurityManagerFrame", UIParent)
win:SetSize(WINDOW_W, WINDOW_H)
win:SetPoint("CENTER")
win:SetFrameStrata("DIALOG")
win:SetMovable(true)
win:EnableMouse(true)
win:RegisterForDrag("LeftButton")
win:SetScript("OnDragStart", win.StartMoving)
win:SetScript("OnDragStop",  win.StopMovingOrSizing)
win:SetClampedToScreen(true)
SetBackdropSimple(win)
win:Hide()

-- Titelleiste
local titleBg = CreateFrame("Frame", nil, win)
titleBg:SetPoint("TOPLEFT",  win, "TOPLEFT",  1, -1)
titleBg:SetPoint("TOPRIGHT", win, "TOPRIGHT", -1, -1)
titleBg:SetHeight(30)
SetBackdropSimple(titleBg, 0.04, 0.04, 0.14, 1, 0.45, 0.2, 0.75)

local titleTxt = titleBg:CreateFontString(nil, "OVERLAY")
titleTxt:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
titleTxt:SetPoint("CENTER", titleBg, "CENTER", -10, 0)

-- Sprach-Toggle (EN | DE) in der Titelleiste
local langBtn = CreateFrame("Button", nil, titleBg)
langBtn:SetSize(52, 20)
langBtn:SetPoint("RIGHT", titleBg, "RIGHT", -36, 0)
SetBackdropSimple(langBtn, 0.1, 0.1, 0.25, 1, 0.5, 0.3, 0.8)
local langLbl = langBtn:CreateFontString(nil, "OVERLAY")
langLbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
langLbl:SetAllPoints()
langLbl:SetJustifyH("CENTER")
langBtn:SetScript("OnEnter", function(s) s:SetBackdropColor(0.18, 0.18, 0.38, 1) end)
langBtn:SetScript("OnLeave", function(s) s:SetBackdropColor(0.1, 0.1, 0.25, 1) end)

-- Schliessen-Button
local closeBtn = CreateFrame("Button", nil, win, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", win, "TOPRIGHT", 2, 2)
closeBtn:SetScript("OnClick", function() win:Hide() end)

-- Status-Zeile
local statusLine = win:CreateFontString(nil, "OVERLAY")
statusLine:SetFont("Fonts\\FRIZQT__.TTF", 11)
statusLine:SetPoint("TOPLEFT",  win, "TOPLEFT",  10, -36)
statusLine:SetPoint("TOPRIGHT", win, "TOPRIGHT", -36, -36)
statusLine:SetJustifyH("LEFT")

-- Hinweis-Box
local hintBox = CreateFrame("Frame", nil, win)
hintBox:SetPoint("TOPLEFT",  win, "TOPLEFT",  8, -52)
hintBox:SetPoint("TOPRIGHT", win, "TOPRIGHT", -8, -52)
hintBox:SetHeight(38)
SetBackdropSimple(hintBox, 0.18, 0.1, 0.0, 0.9, 0.7, 0.45, 0.0)

local hintTxt = hintBox:CreateFontString(nil, "OVERLAY")
hintTxt:SetFont("Fonts\\FRIZQT__.TTF", 10)
hintTxt:SetPoint("TOPLEFT",     hintBox, "TOPLEFT",     6, -4)
hintTxt:SetPoint("BOTTOMRIGHT", hintBox, "BOTTOMRIGHT", -6,  4)
hintTxt:SetJustifyH("LEFT")
hintTxt:SetJustifyV("MIDDLE")
hintTxt:SetTextColor(1, 0.75, 0.1)

-- ============================================================
-- ScrollFrame
-- ============================================================
local sf = CreateFrame("ScrollFrame", "WASecScrollFrame", win)
sf:SetPoint("TOPLEFT",     win, "TOPLEFT",     8,  -96)
sf:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", -26,  46)

local sb = CreateFrame("Slider", "WASecScrollBar", sf, "UIPanelScrollBarTemplate")
sb:SetPoint("TOPLEFT",    sf, "TOPRIGHT",    3, -16)
sb:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", 3,  16)
sb:SetMinMaxValues(0, 0)
sb:SetValueStep(ROW_H)
sb:SetValue(0)
sb:SetScript("OnValueChanged", function(self, val)
    sf:SetVerticalScroll(val)
end)

sf:EnableMouseWheel(true)
sf:SetScript("OnMouseWheel", function(self, delta)
    local cur = sb:GetValue()
    local lo, hi = sb:GetMinMaxValues()
    sb:SetValue(math.max(lo, math.min(hi, cur - delta * ROW_H * 3)))
end)

local content = CreateFrame("Frame", nil, sf)
content:SetWidth(sf:GetWidth() or (WINDOW_W - 38))
sf:SetScrollChild(content)

-- ============================================================
-- Zeilen-Cache
-- ============================================================
local rowCache = {}
local catCache = {}

local function GetRow(i)
    if rowCache[i] then return rowCache[i] end

    local row = CreateFrame("Frame", nil, content)
    row:SetHeight(ROW_H)
    row:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 8, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    row:SetBackdropColor(0, 0, 0, 0)
    row:SetBackdropBorderColor(0, 0, 0, 0)
    row:EnableMouse(true)
    row:SetScript("OnEnter", function(s) s:SetBackdropColor(0.15, 0.15, 0.2, 0.5) end)
    row:SetScript("OnLeave", function(s) s:SetBackdropColor(0, 0, 0, 0) end)

    local tog = CreateFrame("Button", nil, row)
    tog:SetSize(82, ROW_H - 4)
    tog:SetPoint("LEFT", row, "LEFT", 2, 0)
    SetBackdropSimple(tog, 0.25, 0.05, 0.05, 1)

    local togLbl = tog:CreateFontString(nil, "OVERLAY")
    togLbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    togLbl:SetAllPoints()
    togLbl:SetJustifyH("CENTER")

    local nameTxt = row:CreateFontString(nil, "OVERLAY")
    nameTxt:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    nameTxt:SetPoint("LEFT", tog, "RIGHT", 8, 0)
    nameTxt:SetWidth(140)
    nameTxt:SetJustifyH("LEFT")
    nameTxt:SetTextColor(0.9, 0.9, 0.9)

    local descTxt = row:CreateFontString(nil, "OVERLAY")
    descTxt:SetFont("Fonts\\FRIZQT__.TTF", 10)
    descTxt:SetPoint("LEFT",  nameTxt, "RIGHT", 4, 0)
    descTxt:SetPoint("RIGHT", row,     "RIGHT", -4, 0)
    descTxt:SetJustifyH("LEFT")
    descTxt:SetTextColor(0.5, 0.5, 0.5)

    row._tog     = tog
    row._togLbl  = togLbl
    row._nameTxt = nameTxt
    row._descTxt = descTxt
    rowCache[i]  = row
    return row
end

local function GetCatHeader(i)
    if catCache[i] then return catCache[i] end

    local hdr = CreateFrame("Frame", nil, content)
    hdr:SetHeight(CAT_H)
    SetBackdropSimple(hdr, 0.05, 0.05, 0.12, 0.85, 0.3, 0.2, 0.55)

    local lbl = hdr:CreateFontString(nil, "OVERLAY")
    lbl:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    lbl:SetPoint("LEFT", hdr, "LEFT", 10, 0)
    lbl:SetTextColor(1, 0.78, 0.0)
    hdr._lbl    = lbl
    catCache[i] = hdr
    return hdr
end

-- ============================================================
-- Einzelne Zeile rendern
-- ============================================================
local function RefreshRow(row, entry)
    local L       = WASecurityManager.L
    local key     = entry.key
    local blocked = WASecurityManagerDB[key]
    if blocked == nil then blocked = true end

    row._nameTxt:SetText(key)
    row._descTxt:SetText(L["DESC_" .. key] or key)

    local tog    = row._tog
    local togLbl = row._togLbl

    if blocked then
        togLbl:SetText("|cffff5555" .. L.TOGGLE_BLOCKED .. "|r")
        tog:SetBackdropColor(0.28, 0.05, 0.05, 1)
    else
        togLbl:SetText("|cff55ff55" .. L.TOGGLE_ALLOWED .. "|r")
        tog:SetBackdropColor(0.05, 0.22, 0.05, 1)
    end

    tog:SetScript("OnClick", function()
        WASecurityManager.SetBlocked(key, not WASecurityManagerDB[key])
        RefreshRow(row, entry)
    end)
    tog:SetScript("OnEnter", function(s)
        if WASecurityManagerDB[key] then
            s:SetBackdropColor(0.45, 0.1, 0.1, 1)
        else
            s:SetBackdropColor(0.1, 0.38, 0.1, 1)
        end
    end)
    tog:SetScript("OnLeave", function(s)
        if WASecurityManagerDB[key] then
            s:SetBackdropColor(0.28, 0.05, 0.05, 1)
        else
            s:SetBackdropColor(0.05, 0.22, 0.05, 1)
        end
    end)
end

-- ============================================================
-- Inhalt aufbauen
-- ============================================================
local function BuildContent()
    local L = WASecurityManager.L
    local W = sf:GetWidth() or (WINDOW_W - 38)
    content:SetWidth(W)

    local cats, seen = {}, {}
    for _, e in ipairs(WASecurityManager.MANAGED_FUNCTIONS) do
        if not seen[e.category] then
            seen[e.category] = true
            table.insert(cats, e.category)
        end
    end

    local yOff = -4
    local ci   = 0
    local ri   = 0

    for _, cat in ipairs(cats) do
        if ci > 0 then yOff = yOff - CAT_PAD end
        ci = ci + 1

        local hdr = GetCatHeader(ci)
        hdr:SetWidth(W - 4)
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", content, "TOPLEFT", 2, yOff)
        -- Kategoriename aus Locale (CAT_Lua, CAT_System, etc.)
        hdr._lbl:SetText(L["CAT_" .. cat] or cat)
        hdr:Show()
        yOff = yOff - CAT_H - 2

        for _, entry in ipairs(WASecurityManager.MANAGED_FUNCTIONS) do
            if entry.category == cat then
                ri = ri + 1
                local row = GetRow(ri)
                row:SetWidth(W - 4)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 2, yOff)
                RefreshRow(row, entry)
                row:Show()
                yOff = yOff - ROW_H
            end
        end
    end

    local x = ri + 1
    while rowCache[x] do rowCache[x]:Hide(); x = x + 1 end
    local y = ci + 1
    while catCache[y] do catCache[y]:Hide(); y = y + 1 end

    local totalH = math.abs(yOff) + 8
    content:SetHeight(totalH)
    local maxScroll = math.max(0, totalH - (sf:GetHeight() or 400))
    sb:SetMinMaxValues(0, maxScroll)
    sb:SetValue(0)
end

-- ============================================================
-- UI-Texte aktualisieren (nach Sprachwechsel)
-- ============================================================
local btnBlockAll, btnAllowAll, btnReconn, btnClose2  -- forward refs

local function RefreshUIText()
    local L = WASecurityManager.L
    titleTxt:SetText(L.TITLE)
    hintTxt:SetText(L.HINT_TEXT)

    -- Sprach-Button: aktive Sprache anzeigen
    local cur = WASecurityManagerDB and WASecurityManagerDB.locale or "enUS"
    if cur == "enUS" then
        langLbl:SetText("|cffffffff EN|r |cff888888 DE|r")
    else
        langLbl:SetText("|cff888888 EN|r |cffffffff DE|r")
    end

    if btnBlockAll then btnBlockAll._lbl:SetText(L.BTN_BLOCK_ALL) end
    if btnAllowAll then btnAllowAll._lbl:SetText(L.BTN_ALLOW_ALL) end
    if btnReconn   then btnReconn._lbl:SetText(L.BTN_RECONNECT)   end
    if btnClose2   then btnClose2._lbl:SetText(L.BTN_CLOSE)       end

    -- Status
    if WASecurityManager.hooked then
        statusLine:SetText(L.STATUS_ACTIVE)
    else
        statusLine:SetText(L.STATUS_ERROR .. (WASecurityManager.lastError or "?"))
    end
end

-- ============================================================
-- Sprach-Toggle
-- ============================================================
langBtn:SetScript("OnClick", function()
    local cur = WASecurityManagerDB.locale or "enUS"
    local new = (cur == "enUS") and "deDE" or "enUS"
    WASecurityManagerDB.locale = new
    WASecurityManager.SetLocale(new)
    RefreshUIText()
    BuildContent()
end)

-- ============================================================
-- Untere Buttons
-- ============================================================
local btnH = 24

btnBlockAll = MakeBtn(win, 130, btnH, "", function()
    WASecurityManager.SetAllBlocked(true)
    BuildContent()
end)
btnBlockAll:SetPoint("BOTTOMLEFT", win, "BOTTOMLEFT", 10, 12)

btnAllowAll = MakeBtn(win, 130, btnH, "", function()
    WASecurityManager.SetAllBlocked(false)
    BuildContent()
end)
btnAllowAll:SetPoint("LEFT", btnBlockAll, "RIGHT", 6, 0)

btnReconn = MakeBtn(win, 110, btnH, "", function()
    local ok, err = WASecurityManager.Reconnect()
    WASecurityManager.lastError = err
    local L = WASecurityManager.L
    RefreshUIText()
    if ok then
        DEFAULT_CHAT_FRAME:AddMessage(L.MSG_RECONNECTED)
    else
        DEFAULT_CHAT_FRAME:AddMessage(L.MSG_RECONNECT_ERR .. (err or "?") .. "|r")
    end
end)
btnReconn:SetPoint("LEFT", btnAllowAll, "RIGHT", 6, 0)

btnClose2 = MakeBtn(win, 76, btnH, "", function()
    win:Hide()
end)
btnClose2:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", -10, 12)

-- ============================================================
-- OnShow / Toggle
-- ============================================================
win:SetScript("OnShow", function()
    RefreshUIText()
    BuildContent()
end)

function WASecurityManager.ToggleUI()
    if win:IsShown() then
        win:Hide()
    else
        win:Show()
    end
end
