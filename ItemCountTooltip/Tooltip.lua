local addonName, ICT = ...

local function OnTooltipSetItem(tt)
    if not tt.counted then
        local _, link = tt:GetItem()
        if not link then return end
        local id = GetItemInfoInstant(link)
        if not id then return end        

        local result = ICT:Count(id)
        for _, t in pairs(result) do
            tt:AddDoubleLine(t[1], t[2])
        end

        tt:Show()
        tt.counted = true
    end
end

if TooltipDataProcessor then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
else
    GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
    ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
    if GameTooltip.ItemTooltip then
        GameTooltip.ItemTooltip.Tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
    end
end
local function GameTooltip_OnTooltipCleared(tt)
    tt.counted = false
end
GameTooltip:HookScript("OnTooltipCleared", GameTooltip_OnTooltipCleared)

local function ItemRefTooltip_OnTooltipSetItem(tt)
    local _, link = tt:GetItem()
    if not link then return end
    local id = GetItemInfoInstant(link)
    if not id then return end        

    local result = ICT:Count(id)
    for _, t in pairs(result) do
        tt:AddDoubleLine(t[1], t[2])
    end

    tt:Show()
end
