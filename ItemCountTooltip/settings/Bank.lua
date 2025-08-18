local _, ICT = ...

ICT:RegisterEvent("BANKFRAME_OPENED")
ICT:RegisterEvent("BANKFRAME_CLOSED")
ICT:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
-- Hinweis: PLAYERBANKBAGSLOTS_CHANGED und PLAYERREAGENTBANKSLOTS_CHANGED existieren nicht mehr in The War Within

local bags = {1, 2, 3, 4, 5, 6, 7}
local temp = {}

local function ScanBankBag(bag)
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info and info.itemID and info.stackCount and info.hyperlink and info.iconFileID and info.quality then
            if not temp[info.itemID] then
                temp[info.itemID] = {}
                temp[info.itemID][1] = info.stackCount
                temp[info.itemID][2] = string.match(info.hyperlink, "|h%[(.+)%]|h")
                temp[info.itemID][3] = "|T" .. info.iconFileID .. ":0|t"
                temp[info.itemID][4] = info.quality
            else
                temp[info.itemID][1] = temp[info.itemID][1] + info.stackCount
            end
        end
    end
end

local isBankOpen, updateRequired
local function ScanBank()
    if isBankOpen then
        updateRequired = false
        wipe(temp)

        -- Normale Bankslots
        for bag = 6, GetNumBankSlots() + 5 do
            ScanBankBag(bag)
        end

        -- Hauptbankfach
        ScanBankBag(-1)

        -- Reagenzienbank
        ScanBankBag(-3)

        -- Banktaschen-Slots selbst
        for _, slot in ipairs(bags) do
            local info = C_Container.GetContainerItemInfo(-4, slot)
            if info and info.itemID and info.hyperlink and info.iconFileID and info.quality then
                if not temp[info.itemID] then
                    temp[info.itemID] = {}
                    temp[info.itemID][1] = 1
                    temp[info.itemID][2] = string.match(info.hyperlink, "|h%[(.+)%]|h")
                    temp[info.itemID][3] = "|T" .. info.iconFileID .. ":0|t"
                    temp[info.itemID][4] = info.quality
                else
                    temp[info.itemID][1] = temp[info.itemID][1] + 1
                end
            end
        end

        ICT:Save(temp, "bank")
    else
        updateRequired = true
    end
end

function ICT:BANKFRAME_OPENED()
    isBankOpen = true
    C_Timer.After(0.5, ScanBank)
end

function ICT:BANKFRAME_CLOSED()
    isBankOpen = false
end

local timer

function ICT:BAG_UPDATE_DELAYED2()
    if timer then
        timer:Cancel()
    end
    timer = C_Timer.NewTimer(0.5, ScanBank)
end

function ICT:PLAYERBANKSLOTS_CHANGED()
    if timer then
        timer:Cancel()
    end
    timer = C_Timer.NewTimer(0.5, ScanBank)
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
