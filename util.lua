local SU = StockUp
SU.util = {
    LAM = LibStub("LibAddonMenu-2.0"),
    LSC = LibStub("LibSlashCommander"),
}

local util = SU.util

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

-- Analagous to ZO_PreHook
-- Optional parameter was moved to the end of the list,
-- hookFunction will always run after the existing function.
function util.PostHook(existingFunctionName, hookFunction, objectTable)
    if not objectTable then
        objectTable = _G
    end

    local existingFunction = objectTable[existingFunctionName]

    if (existingFunction and type(existingFunction) == "function") then
        local newFunction = function(...)
            existingFunction(...)
            hookFunction(...)
        end

        objectTable[existingFunctionName] = newFunction
    end
end

function util.SystemMessage(message)
    if CHAT_SYSTEM.primaryContainer then
        CHAT_SYSTEM.primaryContainer:OnChatEvent(nil, message, CHAT_CATEGORY_SYSTEM)
    else
        CHAT_SYSTEM:AddMessage(message)
    end
end