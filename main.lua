StockUp = {
    name = "StockUp",
    addonVersion = "2.1.0.0",
    debug = false,
}
local SU = StockUp

local function OnAddonLoaded(_, addonName)
    if addonName ~= SU.name then return end
    EVENT_MANAGER:UnregisterForEvent("StockUpLoaded", EVENT_ADD_ON_LOADED)

    local strings = SU.strings
    local util = SU.util
    local settings = SU.settings

    settings.InitializeSettings()

    local function initializeHooks()
        local function addContextMenuOption(slot)
            if slot:GetOwningWindow() == ZO_TradingHouse then return end

            if not ZO_PlayerInventoryList:IsHidden() or
               not ZO_StoreWindowList:IsHidden() or
               not ZO_CraftBagList:IsHidden() then
                local _, itemId = util.GetItemInfoFromSlot(slot)

                if (not settings.IsItemStocked(itemId)) then
                    local function stockItem()
                        ZO_Dialogs_ShowDialog("STOCK_ITEM", slot)
                    end

                    AddCustomMenuItem(GetString(SI_STOCKUP_STOCK_ITEM_MENU_OPTION), stockItem, MENU_ADD_OPTION_LABEL)
                else
                    local function destockItem()
                        settings.DestockItem(itemId)
                    end

                    AddCustomMenuItem(GetString(SI_STOCKUP_DESTOCK_ITEM_MENU_OPTION), destockItem, MENU_ADD_OPTION_LABEL)
                end

                ShowMenu(ZO_Menu.owner)
            end
        end

        util.PostHook("ZO_InventorySlot_ShowContextMenu", addContextMenuOption)

        local function onOpenStore()
            local function gatherStoreInfo()
                local storeTable = {}
                local preferAP = settings.IsAPPreferred()

                for i = 1, GetNumStoreItems() do
                    local _, _, s, p, _, _, _, _, _, t1, q1 = GetStoreEntryInfo(i)
                    local storeItemLink, storeItemId = util.GetItemInfo(nil, i)
                    local isStocked = settings.IsItemStocked(storeItemId)

                    if isStocked and (
                       --if an item is found for the first time, enter it
                       storeTable[storeItemId] == nil or
                       --if an item is found again, re-enter it if it costs AP and that is
                       --preferred to gold
                       (preferAP and p == 0) or
                       --if an item is found again, re-enter it if it costs gold and that is
                       --preferred to AP
                       (not preferAP and q1 == 0)) then
                        storeTable[storeItemId] = {
                            index = i,
                            stack = s,
                            price = p,
                            curType = t1,
                            curQuantity = q1,
                            itemLink = storeItemLink,
                        }
                    end
                end

                return storeTable
            end

            local storeTable = gatherStoreInfo()

            for itemId, storeItem in pairs(storeTable) do
                local stockingInfo = settings.GetStockedItemInfo(itemId)

                local amountWanted = stockingInfo.amount
                local bagCount, _, craftBagCount = GetItemLinkStacks(storeItem.itemLink)

                local amountHave = bagCount + craftBagCount
                local amountNeeded = amountWanted - amountHave

                if SU.debug then
                    util.SystemMessage(string.format("Need %d %s", amountNeeded, stockingInfo.itemName))
                end

                if amountNeeded > 0 then
                    local storeIndex = storeItem.index
                    local quantity = zo_min(amountNeeded, GetStoreEntryMaxBuyable(storeIndex))

                    local currencyType = (storeItem.curType == (0 or 1) and CURT_MONEY) or CURT_ALLIANCE_POINTS

                    local price = zo_max(storeItem.price, storeItem.curQuantity) * quantity

                    if not SU.debug then
                        BuyStoreItem(storeIndex, quantity)
                    end

                    if price > 0 then
                        util.SystemMessage(string.format("%s %d %s - %s", GetString(SI_STOCKUP_PURCHASE_CONFIRMATION), quantity, ZO_SELECTED_TEXT:Colorize(stockingInfo.itemName), ZO_Currency_FormatPlatform(currencyType, price, ZO_CURRENCY_FORMAT_AMOUNT_ICON)))
                    else
                        util.SystemMessage(string.format(GetString(SI_STOCKUP_NOT_ENOUGH_CURRENCY), ZO_Currecy_GetPlatformFormattedCurrencyIcon(currencyType), ZO_SELECTED_TEXT:Colorize(stockingInfo.itemName)))
                    end
                end
            end
        end

        EVENT_MANAGER:RegisterForEvent("StockUpOpenStore", EVENT_OPEN_STORE, onOpenStore)
    end

    initializeHooks()

    --Get slash command set up by LAM, change over to LSC
    local slashcommand = SLASH_COMMANDS["/stockup"]
    SLASH_COMMANDS["/stockup"] = nil
    local command = util.LSC:Register("/stockup", slashcommand, GetString(SI_STOCKUP_LSC_DESCRIPTION_SETTINGS))

    --add LSC debug subcommand
    local function toggleDebug()
        SU.debug = not SU.debug

        local message

        if SU.debug then
            message = GetString(SI_ADDONLOADSTATE2)
        else
            message = GetString(SI_ADDONLOADSTATE3)
        end

        util.SystemMessage(string.format("%s %s!", GetString(SI_SETTINGSYSTEMPANEL6), message)) -- Debug Enabled/Disabled with game localized strings
    end

    local debugCommand = command:RegisterSubCommand()
    debugCommand:AddAlias("debug")
    debugCommand:SetCallback(toggleDebug)
    debugCommand:SetDescription(GetString(SI_STOCKUP_LSC_DESCRIPTION_DEBUG))
end

EVENT_MANAGER:RegisterForEvent("StockUpLoaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)