local addonName, ICT = ...

local lastID, lastResult

local function GameTooltip_OnTooltipSetItem(tooltip, data)
    if data.id and data.id ~= lastID then
        lastID = data.id
        lastResult = ICT:Count(data.id)
    end

    if lastResult then
        for _, t in pairs(lastResult) do
            tooltip:AddDoubleLine(t[1], t[2])
        end
        tooltip:Show()
    end
end
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, GameTooltip_OnTooltipSetItem)

function ICT:UpdateTooltips()
    lastID = nil
    lastResult = nil
end
