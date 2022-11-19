local addonName, ICT = ...
local L = ICT.L

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

function ICT:RegisterEvent(event)
    frame:RegisterEvent(event)
end

function ICT:UnregisterEvent(event)
    frame:UnregisterEvent(event)
end

function ICT:ADDON_LOADED(arg1)
    if arg1 == "ItemCountTooltip" then
        if type(ICT_DB) ~= "table" then ICT_DB = {} end
    end
end

function ICT:PLAYER_ENTERING_WORLD()
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    ICT.name, ICT.realm = UnitFullName("player")
    ICT.faction = UnitFactionGroup("player")

    if type(ICT_DB[ICT.realm]) ~= "table" then ICT_DB[ICT.realm] = {} end
    if type(ICT_DB[ICT.realm][ICT.name]) ~= "table" then ICT_DB[ICT.realm][ICT.name] = {
        ["faction"] = ICT.faction,
        ["class"] = select(2, UnitClass("player")),
        ["bags"] = {},
        ["bank"] = {},
        ["equipped"] = {},
    } end
end

frame:SetScript("OnEvent", function(self, event, ...)
    ICT[event](ICT, ...)
end)

function ICT:Save(temp, category)
    ICT_DB[ICT.realm][ICT.name][category] = temp
end

local function ColorByClass(class, str)
    return "|c" .. RAID_CLASS_COLORS[class].colorStr .. str .. "|r"
end

local function CountOnCharacter(name, id)
    local equipped, bags, bank = 0, 0, 0
    local result = {}

    if ICT_DB[ICT.realm][name]["equipped"][id] then
        equipped = ICT_DB[ICT.realm][name]["equipped"][id][1]
        table.insert(result, L["Equipped"] .. ": " .. equipped)
    end

    if ICT_DB[ICT.realm][name]["bags"][id] then
        bags = ICT_DB[ICT.realm][name]["bags"][id][1]
        table.insert(result, L["Bags"] .. ": " .. bags)
    end

    if ICT_DB[ICT.realm][name]["bank"][id] then
        bank = ICT_DB[ICT.realm][name]["bank"][id][1]
        table.insert(result, L["Bank"] .. ": " .. bank)
    end
    
    if equipped + bags + bank > 0 then
        local class = ICT_DB[ICT.realm][name]["class"]
        local cname = ColorByClass(class, name)
        if #result == 1 then
            return cname, ColorByClass(class, result[1])
        else
            return cname, ColorByClass(class, equipped + bags + bank).." |cFFBBBBBB("..table.concat(result, ", ")..")"
        end
    end
end

local function CountOnCurrentCharacter(id)
    local equipped = 0, 0, 0
    local bags = GetItemCount(id)
    local bank = GetItemCount(id, true) - bags
    local result = {}

    if ICT_DB[ICT.realm][ICT.name]["equipped"][id] then
        equipped = ICT_DB[ICT.realm][ICT.name]["equipped"][id][1]
        table.insert(result, L["Equipped"] .. ": " .. equipped)

        bags = bags - equipped
    end

    if bags > 0 then
        table.insert(result, L["Bags"] .. ": " .. bags)
    end

    if bank > 0 then
        table.insert(result, L["Bank"] .. ": " .. bank)
    end

    if ICT_DB[ICT.realm][ICT.name]["bank"][id] then
        if bank ~= ICT_DB[ICT.realm][ICT.name]["bank"][id][1] then
            if bank > 0 then
                ICT_DB[ICT.realm][ICT.name]["bank"][id][1] = bank
            else
                ICT_DB[ICT.realm][ICT.name]["bank"][id] = nil
            end
        end
    end
    
    if equipped + bags + bank > 0 then
        local class = ICT_DB[ICT.realm][ICT.name]["class"]
        local cname = ColorByClass(class, ICT.name)
        if #result == 1 then
            return cname, ColorByClass(class, result[1])
        else
            return cname, ColorByClass(class, equipped + bags + bank).." |cFFBBBBBB("..table.concat(result, ", ")..")"
        end
    end
end

function ICT:Count(id)
    if not ICT_DB[ICT.realm] then return end

    local result = {}
    for name, t in pairs(ICT_DB[ICT.realm]) do
        if name ~= ICT.name and t["faction"] == ICT.faction then
            local text1, text2 = CountOnCharacter(name, id)
            if text1 and text2 then
                table.insert(result, {text1, text2})
            end
        end
    end
    local text1, text2 = CountOnCurrentCharacter(id)
    if text1 and text2 then
        table.insert(result, {text1, text2})
    end
    return result
end

local ICT = "|cFF00CCFFItemCountTooltip|r "
SLASH_ItemCountTooltip1 = "/ICT"
function SlashCmdList.ItemCountTooltip(msg, editbox)
end
