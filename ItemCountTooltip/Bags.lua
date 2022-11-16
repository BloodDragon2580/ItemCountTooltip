local _, ICT = ...

ICT:RegisterEvent("BAG_UPDATE_DELAYED")

local temp = {}
function ICT:BAG_UPDATE_DELAYED()
    wipe(temp)
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = C_Container.GetContainerItemInfo(bag, slot)
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
    ICT:Save(temp, "bags")
end
