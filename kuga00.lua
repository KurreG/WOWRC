print("kuga00 loaded")

-- Saved settings (persisted via TOC SavedVariables)
-- kuga00Settings = { enabledClasses = { ROUGE=true, ... } }

-- Event frame to initialize saved vars
local evt = CreateFrame("Frame")
evt:RegisterEvent("ADDON_LOADED")
evt:SetScript("OnEvent", function(self, event, name)
    if name ~= "kuga00" then return end
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
    print("kuga00 settings loaded")
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
        if infoFrame then infoFrame:Show() end
        return
    elseif cmd == "disable" and cls ~= "" then
        cls = cls:upper()
        kuga00Settings.enabledClasses[cls] = false
        print("kuga00: disabled for class " .. cls)
        return
    elseif cmd == "status" then
        print("kuga00 class status:")
        for k, v in pairs(kuga00Settings.enabledClasses) do
            print(string.format("%s : %s", k, v and "enabled" or "disabled"))
        end
        return
    elseif cmd == "options" or cmd == "opt" then
        if not kuga00_CreateOptionsUI then
            -- create UI on demand
            CreateOptionsUI()
        end
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
    configFrame = CreateFrame("Frame", "kuga00ConfigFrame", UIParent)
    configFrame:SetSize(300, 360)
    configFrame:SetPoint("CENTER", 0, 0)
    configFrame:EnableMouse(true)

    local bg = configFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(configFrame)
    bg:SetColorTexture(0, 0, 0, 0.7)

    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", configFrame, "TOP", 0, -10)
    title:SetText("kuga00 Options")

    local classes = {"ROGUE","WARRIOR","HUNTER","WARLOCK","DEATHKNIGHT","PALADIN","MONK","DRUID","PRIEST","MAGE","SHAMAN"}
    local y = -40
    configFrame.checkboxes = {}
    for i, cls in ipairs(classes) do
        local cb = CreateFrame("CheckButton", "kuga00_cb_"..cls, configFrame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 16, y)
        cb.text:SetText(cls)
        local enabled = true
        if kuga00Settings and kuga00Settings.enabledClasses and type(kuga00Settings.enabledClasses[cls]) == "boolean" then
            enabled = kuga00Settings.enabledClasses[cls]
        end
        cb:SetChecked(enabled)
        cb:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            if not kuga00Settings then kuga00Settings = { enabledClasses = {} } end
            if not kuga00Settings.enabledClasses then kuga00Settings.enabledClasses = {} end
            kuga00Settings.enabledClasses[cls] = checked
        end)
        configFrame.checkboxes[cls] = cb
        y = y - 24
    end

    local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    closeBtn:SetSize(100, 24)
    closeBtn:SetPoint("BOTTOM", configFrame, "BOTTOM", 0, 12)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        configFrame:Hide()
    end)

    -- mark UI created
    kuga00_CreateOptionsUI = true
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
        local form = GetShapeshiftForm()
        if form == 1 then -- Bear form
            stats.rage = ensureNumber(GetRageCount())
        elseif form == 2 then -- Cat form
            stats.comboPoints = ensureNumber(GetComboPointsCount())
            stats.energy = ensureNumber(GetEnergyCount())
        else -- Caster form
            -- no tracked resource
        end
    elseif class == "PRIEST" or class == "MAGE" or class == "SHAMAN" then
        -- no tracked resource
    end
    
    return stats
end

-- Create a simple frame for text display
local infoFrame = CreateFrame("Frame", "ClassInfoDisplay", UIParent)
infoFrame:SetSize(300, 100)
infoFrame:SetPoint("CENTER", 0, -100)

-- Create text for stats display
local statsText = infoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
statsText:SetPoint("CENTER", infoFrame, "CENTER", 0, 0)
statsText:SetText("")
statsText:SetTextColor(1, 1, 1, 1)  -- White text

-- Update function
local function UpdateClassStats()
    local success, err = pcall(function()
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
                    local statStr = displayKey .. ": " .. tostring(numValue)

                    -- Color thresholds
                    if key == "chi" and safeAtLeast(numValue, 2) then
                        statStr = "|cff00ff00" .. statStr .. "|r"
                        highlight = true
                    end

                    table.insert(parts, statStr)
                end
            end
        end

        local finalText = "No stats available"
        if #parts > 0 then
            -- Build string manually instead of concat to avoid issues
            finalText = ""
            for i, part in ipairs(parts) do
                if i == 1 then
                    finalText = part
                else
                    finalText = finalText .. "\n" .. part
                end
            end
        end

        -- Always update without storing state
        statsText:SetText(finalText)
        -- Also tint the whole text if any stat is highlighted (so energy/chi green works even if color codes are stripped)
        if highlight then
            statsText:SetTextColor(0, 1, 0, 1)
        else
            statsText:SetTextColor(1, 1, 1, 1)
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