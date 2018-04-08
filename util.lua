local SU = StockUp
SU.util = {
    LAM = LibStub("LibAddonMenu-2.0"),
    LSC = LibStub("LibSlashCommander"),
}

local util = SU.util

function util.SystemMessage(message)
    if CHAT_SYSTEM.primaryContainer then
        CHAT_SYSTEM.primaryContainer:OnChatEvent(nil, message, CHAT_CATEGORY_SYSTEM)
    else
        CHAT_SYSTEM:AddMessage(message)
    end
end

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