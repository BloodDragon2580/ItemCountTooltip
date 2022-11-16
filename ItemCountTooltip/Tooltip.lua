local addonName, ICT = ...

local function GameTooltip_OnTooltipSetItem(tt)
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
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, GameTooltip_OnTooltipSetItem)


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
ItemRefTooltip:HookScript("GameTooltip_OnTooltipSetItem", ItemRefTooltip_OnTooltipSetItem)
