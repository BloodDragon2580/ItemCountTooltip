local _, ICT = ...

ICT:RegisterEvent("BAG_UPDATE_DELAYED")

local equippedBags = {}
for i = 1, 5 do
    tinsert(equippedBags, C_Container.ContainerIDToInventoryID(i))
end

local temp = {}
function ICT:BAG_UPDATE_DELAYED()
    wipe(temp)
    for bag = 0, 4 do
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

    for _, slot in ipairs(equippedBags) do
        local itemID = GetInventoryItemID("player", slot)
        local itemLink = GetInventoryItemLink("player", slot)
        local itemIcon = GetInventoryItemTexture("player", slot)
        local itemQuality = GetInventoryItemQuality("player", slot)
        if itemID and itemLink and itemIcon and itemQuality then
            if not temp[itemID] then
                temp[itemID] = {}
                temp[itemID][1] = 1
                temp[itemID][2] = string.match(itemLink, "|h%[(.+)%]|h")
                temp[itemID][3] = "|T" .. itemIcon .. ":0|t"
                temp[itemID][4] = itemQuality
            else
                temp[itemID][1] = temp[itemID][1] + 1
            end
        end
    end

    ICT:Save(temp, "bags")

    ICT:BAG_UPDATE_DELAYED2()

    ICT:UpdateTooltips()
end
