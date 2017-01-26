local str = StockUpStrings[StockUpSettings:GetLanguage()]
local data = nil

--inventoryItemControl is child of rowControl
local function SetupStockItem(stackControl, inventorySlotControl)
    data = inventorySlotControl:GetParent().dataEntry.data
    local itemIcon = data.iconFile or data.icon
    local sourceSlot = GetControl(stackControl, "Source")

    stackControl.slotControl = inventorySlotControl
    stackControl.spinner:SetMinMax(1, nil)
    stackControl.spinner:SetValue(5)
    ZO_ItemSlot_SetupSlot(sourceSlot, 0, itemIcon)
end

function StockUp_SetupDialog(self)
    local info = {
        customControl = self,
        setup = SetupStockItem,
        title = {
            text = zo_strupper(str.STOCK_UP_NAME),
        },
        buttons = {
            [1] = {
                control = GetControl(self, "Split"),
                text = str.STOCK_ITEM_MENU_OPTION,
                callback = function(stackControl)
                    local bagId = data.bagId
                    local slotIndex = data.slotIndex
                    local itemId, itemLink
                    if bagId then
                        itemLink = GetItemLink(bagId, slotIndex)
                    else
                        itemLink = GetStoreItemLink(slotIndex)
                    end
                    itemId = select(4, ZO_LinkHandler_ParseLink(itemLink))
                    local stock = StockUpSettings:GetStockedItems()

                    stock[itemId] = {
                        itemName = zo_strformat("<<t:1>>", GetItemLinkName(itemLink)),
                        amount = stackControl.spinner:GetValue(),
                    }

                    d(str.STOCK_ITEM_CONFIRMATION .. stock[itemId].amount .. " " .. stock[itemId].itemName .. "!")
                end,
            },
            [2] = {
                control = GetControl(self, "Cancel"),
                text = SI_DIALOG_CANCEL,
            }
        }
    }
    ZO_Dialogs_RegisterCustomDialog("STOCK_ITEM", info)

    local function HandleCursorPickup(eventId, cursorType)
        if(cursorType == MOUSE_CONTENT_INVENTORY_ITEM) then
            ZO_Dialogs_ReleaseAllDialogsOfName("STACK_SPLIT")
        end
    end

    self.spinner = ZO_Spinner:New(GetControl(self, "Spinner"))

    EVENT_MANAGER:RegisterForEvent("ZO_Stack", EVENT_CURSOR_PICKUP, HandleCursorPickup)
end