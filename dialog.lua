local SU = StockUp
SU.dialog = {}

local strings = SU.strings
local util = SU.util
local settings = SU.settings
local dialog = SU.dialog

function dialog.InitializeDialog(dialogControl)
    dialog.control = dialogControl

    --inventorySlotControl is child of rowControl
    local function setupStockItem(_, inventorySlotControl)
        dialogControl.data = inventorySlotControl:GetParent().dataEntry.data
        local data = dialogControl.data

        local itemIcon = data.iconFile or data.icon
        local sourceSlot = GetControl(dialogControl, "Source")

        dialogControl.slotControl = inventorySlotControl
        dialogControl.spinner:SetMinMax(1, nil)
        dialogControl.spinner:SetValue(5)
        ZO_ItemSlot_SetupSlot(sourceSlot, 0, itemIcon)
    end

    local info = {
        customControl = dialogControl,
        setup = setupStockItem,
        title = {
            text = zo_strupper(strings.STOCK_UP_NAME),
        },
        buttons = {
            [1] = {
                control = GetControl(dialogControl, "Split"),
                text = strings.STOCK_ITEM_MENU_OPTION,
                callback = function()
                    local data = dialogControl.data
                    local itemLink, itemId = util.GetItemInfoFromSlot(data)
                    local amount = dialogControl.spinner:GetValue()

                    settings.StockItem(itemId, itemLink, amount)
                end,
            },
            [2] = {
                control = GetControl(dialogControl, "Cancel"),
                text = SI_DIALOG_CANCEL,
            }
        }
    }
    ZO_Dialogs_RegisterCustomDialog("STOCK_ITEM", info)

    dialogControl.spinner = ZO_Spinner:New(GetControl(dialogControl, "Spinner"))

    local function HandleCursorPickup(eventId, cursorType)
        if cursorType == MOUSE_CONTENT_INVENTORY_ITEM then
            ZO_Dialogs_ReleaseAllDialogsOfName("STACK_SPLIT")
        end
    end
    EVENT_MANAGER:RegisterForEvent("ZO_Stack", EVENT_CURSOR_PICKUP, HandleCursorPickup)
end