StockUp = {}
local SU = StockUp
SU.addonVersion = "2.0.0.0"
SU.debug = false

local strings, util, settings

local function loaded(eventCode, addonName)
    if addonName ~= "StockUp" then return end
    EVENT_MANAGER:UnregisterForEvent("StockUpLoaded", EVENT_ADD_ON_LOADED)

    strings = SU.strings
    util = SU.util
    settings = SU.settings

    settings.InitializeSettings()

    local function initializeHooks()
        local function addContextMenuOptionSoon(slot)
            if slot:GetOwningWindow() == ZO_TradingHouse then return end

            local function addContextMenuOption()
                local _, itemId = util.GetInfoFromSlot(slot)

                if(not settings.IsItemStocked(itemId)) then
                    local function stockItem()
                        ZO_Dialogs_ShowDialog("STOCK_ITEM", slot)
                    end
                    AddCustomMenuItem(strings.STOCK_ITEM_MENU_OPTION, stockItem, MENU_ADD_OPTION_LABEL)
                else
                    local function destockItem()
                        settings.DestockItem(itemId)
                    end
                    AddCustomMenuItem(strings.DESTOCK_ITEM_MENU_OPTION, destockItem, MENU_ADD_OPTION_LABEL)
                end

                ShowMenu()
            end

            if not ZO_PlayerInventoryList:IsHidden() or
              not ZO_StoreWindowList:IsHidden() or
              not ZO_CraftBagList:IsHidden() then
                zo_callLater(addContextMenuOption, 50)
            end
        end
        ZO_PreHook("ZO_InventorySlot_ShowContextMenu", addContextMenuOptionSoon)

        local function storeOpened()
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
                      (preferAP == true and p == 0) or
                      --if an item is found again, re-enter it if it costs gold and that is
                      --preferred to AP
                      (preferAP == false and q1 == 0)) then
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
            local curTypeToFormattedTexture = {
                [CURT_NONE] = "|t16:16:esoui/art/currency/currency_gold.dds|t",
                [CURT_MONEY] = "|t16:16:esoui/art/currency/currency_gold.dds|t",
                [CURT_ALLIANCE_POINTS] = "|t16:16:esoui/art/currency/alliancepoints.dds|t",
                [CURT_TELVAR_STONES] = "|t16:16:esoui/art/currency/currency_telvar.dds|t",
                [CURT_WRIT_VOUCHERS] = "|t16:16:esoui/art/currency/currency_writvoucher.dds|t",
            }

            for itemId, storeItem in pairs(storeTable) do
                local stockingInfo = settings.GetStockedItemInfo(itemId)

                local amountWanted = stockingInfo.amount
                local bagCount, bankCount, craftBagCount = GetItemLinkStacks(storeItem.itemLink)
                local amountHave = bagCount + craftBagCount
                local amountNeeded = amountWanted - amountHave

                if SU.debug == true then d("Need " .. amountNeeded .. " " .. stockingInfo.itemName) end

                if amountNeeded > 0 then
                    local storeIndex = storeItem.index
                    local quantity = zo_min(amountNeeded, GetStoreEntryMaxBuyable(storeIndex))
                    local price = zo_max(storeItem.price, storeItem.curQuantity)
                    price = price * quantity
                    local itemName = stockingInfo.itemName

                    if SU.debug == false then BuyStoreItem(storeIndex, quantity) end
                    d(strings.PURCHASE_CONFIRMATION .. quantity .. " " .. itemName .. " -- " .. price .. curTypeToFormattedTexture[storeItem.curType])
                end
            end
        end
        EVENT_MANAGER:RegisterForEvent("StockUpStoreOpened", EVENT_OPEN_STORE, storeOpened)
    end
    initializeHooks()

    local function toggleDebug()
        SU.debug = not SU.debug
        d("Debug set to "..tostring(SU.debug)..".")
    end
    local slashcommand = SLASH_COMMANDS["/stockup"]
    SLASH_COMMANDS["/stockup"] = nil
    local command = util.LSC:Register("/stockup", slashcommand, strings.LSC_DESCRIPTION_SETTINGS)
    local debugCommand = command:RegisterSubCommand()
    debugCommand:AddAlias("debug")
    debugCommand:SetCallback(toggleDebug)
    debugCommand:SetDescription(strings.LSC_DESCRIPTION_DEBUG)
end
EVENT_MANAGER:RegisterForEvent("StockUpLoaded", EVENT_ADD_ON_LOADED, loaded)