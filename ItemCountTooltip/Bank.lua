local _, ICT = ...

ICT:RegisterEvent("BANKFRAME_OPENED")
ICT:RegisterEvent("BANKFRAME_CLOSED")
ICT:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
ICT:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
ICT:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")

local temp = {}
local function ScanBankBag(bag)
    for slot = 1, GetContainerNumSlots(bag) do
        local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
        if itemID then
            if not temp[itemID] then
                temp[itemID] = {}
                temp[itemID][1] = itemCount
                temp[itemID][2] = string.match(itemLink, "|h%[(.+)%]|h")
                temp[itemID][3] = "|T" .. icon .. ":0|t"
                temp[itemID][4] = quality
            else
                temp[itemID][1] = temp[itemID][1] + itemCount
            end
        end
    end
end

local isBankOpen, updateRequired
local function ScanBank()
    if isBankOpen then
        updateRequired = false

        wipe(temp)

        for bag = 5, GetNumBankSlots()+4 do
            ScanBankBag(bag)
        end

        ScanBankBag(-1)

        ScanBankBag(-3)

        ICT:Save(temp, "bank")
    else
        updateRequired = true
    end
end

function ICT:BANKFRAME_OPENED()
    isBankOpen = true
    C_Timer.After(.5, ScanBank)
end

function ICT:BANKFRAME_CLOSED()
    isBankOpen = false
end

function ICT:PLAYERBANKBAGSLOTS_CHANGED()
    ScanBank()
end

function ICT:PLAYERBANKSLOTS_CHANGED()
    ScanBank()
end

function ICT:PLAYERREAGENTBANKSLOTS_CHANGED()
    ScanBank()
end

local function UpdateBankDB()
    for id, t in pairs(ICT_DB[ICT.realm][ICT.name]["bank"]) do
        local bank = GetItemCount(id, true) - GetItemCount(id)
        if t[1] ~= bank then
            if bank > 0 then
                t[1] = bank
            else
                t = nil
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == "Blizzard_TradeSkillUI" then
        TradeSkillFrame:HookScript("OnHide", function()
            if updateRequired then
                updateRequired = false
                UpdateBankDB()
            end
        end)
    end
end)
