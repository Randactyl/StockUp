local SUSettings = nil
local stock = nil
local str = nil

local BACKPACK = ZO_PlayerInventoryBackpack
local STORE = ZO_StoreWindowList

local dbg = false

local function FindStoreItem(itemId)
	local preferAP = SUSettings:GetCurrencyPreference()

	for index = 1, GetNumStoreItems() do
		local _, _, stack, _, _, _, _, _, _, currencyType1 = GetStoreEntryInfo(index)
		local storeItemId = select(4, ZO_LinkHandler_ParseLink(GetStoreItemLink(index)))

		if (preferAP == true) and (currencyType1 == 2) then
 			if itemId == storeItemId then return index, stack end
		elseif (preferAP == false) and (currencyType1 == 0) then
 			if itemId == storeItemId then return index, stack end
   		end
   	end
end

local function GatherBackpackInfo()
	local backpackTable = {}
	local contents = BACKPACK.data

	for i = 1, #contents do
		local itemId = select(4, ZO_LinkHandler_ParseLink(GetItemLink(BAG_BACKPACK, contents[i].data.slotIndex)))
		
		if backpackTable[itemId] == nil then 
			backpackTable[itemId] = {
				amountHave = 0,
			}
		end
		backpackTable[itemId].amountHave = backpackTable[itemId].amountHave + contents[i].data.stackCount
		if dbg == true then d("have " .. backpackTable[itemId].amountHave .. " " .. contents[i].data.name) end
	end

	return backpackTable
end

local function StockUp_StoreOpened()
	local backpackTable = GatherBackpackInfo()

	for itemId, _ in pairs(stock) do
		local amountWanted = stock[itemId].amount
		local amountHave = 0
		if backpackTable[itemId] then
			amountHave = backpackTable[itemId].amountHave
		end
		local amountNeeded = amountWanted - amountHave
		if dbg == true then d("need " .. amountNeeded .. " " .. stock[itemId].itemName) end

		if amountNeeded > 0 then
			local storeIndex, stack = FindStoreItem(itemId)
			if stack ~= nil then
				local quantity = --[[zo_min(GetNumBagFreeSlots(BAG_BACKPACK),]]
					zo_min(amountNeeded, GetStoreEntryMaxBuyable(storeIndex))--)
				local itemName = stock[itemId].itemName

				if dbg == false then BuyStoreItem(storeIndex, quantity) end
				d(str.PURCHASE_CONFIRMATION .. quantity .. " " .. itemName)
			end
		end
	end
end

local function DestockItem(rowControl)
	local itemId
	if rowControl.bagId then
		itemId = select(4, ZO_LinkHandler_ParseLink(GetItemLink(rowControl.bagId, rowControl.slotIndex)))
	else
		itemId = select(4, ZO_LinkHandler_ParseLink(GetStoreItemLink(rowControl.slotIndex)))
	end

	d(str.DESTOCK_ITEM_CONFIRMATION .. stock[itemId].itemName .. ".")
	stock[itemId] = nil
end

local function StockItem(rowControl)
	local itemId
	if rowControl.bagId then
		itemId = select(4, ZO_LinkHandler_ParseLink(GetItemLink(rowControl.bagId, rowControl.slotIndex)))
	else
		itemId = select(4, ZO_LinkHandler_ParseLink(GetStoreItemLink(rowControl.slotIndex)))
	end

	if(not itemId) then return end
	ZO_Dialogs_ShowDialog("STOCK_ITEM", rowControl)
end

local function AddContextMenuOption(rowControl)
	local menuIndex = nil
	local menuItem = nil
	local itemId
	if rowControl.bagId then
		itemId = select(4, ZO_LinkHandler_ParseLink(GetItemLink(rowControl.bagId, rowControl.slotIndex)))
	else
		itemId = select(4, ZO_LinkHandler_ParseLink(GetStoreItemLink(rowControl.slotIndex)))
	end

	if(not stock[itemId]) then
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
	if(not BACKPACK:IsHidden() or not STORE:IsHidden()) then
		zo_callLater(function() AddContextMenuOption(rowControl) end, 50)
	end
end

local function SetupDebugSlashCommand()
	SLASH_COMMANDS["/stockupdebug"] = function()
		dbg = not dbg
		if dbg then d("Debug set to true.")
		else d("Debug set to false.") end
	end
end

local function StockUp_Loaded(eventCode, addonName)
	if(addonName ~= "StockUp") then return end
	EVENT_MANAGER:UnregisterForEvent("StockUpLoaded", EVENT_ADD_ON_LOADED)

	SUSettings = StockUpSettings:New()
	stock = SUSettings:GetStockedItems()
	str = StockUpStrings[SUSettings:GetLanguage()]

	SetupDebugSlashCommand()
	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuOptionSoon)

	EVENT_MANAGER:RegisterForEvent("StoreOpened", EVENT_OPEN_STORE, StockUp_StoreOpened)
end

EVENT_MANAGER:RegisterForEvent("StockUpLoaded", EVENT_ADD_ON_LOADED, StockUp_Loaded)