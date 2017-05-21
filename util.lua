local SU = StockUp
SU.util = {}

local strings = SU.strings
local util = SU.util
util.LAM = LibStub("LibAddonMenu-2.0")
util.LSC = LibStub("LibSlashCommander")

function util.GetItemInfo(bagId, slotIndex)
    local itemLink, itemId

    if bagId then
        itemLink = GetItemLink(bagId, slotIndex)
    else
        itemLink = GetStoreItemLink(slotIndex)
    end
    itemId = select(4, ZO_LinkHandler_ParseLink(itemLink))

    return itemLink, itemId
end

function util.GetItemInfoFromSlot(slot)
    return util.GetItemInfo(slot.bagId, slot.slotIndex or slot.index)
end