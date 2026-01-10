-- Function to get current combo points
function GetComboPointsCount()
    return GetComboPoints("player", "target")
end

-- Function to get current energy
function GetEnergyCount()
    return UnitPower("player", Enum.PowerType.Energy)
end

-- Function to get current rage
function GetRageCount()
    return UnitPower("player", Enum.PowerType.Rage)
end

-- Function to get current focus
function GetFocusCount()
    return UnitPower("player", Enum.PowerType.Focus)
end

-- Function to get current mana
function GetManaCount()
    return UnitPower("player", Enum.PowerType.Mana)
end

-- Function to get current runic power
function GetRunicPowerCount()
    return UnitPower("player", Enum.PowerType.RunicPower)
end

-- Function to get current chi
function GetChiCount()
    return UnitPower("player", Enum.PowerType.Chi)
end

-- Function to get current soul shards
function GetSoulShardCount()
    return UnitPower("player", Enum.PowerType.SoulShards)
end

-- Function to get current holy power
function GetHolyPowerCount()
    return UnitPower("player", Enum.PowerType.HolyPower)
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
    
    if class == "ROGUE" then
        stats.comboPoints = GetComboPointsCount()
        stats.energy = GetEnergyCount()
    elseif class == "WARRIOR" then
        stats.rage = GetRageCount()
    elseif class == "HUNTER" then
        stats.focus = GetFocusCount()
    elseif class == "WARLOCK" then
        stats.soulShards = GetSoulShardCount()
    elseif class == "DEATHKNIGHT" then
        stats.runicPower = GetRunicPowerCount()
    elseif class == "PALADIN" then
--[[         stats.mana = GetManaCount() ]]
        stats.holyPower = GetHolyPowerCount()
    elseif class == "MONK" then
        stats.chi = GetChiCount()
--[[         stats.mana = GetManaCount() ]]
    elseif class == "DRUID" then
        local form = GetShapeshiftForm()
        if form == 1 then -- Bear form
            stats.rage = GetRageCount()
        elseif form == 2 then -- Cat form
            stats.comboPoints = GetComboPointsCount()
            stats.energy = GetEnergyCount()
        else -- Caster form
            stats.mana = GetManaCount()
        end
    elseif class == "PRIEST" or class == "MAGE" or class == "SHAMAN" then
        stats.mana = GetManaCount()
    end
    
    return stats
end

-- Create a frame to display class-specific stats
local statsFrame = CreateFrame("Frame", "ClassStatsDisplay", UIParent)
statsFrame:SetSize(250, 120)
statsFrame:SetPoint("CENTER", 0, 200)
statsFrame:SetMovable(true)
statsFrame:SetResizable(true)
statsFrame:SetMinResize(150, 80)
statsFrame:EnableMouse(true)

-- Create background
local bg = statsFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(statsFrame)
bg:SetColorTexture(0, 0, 0, 0.5)

-- Create text for class and spec display
local classSpecText = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
classSpecText:SetPoint("TOP", statsFrame, "TOP", 0, -10)
classSpecText:SetText("Class: Unknown")

-- Create text for stats display
local statsText = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statsText:SetPoint("TOP", classSpecText, "BOTTOM", 0, -10)
statsText:SetText("Loading...")

-- Update function
local function UpdateClassStats()
    local class, spec = GetPlayerClassAndSpec()
    local stats = GetClassRelevantStats()
    
    classSpecText:SetText(class .. " - " .. spec)
    
    local statsDisplay = ""
    for key, value in pairs(stats) do
        if statsDisplay ~= "" then
            statsDisplay = statsDisplay .. "\n"
        end
        -- Format the key name nicely
        local displayKey = key:gsub("(%l)(%u)", "%1 %2"):gsub("^%l", string.upper)
        statsDisplay = statsDisplay .. displayKey .. ": " .. value
    end
    
    if statsDisplay == "" then
        statsDisplay = "No stats available"
    end
    
    statsText:SetText(statsDisplay)
end

-- Register for updates
statsFrame:SetScript("OnUpdate", function(self, elapsed)
    UpdateClassStats()
end)

-- Make frame draggable and resizable
statsFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        local x = GetCursorPosition() / self:GetEffectiveScale()
        local y = GetCursorPosition() / self:GetEffectiveScale()
        local frameLeft = self:GetLeft()
        local frameBottom = self:GetBottom()
        local frameRight = self:GetRight()
        local frameTop = self:GetTop()
        
        -- Check if clicking near the bottom-right corner (resize handle area)
        if x > frameRight - 20 and y < frameBottom + 20 then
            self:StartSizing("BOTTOMRIGHT")
        else
            self:StartMoving()
        end
    end
end)

statsFrame:SetScript("OnMouseUp", function(self, button)
    self:StopMovingOrSizing()
end)