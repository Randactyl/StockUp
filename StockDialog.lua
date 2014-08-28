local SIGNED_INT_MAX = 2^32 / 2 - 1
local INT_MAX = 2^32
local str = StockUpStrings[StockUpSettings:GetLanguage()]

local function SignItemId(itemInstanceId)
    if(itemInstanceId and itemInstanceId > SIGNED_INT_MAX) then
        itemInstanceId = itemInstanceId - INT_MAX
    end
    return itemInstanceId
end

local function RefreshDestinations(stackControl)
    local stackLabel = GetControl(stackControl, "SourceStackCount")
    stackLabel:SetText(stackControl.spinner:GetValue())
end

local function SetupStockItem(stackControl, inventorySlotControl)
    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlotControl)
    local stackSize = GetSlotStackSize(bagId, slotIndex)

    stackControl.stackSize = stackSize
    stackControl.slotControl = inventorySlotControl

    local itemIcon, _, _, _, _, _, _, quality = GetItemInfo(bagId, slotIndex)
    local itemName = GetItemName(bagId, slotIndex)
    local qualityColor = GetItemQualityColor(quality)

    local sourceSlot = GetControl(stackControl, "Source")
    
    ZO_ItemSlot_SetupSlot(sourceSlot, 0, itemIcon)

    ZO_Inventory_BindSlot(sourceSlot, SLOT_TYPE_STACK_SPLIT, slotIndex, bagId)

    stackControl.spinner:SetMinMax(1, 100)
    stackControl.spinner:SetValue(5)
    RefreshDestinations(stackControl)
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
                			   local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(stackControl.slotControl)
                               local signedItemInstanceId = SignItemId(GetItemInstanceId(bagId, slotIndex))
                               local stock = StockUpSettings:GetStockedItems()

                               stock[signedItemInstanceId] = {
									itemName = GetItemName(bagId, slotIndex),
									itemId = select(4, ZO_LinkHandler_ParseLink(GetItemLink(bagId, slotIndex))),
									amount = stackControl.spinner:GetValue() or 600
							   }

                               d(str.STOCK_ITEM_CONFIRMATION .. stock[signedItemInstanceId].amount .. " " .. stock[signedItemInstanceId].itemName .. "!")
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

    local function OnSpinnerValueChanged()
        RefreshDestinations(self)
    end

    self.spinner = ZO_Spinner:New(GetControl(self, "Spinner"))
    self.spinner:RegisterCallback("OnValueChanged", OnSpinnerValueChanged)

    EVENT_MANAGER:RegisterForEvent("ZO_Stack", EVENT_CURSOR_PICKUP, HandleCursorPickup)
end