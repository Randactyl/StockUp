local SUSettings = nil
local stock = nil

local BACKPACK = ZO_PlayerInventoryBackpack

local SIGNED_INT_MAX = 2^32 / 2 - 1
local INT_MAX = 2^32

local function SignItemId(itemId)
	if(itemId and itemId > SIGNED_INT_MAX) then
		itemId = itemId - INT_MAX
	end
	return itemId
end

local function MyGetItemInstanceId(rowControl)
	local bagId, slotIndex 
	bagId = rowControl.bagId
	slotIndex = rowControl.slotIndex
	return SignItemId(GetItemInstanceId(bagId, slotIndex))
end

local function FindStoreItem(itemId)
	local preferAP = SUSettings:GetCurrencyPreference()

	for index = 1, GetNumStoreItems() do
		local _, _, stack, _, _, _, _, _, _, currencyType1 = GetStoreEntryInfo(index)
		local storeItemId = select(4, ZO_LinkHandler_ParseLink(GetStoreItemLink(index)))

		if (preferAP == true) and (currencyType1 == 2) then
 			if itemId == storeItemId then return storeItemId, stack, index end
		elseif (preferAP == false) and (currencyType1 == 0) then
 			if itemId == storeItemId then return storeItemId, stack, index end
   		end
   	end
end

local function GetItemCount(itemInstanceId)
	local inventory = BACKPACK--PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK]
	local contents = inventory.data --inventory.slots
	local numFound = 0

	for i = 1, #contents, 1 do
		if(itemInstanceId == GetItemInstanceId(BAG_BACKPACK, contents[i].data.slotIndex)) then
			numFound = numFound + contents[i].data.stackCount
		end
	end
	return numFound
end

local function IsItemStocked(signedItemId)
	if stock[signedItemId] ~= nil then return true end
	return false
end

local function StockUp_StoreOpened()
	for i = 1, #BACKPACK.data, 1 do
		local itemInstanceId = GetItemInstanceId(BAG_BACKPACK, BACKPACK.data[i].data.slotIndex)
		local signedItemInstanceId = SignItemId(itemInstanceId)
		if IsItemStocked(signedItemInstanceId) then
			local itemId = stock[signedItemInstanceId].itemId
			local amountWanted = stock[signedItemInstanceId].amount
			local amountHave = GetItemCount(itemInstanceId)
			local amountNeeded = amountWanted - amountHave

			if amountNeeded > 0 then
				local storeItemId, stack, storeIndex = FindStoreItem(itemId)
				if storeItemId then
					if stack > 0 then
						local quantity = zo_min(amountNeeded, GetStoreEntryMaxBuyable(storeIndex))
						local itemName = stock[signedItemInstanceId].itemName
						BuyStoreItem(storeIndex, quantity)
						d(str.PURCHASE_CONFIRMATION .. quantity .. " " .. itemName)
					end
				end
			end
		end
	end
end

local function DestockItem(rowControl)
	itemId = MyGetItemInstanceId(rowControl)
	d(str.DESTOCK_ITEM_CONFIRMATION .. stock[itemId].itemName .. ".")
	stock[itemId] = nil
end

local function StockItem(rowControl)
	itemId = MyGetItemInstanceId(rowControl)
	if(not itemId) then return end
	ZO_Dialogs_ShowDialog("STOCK_ITEM", rowControl)
end

local function AddContextMenuOption(rowControl)
	local menuIndex = nil
	local menuItem = nil
	if(not stock[MyGetItemInstanceId(rowControl)]) then
		menuIndex = AddMenuItem(str.STOCK_ITEM_MENU_OPTION, function() StockItem(rowControl) end, MENU_ADD_OPTION_LABEL)
		menuItem = ZO_Menu:GetNamedChild("Item"..menuIndex)
		menuItem.OnSelect = function() StockItem(rowControl) end
	else
		menuIndex = AddMenuItem(str.DESTOCK_ITEM_MENU_OPTION, function() DestockItem(rowControl) end, MENU_ADD_OPTION_LABEL)
		menuItem = ZO_Menu:GetNamedChild("Item"..menuIndex)
		menuItem.OnSelect = function() DestockItem(rowControl) end
	end
	ShowMenu(self)
end

local function AddContextMenuOptionSoon(rowControl)
	if(rowControl:GetOwningWindow() == ZO_TradingHouse) then return end
	if(BACKPACK:IsHidden()) then return end

	zo_callLater(function() AddContextMenuOption(rowControl) end, 50)
end

local function StockUp_Loaded(eventCode, addonName)
	if(addonName ~= "StockUp") then return end
	EVENT_MANAGER:UnregisterForEvent("StockUpLoaded", EVENT_ADD_ON_LOADED)

	SUSettings = StockUpSettings:New()
	stock = SUSettings:GetStockedItems()
	str = StockUpStrings[SUSettings:GetLanguage()]

	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuOptionSoon)

	EVENT_MANAGER:RegisterForEvent("StoreOpened", EVENT_OPEN_STORE, StockUp_StoreOpened)
end

EVENT_MANAGER:RegisterForEvent("StockUpLoaded", EVENT_ADD_ON_LOADED, StockUp_Loaded)