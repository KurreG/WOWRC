print("kuga00 loaded")

-- Function to get current combo points
function GetComboPointsCount()
    return GetComboPoints("player", "target") or 0
end

-- Function to get current energy
function GetEnergyCount()
    return UnitPower("player", 3) or 0  -- Power type 3 is Energy
end

-- Function to get current rage
function GetRageCount()
    return UnitPower("player", 1) or 0  -- Power type 1 is Rage
end

-- Function to get current focus
function GetFocusCount()
    return UnitPower("player", 2) or 0  -- Power type 2 is Focus
end

-- Function to get current mana
function GetManaCount()
    return UnitPower("player", 0) or 0  -- Power type 0 is Mana
end

-- Function to get current runic power
function GetRunicPowerCount()
    return UnitPower("player", 6) or 0  -- Power type 6 is RunicPower
end

-- Function to get current chi
function GetChiCount()
    return UnitPower("player", 12) or 0  -- Power type 12 is Chi
end

-- Function to get current soul shards
function GetSoulShardCount()
    return UnitPower("player", 7) or 0  -- Power type 7 is SoulShards
end

-- Function to get current holy power
function GetHolyPowerCount()
    return UnitPower("player", 9) or 0  -- Power type 9 is HolyPower
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
        stats.mana = GetManaCount()
        stats.holyPower = GetHolyPowerCount()
    elseif class == "MONK" then
        stats.chi = GetChiCount()
        stats.energy = GetEnergyCount()
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
    else
        stats.debug = "Class not recognized: " .. tostring(class)
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
statsText:SetText("Loading...")
statsText:SetTextColor(1, 1, 1, 1)  -- White text

-- Update function
local function UpdateClassStats()
    local success, err = pcall(function()
        local class, spec = GetPlayerClassAndSpec()
        local stats = GetClassRelevantStats()
        
        if stats and type(stats) == "table" then
            local statsDisplay = ""
            local first = true
            
            for key, value in pairs(stats) do
                -- Only process if key is string and value is number
                if type(key) == "string" and type(value) == "number" then
                    local displayKey = key:gsub("(%l)(%u)", "%1 %2"):gsub("^%l", string.upper)
                    local line = displayKey .. ": " .. value
                    
                    if not first then
                        statsDisplay = statsDisplay .. "\n"
                    end
                    statsDisplay = statsDisplay .. line
                    first = false
                end
            end
            
            if first then
                statsDisplay = "No stats available"
            end
            
            statsText:SetText(statsDisplay)
        else
            statsText:SetText("No stats available")
        end
    end)
end

-- Register for updates
local updateCounter = 0
infoFrame:SetScript("OnUpdate", function(self, elapsed)
    updateCounter = updateCounter + elapsed
    if updateCounter >= 0.5 then  -- Update every 0.5 seconds
        updateCounter = 0
        UpdateClassStats()
    end
end)

-- Show the frame
infoFrame:Show()