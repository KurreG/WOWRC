-- Saved settings (persisted via TOC SavedVariables)
-- kuga00Settings = { enabledClasses = { ROUGE=true, ... } }

-- Declare infoFrame globally so it can be accessed from options UI
local infoFrame

-- Event frame to initialize saved vars
local evt = CreateFrame("Frame")
evt:RegisterEvent("ADDON_LOADED")
evt:SetScript("OnEvent", function(self, event, name)
    if name ~= "kuga00" then return end
    local function resolveVersion()
        -- Try modern API first
        if C_AddOns and C_AddOns.GetAddOnMetadata then
            local v = C_AddOns.GetAddOnMetadata(name, "Version") or C_AddOns.GetAddOnMetadata("kuga00", "Version")
            if v and v ~= "" then return v end
        end
        -- Fallback to legacy API
        if GetAddOnMetadata then
            local v = GetAddOnMetadata(name, "Version") or GetAddOnMetadata("kuga00", "Version")
            if v and v ~= "" then return v end
        end
        -- Last resort: hardcoded fallback matching TOC
        return "0.1beta"
    end

    local ver = resolveVersion()
    print("kuga00 v" .. tostring(ver) .. " loaded")
    print("Access options via: ESC > Interface > AddOns > kuga00, or type /kuga00 opt")
    if not kuga00Settings then kuga00Settings = {} end
    if not kuga00Settings.enabledClasses then
        kuga00Settings.enabledClasses = {
            ROGUE = true,
            WARRIOR = true,
            HUNTER = true,
            WARLOCK = true,
            DEATHKNIGHT = true,
            PALADIN = true,
            MONK = true,
            DRUID = true,
            PRIEST = true,
            MAGE = true,
            SHAMAN = true,
        }
    end
    if not kuga00Settings.thresholds then
        kuga00Settings.thresholds = {
            chi = 2,
            holyPower = 3,
            comboPoints = 5,
            energy = 55,
            rage = 50,
            focus = 50,
            runicPower = 60,
            soulShards = 3,
        }
    end
    if not kuga00Settings.colors then
        kuga00Settings.colors = {
            highlight = { r = 0, g = 1, b = 0 }, -- green
        }
    end
    if kuga00Settings.showPowerNames == nil then
        kuga00Settings.showPowerNames = true -- default to showing names
    end
    if not kuga00Settings.textSize then
        kuga00Settings.textSize = 20 -- default to medium
    end
    if not kuga00Settings.position then
        kuga00Settings.position = { x = 0, y = -100 } -- default position
    end
    print("kuga00 settings loaded")
    
    -- Apply saved position to the frame
    if infoFrame then
        infoFrame:ClearAllPoints()
        infoFrame:SetPoint("CENTER", kuga00Settings.position.x, kuga00Settings.position.y)
    end
    
    -- Create and register options UI at load time
    CreateOptionsUI()
end)

-- Slash command to manage per-class enable/disable
SLASH_KUGA1 = "/kuga00"
SlashCmdList["KUGA"] = function(msg)
    local cmd, cls = msg:match("^(%S+)%s*(%S*)")
    if not cmd then
        print("Usage: /kuga00 enable|disable <CLASS> | /kuga00 status")
        return
    end
    cmd = cmd:lower()
    if cmd == "enable" and cls ~= "" then
        cls = cls:upper()
        kuga00Settings.enabledClasses[cls] = true
        print("kuga00: enabled for class " .. cls)
        print("Type /reload to apply changes")
        if infoFrame then infoFrame:Show() end
        return
    elseif cmd == "disable" and cls ~= "" then
        cls = cls:upper()
        kuga00Settings.enabledClasses[cls] = false
        print("kuga00: disabled for class " .. cls)
        print("Type /reload to apply changes")
        return
    elseif cmd == "status" then
        print("kuga00 class status:")
        for k, v in pairs(kuga00Settings.enabledClasses) do
            print(string.format("%s : %s", k, v and "enabled" or "disabled"))
        end
        return
    elseif cmd == "options" or cmd == "opt" then
        if configFrame then
            configFrame:Show()
        end
        return
    else
        print("Usage: /kuga00 enable|disable <CLASS> | /kuga00 status")
    end
end

-- Create options UI with checkboxes per class
function CreateOptionsUI()
    if configFrame then return end
    -- Ensure settings are initialized
    if not kuga00Settings then
        print("kuga00: Settings not loaded yet")
        return
    end
    -- Ensure position table exists
    if not kuga00Settings.position then
        kuga00Settings.position = { x = 0, y = -100 }
    end
    configFrame = CreateFrame("Frame", "kuga00ConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    configFrame:SetSize(500, 600)
    configFrame:SetPoint("CENTER", 0, 0)
    configFrame:SetMovable(true)
    configFrame:SetResizable(true)
    -- Use SetResizeBounds for compatibility across client versions
    if configFrame.SetResizeBounds then
        configFrame:SetResizeBounds(380, 420)
    end
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)

    -- Resize handle (bottom-right)
    local resizeButton = CreateFrame("Button", nil, configFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", -6, 6)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetScript("OnMouseDown", function(self)
        self:GetParent():StartSizing("BOTTOMRIGHT")
        self:GetParent():SetUserPlaced(true)
    end)
    resizeButton:SetScript("OnMouseUp", function(self)
        self:GetParent():StopMovingOrSizing()
    end)

    -- Adjust scroll width when frame is resized
    configFrame:SetScript("OnSizeChanged", function(self, width)
        local usableWidth = width - 50
        if usableWidth < 300 then usableWidth = 300 end
        if self.scrollChild then
            self.scrollChild:SetWidth(usableWidth)
        end
    end)

    configFrame.title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    configFrame.title:SetPoint("TOP", 0, -5)
    configFrame.title:SetText("kuga00 Options")

    -- Scroll frame for all content
    local scrollFrame = CreateFrame("ScrollFrame", nil, configFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(450, 1200)  -- Increased height to accommodate all content
    
    -- Keep references for resize handling
    configFrame.scrollFrame = scrollFrame
    configFrame.scrollChild = scrollChild

    -- Class enable/disable checkboxes
    local classLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    classLabel:SetPoint("TOPLEFT", 10, -10)
    classLabel:SetText("Enable/Disable Classes:")

    local classes = {"ROGUE","WARRIOR","HUNTER","WARLOCK","DEATHKNIGHT","PALADIN","MONK","DRUID","PRIEST","MAGE","SHAMAN"}
    local y = -35
    configFrame.checkboxes = {}
    for i, cls in ipairs(classes) do
        local cb = CreateFrame("CheckButton", "kuga00_cb_"..cls, scrollChild, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 20, y)
        cb.text:SetText(cls)
        local enabled = kuga00Settings.enabledClasses[cls]
        cb:SetChecked(enabled)
        cb:SetScript("OnClick", function(self)
            kuga00Settings.enabledClasses[cls] = self:GetChecked()
            local status = self:GetChecked() and "enabled" or "disabled"
            print("kuga00: " .. status .. " for class " .. cls)
            print("Type /reload to apply changes")
        end)
        configFrame.checkboxes[cls] = cb
        y = y - 24
    end
    -- Display options
    local displayY = y - 15
    local displayLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    displayLabel:SetPoint("TOPLEFT", 10, displayY)
    displayLabel:SetText("Display Options:")
    
    displayY = displayY - 25
    local showNamesCheck = CreateFrame("CheckButton", "kuga00ShowNamesCheck", scrollChild, "UICheckButtonTemplate")
    showNamesCheck:SetPoint("TOPLEFT", 20, displayY)
    showNamesCheck:SetChecked(kuga00Settings.showPowerNames)
    showNamesCheck.text:SetText("Show Power Names (e.g., 'Chi: 5' vs '5')")
    showNamesCheck:SetScript("OnClick", function(self)
        kuga00Settings.showPowerNames = self:GetChecked()
        print("kuga00: Power names " .. (kuga00Settings.showPowerNames and "enabled" or "disabled"))
    end)
    
    -- Text size dropdown
    displayY = displayY - 30
    local sizeLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeLabel:SetPoint("TOPLEFT", 20, displayY)
    sizeLabel:SetText("Text Size:")
    
    local textSizeDropdown = CreateFrame("Frame", "kuga00TextSizeDropdown", scrollChild, "UIDropDownMenuTemplate")
    textSizeDropdown:SetPoint("TOPLEFT", 110, displayY - 5)
    
    local textSizes = {18, 20, 24, 28, 32, 36, 40, 44}
    local textSizeLabels = {"Small (18)", "Medium (20)", "Large (24)", "Extra Large (28)", "Huge (32)", "Massive (36)", "Giant (40)", "Colossal (44)"}
    
    UIDropDownMenu_Initialize(textSizeDropdown, function()
        for i, size in ipairs(textSizes) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = textSizeLabels[i]
            info.value = size
            info.checked = (kuga00Settings.textSize == size)
            info.func = function()
                kuga00Settings.textSize = size
                UIDropDownMenu_SetSelectedValue(textSizeDropdown, size)
                print("kuga00: Text size set to " .. size)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    UIDropDownMenu_SetSelectedValue(textSizeDropdown, kuga00Settings.textSize)
    
    -- Position settings
    displayY = displayY - 40
    local positionLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    positionLabel:SetPoint("TOPLEFT", 10, displayY)
    positionLabel:SetText("Position:")
    
    displayY = displayY - 30
    
    -- X position slider
    local xPosSlider = CreateFrame("Slider", "kuga00XPosSlider", scrollChild, "OptionsSliderTemplate")
    xPosSlider:SetPoint("TOPLEFT", 20, displayY)
    xPosSlider:SetMinMaxValues(-500, 500)
    xPosSlider:SetValue((kuga00Settings.position and kuga00Settings.position.x) or 0)
    xPosSlider:SetValueStep(1)
    xPosSlider:SetObeyStepOnDrag(true)
    xPosSlider.tooltipText = "Move counter left/right"
    getglobal(xPosSlider:GetName() .. 'Low'):SetText("Left")
    getglobal(xPosSlider:GetName() .. 'High'):SetText("Right")
    getglobal(xPosSlider:GetName() .. 'Text'):SetText("Horizontal: " .. xPosSlider:GetValue())
    
    xPosSlider:SetScript("OnValueChanged", function(self, value)
        if not kuga00Settings.position then kuga00Settings.position = {} end
        kuga00Settings.position.x = value
        getglobal(self:GetName() .. 'Text'):SetText("Horizontal: " .. value)
        if infoFrame then
            infoFrame:ClearAllPoints()
            infoFrame:SetPoint("CENTER", UIParent, "CENTER", kuga00Settings.position.x, kuga00Settings.position.y or -100)
        end
    end)
    
    displayY = displayY - 40
    
    -- Y position slider
    local yPosSlider = CreateFrame("Slider", "kuga00YPosSlider", scrollChild, "OptionsSliderTemplate")
    yPosSlider:SetPoint("TOPLEFT", 20, displayY)
    yPosSlider:SetMinMaxValues(-500, 500)
    yPosSlider:SetValue((kuga00Settings.position and kuga00Settings.position.y) or -100)
    yPosSlider:SetValueStep(1)
    yPosSlider:SetObeyStepOnDrag(true)
    yPosSlider.tooltipText = "Move counter up/down"
    getglobal(yPosSlider:GetName() .. 'Low'):SetText("Down")
    getglobal(yPosSlider:GetName() .. 'High'):SetText("Up")
    getglobal(yPosSlider:GetName() .. 'Text'):SetText("Vertical: " .. yPosSlider:GetValue())
    
    yPosSlider:SetScript("OnValueChanged", function(self, value)
        if not kuga00Settings.position then kuga00Settings.position = {} end
        kuga00Settings.position.y = value
        getglobal(self:GetName() .. 'Text'):SetText("Vertical: " .. value)
        if infoFrame then
            infoFrame:ClearAllPoints()
            infoFrame:SetPoint("CENTER", UIParent, "CENTER", kuga00Settings.position.x or 0, kuga00Settings.position.y)
        end
    end)
    
    displayY = displayY - 30
    
    -- Reset position button
    local resetPosBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    resetPosBtn:SetSize(150, 24)
    resetPosBtn:SetPoint("TOPLEFT", 20, displayY)
    resetPosBtn:SetText("Reset Position")
    resetPosBtn:SetScript("OnClick", function()
        if not kuga00Settings.position then kuga00Settings.position = {} end
        kuga00Settings.position.x = 0
        kuga00Settings.position.y = -100
        xPosSlider:SetValue(0)
        yPosSlider:SetValue(-100)
        if infoFrame then
            infoFrame:ClearAllPoints()
            infoFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
        end
        print("kuga00: Position reset to default")
    end)
    
    displayY = displayY - 40
    
    -- Threshold settings
    local thresholdY = displayY
    local thresholdLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    thresholdLabel:SetPoint("TOPLEFT", 10, thresholdY)
    thresholdLabel:SetText("Threshold Values:")

    local thresholds = {
        {key = "chi", label = "Chi", min = 1, max = 6},
        {key = "holyPower", label = "Holy Power", min = 1, max = 5},
        {key = "comboPoints", label = "Combo Points", min = 1, max = 7},
    }

    configFrame.sliders = {}
    thresholdY = thresholdY - 25
    for i, threshold in ipairs(thresholds) do
        local slider = CreateFrame("Slider", "kuga00Slider"..threshold.key, scrollChild, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", 20, thresholdY)
        slider:SetMinMaxValues(threshold.min, threshold.max)
        slider:SetValue(kuga00Settings.thresholds[threshold.key] or threshold.min)
        slider:SetValueStep(1)
        slider:SetObeyStepOnDrag(true)
        slider.tooltipText = "Set threshold for " .. threshold.label
        getglobal(slider:GetName() .. 'Low'):SetText(threshold.min)
        getglobal(slider:GetName() .. 'High'):SetText(threshold.max)
        getglobal(slider:GetName() .. 'Text'):SetText(threshold.label .. ": " .. slider:GetValue())
        
        slider:SetScript("OnValueChanged", function(self, value)
            kuga00Settings.thresholds[threshold.key] = value
            getglobal(self:GetName() .. 'Text'):SetText(threshold.label .. ": " .. value)
        end)
        
        configFrame.sliders[threshold.key] = slider
        thresholdY = thresholdY - 40
    end

    -- Color picker
    local colorY = thresholdY - 10
    local colorLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    colorLabel:SetPoint("TOPLEFT", 10, colorY)
    colorLabel:SetText("Highlight Color:")

    local colorButton = CreateFrame("Button", nil, scrollChild, "BackdropTemplate")
    colorButton:SetPoint("TOPLEFT", 20, colorY - 25)
    colorButton:SetSize(40, 20)
    colorButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    local c = kuga00Settings.colors and kuga00Settings.colors.highlight
    if c and type(c.r) == "number" and type(c.g) == "number" and type(c.b) == "number" then
        if CreateColor then
            pcall(function()
                colorButton:SetBackdropColor(CreateColor(c.r, c.g, c.b, 1))
            end)
        else
            pcall(function()
                colorButton:SetBackdropColor({r = c.r, g = c.g, b = c.b, a = 1})
            end)
        end
    else
        -- Set default green color
        if CreateColor then
            pcall(function()
                colorButton:SetBackdropColor(CreateColor(0, 1, 0, 1))
            end)
        else
            pcall(function()
                colorButton:SetBackdropColor({r = 0, g = 1, b = 0, a = 1})
            end)
        end
    end

    colorButton:SetScript("OnClick", function()
        print("To change the highlight color, edit your SavedVariables:")
        print("  /kuga00Settings.colors.highlight = {r = 1, g = 0, b = 0}  -- red")
        print("  /kuga00Settings.colors.highlight = {r = 0, g = 1, b = 0}  -- green (default)")
        print("  /kuga00Settings.colors.highlight = {r = 0, g = 0, b = 1}  -- blue")
        print("Values should be 0-1 for each color component (R, G, B)")
    end)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    closeBtn:SetSize(100, 24)
    closeBtn:SetPoint("BOTTOM", 0, 10)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        configFrame:Hide()
    end)
    
    -- Hide frame by default (only show when user opens it)
    configFrame:Hide()
    
    -- Register with Interface Options
    configFrame.name = "kuga00"
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(configFrame)
    elseif Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(configFrame, "kuga00")
        Settings.RegisterAddOnCategory(category)
    end
end

-- Function to get current combo points
function GetComboPointsCount()
    local result = GetComboPoints("player", "target")
    return type(result) == "number" and result or 0
end

-- Function to get current energy
function GetEnergyCount()
    local result = UnitPower("player", 3)
    return type(result) == "number" and result or 0
end

-- Function to get current rage
function GetRageCount()
    local result = UnitPower("player", 1)
    return type(result) == "number" and result or 0
end

-- Function to get current focus
function GetFocusCount()
    local result = UnitPower("player", 2)
    return type(result) == "number" and result or 0
end

-- Function to get current mana
function GetManaCount()
    local result = UnitPower("player", 0)
    return type(result) == "number" and result or 0
end

-- Function to get current runic power
function GetRunicPowerCount()
    local result = UnitPower("player", 6)
    return type(result) == "number" and result or 0
end

-- Function to get current maelstrom weapon stacks
function GetMaelstromCount()
    -- Use only C_UnitAuras (combat-safe, no AuraUtil/UnitBuff)
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        -- Retail spellID for Maelstrom Weapon
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(344179)
        if aura then
            if aura.applications then return aura.applications end
            if aura.charges then return aura.charges end
        end
        -- Legacy spellID fallback (older expansions)
        local legacy = C_UnitAuras.GetPlayerAuraBySpellID(187878)
        if legacy then
            if legacy.applications then return legacy.applications end
            if legacy.charges then return legacy.charges end
        end
    end

    -- If C_UnitAuras missing, return 0
    return 0
end

-- Function to get current chi
function GetChiCount()
    local result = UnitPower("player", 12)
    return type(result) == "number" and result or 0
end

-- Function to get current soul shards
function GetSoulShardCount()
    local result = UnitPower("player", 7)
    return type(result) == "number" and result or 0
end

-- Function to get current holy power
function GetHolyPowerCount()
    local result = UnitPower("player", 9)
    return type(result) == "number" and result or 0
end

-- Function to get player class and spec
function GetPlayerClassAndSpec()
    local class = UnitClassBase("player")
    local spec = GetSpecialization()
    local specName = spec and select(2, GetSpecializationInfo(spec)) or "Unknown"
    return class, specName
end

-- Function to get relevant stats for each class
function GetClassRelevantStats()
    local class = UnitClassBase("player")
    local stats = {}
    
    -- Helper to ensure numeric conversion
    local function ensureNumber(val)
        if type(val) == "number" then return val end
        return 0
    end
    
    if class == "ROGUE" then
        stats.comboPoints = ensureNumber(GetComboPointsCount())
        stats.energy = ensureNumber(GetEnergyCount())
    elseif class == "WARRIOR" then
        stats.rage = ensureNumber(GetRageCount())
    elseif class == "HUNTER" then
        stats.focus = ensureNumber(GetFocusCount())
    elseif class == "WARLOCK" then
        stats.soulShards = ensureNumber(GetSoulShardCount())
    elseif class == "DEATHKNIGHT" then
        stats.runicPower = ensureNumber(GetRunicPowerCount())
    elseif class == "PALADIN" then
        stats.holyPower = ensureNumber(GetHolyPowerCount())
    elseif class == "MONK" then
        local spec = GetSpecialization()
        if spec == 1 then -- Brewmaster
            -- no tracked resource
        elseif spec == 3 then -- Windwalker
            stats.chi = ensureNumber(GetChiCount())
        else -- Mistweaver
            -- no tracked resource
        end
    elseif class == "DRUID" then
        local spec = GetSpecialization()
        local form = GetShapeshiftForm()
        -- Only track resources for Feral (spec 2) and Guardian (spec 3)
        if spec == 3 and form == 1 then -- Guardian in Bear form
            stats.rage = ensureNumber(GetRageCount())
        elseif spec == 2 and form == 2 then -- Feral in Cat form
            stats.comboPoints = ensureNumber(GetComboPointsCount())
        else -- Balance, Resto, or wrong form
            -- no tracked resource
        end
    elseif class == "PRIEST" or class == "MAGE" or class == "SHAMAN" then
        -- no tracked resource
    end
    
    return stats
end

-- Create a simple frame for text display
infoFrame = CreateFrame("Frame", "ClassInfoDisplay", UIParent)
infoFrame:SetSize(300, 100)
-- Use saved position settings (will be updated after settings load)
local posX = 0
local posY = -100
infoFrame:SetPoint("CENTER", UIParent, "CENTER", posX, posY)

-- Create text for stats display
local statsText = infoFrame:CreateFontString(nil, "OVERLAY")
statsText:SetFont("Fonts\\FRIZQT__.TTF", 16) -- default size, will be updated once settings load
statsText:SetPoint("CENTER", infoFrame, "CENTER", 0, 0)
statsText:SetText("")
statsText:SetTextColor(1, 1, 1, 1)  -- White text

-- Update function
local function UpdateClassStats()
    local success, err = pcall(function()
        -- Update text size if settings exist
        if statsText and kuga00Settings and kuga00Settings.textSize then
            statsText:SetFont("Fonts\\FRIZQT__.TTF", kuga00Settings.textSize)
        end
        
        local class, spec = GetPlayerClassAndSpec()
        -- respect per-class enable/disable settings (default enabled)
        local enabled = true
        if kuga00Settings and kuga00Settings.enabledClasses and type(class) == "string" then
            local flag = kuga00Settings.enabledClasses[class]
            if type(flag) == "boolean" then enabled = flag end
        end

        if not enabled then
            -- hide the info frame when disabled for this class to avoid showing "Disabled" text
            if infoFrame and infoFrame:IsShown() then
                infoFrame:Hide()
            end
            return
        else
            if infoFrame and not infoFrame:IsShown() then
                infoFrame:Show()
            end
        end

        local stats = GetClassRelevantStats()
        local parts = {}
        local highlight = false

        -- helper to guard against protected/secret values when comparing
        local function safeAtLeast(val, threshold)
            if type(val) ~= "number" then return false end
            local ok, res = pcall(function()
                return val >= threshold
            end)
            return ok and res or false
        end
        if stats and type(stats) == "table" then
            for key, value in pairs(stats) do
                if type(key) == "string" and type(value) == "number" then
                    local numValue = tonumber(value) or 0
                    local displayKey = key:gsub("(%l)(%u)", "%1 %2"):gsub("^%l", string.upper)
                    local statStr
                    if kuga00Settings.showPowerNames then
                        statStr = displayKey .. ": " .. tostring(numValue)
                    else
                        statStr = tostring(numValue)
                    end

                    -- Color thresholds using saved settings
                    local threshold = kuga00Settings.thresholds[key]
                    if threshold and safeAtLeast(numValue, threshold) then
                        local c = kuga00Settings.colors and kuga00Settings.colors.highlight
                        if c and type(c.r) == "number" and type(c.g) == "number" and type(c.b) == "number" then
                            local colorCode = string.format("|cff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
                            statStr = colorCode .. statStr .. "|r"
                            highlight = true
                        else
                            highlight = true
                        end
                    end

                    table.insert(parts, statStr)
                end
            end
        end

        local finalText = ""
        if #parts > 0 then
            -- Build string manually instead of concat to avoid issues
            for i, part in ipairs(parts) do
                if i == 1 then
                    finalText = part
                else
                    finalText = finalText .. "\n" .. part
                end
            end
            -- Show frame and update text
            if infoFrame and not infoFrame:IsShown() then
                infoFrame:Show()
            end
            statsText:SetText(finalText)
            -- Also tint the whole text if any stat is highlighted
            if highlight then
                local c = kuga00Settings.colors and kuga00Settings.colors.highlight
                if c and type(c.r) == "number" and type(c.g) == "number" and type(c.b) == "number" then
                    if CreateColor then
                        statsText:SetTextColor(CreateColor(c.r, c.g, c.b, 1))
                    else
                        statsText:SetTextColor(c.r, c.g, c.b, 1)
                    end
                else
                    statsText:SetTextColor(0, 1, 0, 1)  -- Default green
                end
            else
                statsText:SetTextColor(1, 1, 1, 1)
            end
        else
            -- Hide frame when no stats to display
            if infoFrame and infoFrame:IsShown() then
                infoFrame:Hide()
            end
        end
    end)
    if not success then
        -- on error, do not spam UI; print to chat once
        print("kuga00: UpdateClassStats error: " .. tostring(err))
    end
end

-- Register for updates
local updateCounter = 0
infoFrame:SetScript("OnUpdate", function(self, elapsed)
    updateCounter = updateCounter + elapsed
    if updateCounter >= 0.1 then  -- Update every 0.1 seconds
        updateCounter = 0
        UpdateClassStats()
    end
end)

-- Show the frame
infoFrame:Show()