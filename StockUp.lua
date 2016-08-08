local SUSettings = nil
local stock = nil
local str = nil

local BACKPACK = ZO_PlayerInventoryList
local STORE = ZO_StoreWindowList
local CRAFTBAG = ZO_CraftBagList

local dbg = false

local function GatherStoreInfo()
	local storeTable = {}
	local preferAP = SUSettings:GetAPPreference()

	for i = 1, GetNumStoreItems() do
		local _, _, s, p, _, _, _, _, _, t1, q1 = GetStoreEntryInfo(i)
		local storeItemLink = GetStoreItemLink(i)
        local storeItemId = select(4, ZO_LinkHandler_ParseLink(storeItemLink))

		if stock[storeItemId] and (
		  --if an item is found for the first time, enter it
		  storeTable[storeItemId] == nil or
		  --if an item is found again, re-enter it if it costs AP and that is
		  --preferred to gold
		  (preferAP == true and p == 0) or
		  --if an item is found again, re-enter it if it costs gold and that is
		  --preferred to AP
		  (preferAP == false and q1 == 0) ) then
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

local function StockUp_StoreOpened()
	local storeTable = GatherStoreInfo()

	for itemId, storeItem in pairs(storeTable) do
		local amountWanted = stock[itemId].amount
		local amountHave = GetItemLinkStacks(storeItem.itemLink)
		local amountNeeded = amountWanted - amountHave
		if dbg == true then d("Need " .. amountNeeded .. " " .. stock[itemId].itemName) end

		if amountNeeded > 0 then
			local storeIndex = storeTable[itemId].index
			local quantity = zo_min(amountNeeded, GetStoreEntryMaxBuyable(storeIndex))
			local itemName = stock[itemId].itemName

			if dbg == false then BuyStoreItem(storeIndex, quantity) end
			d(str.PURCHASE_CONFIRMATION .. quantity .. " " .. itemName)
		end
	end
end

local function DestockItem(rowControl)
	local itemId
	if rowControl.bagId then
		itemId = select(4, ZO_LinkHandler_ParseLink(GetItemLink(rowControl.bagId, rowControl.slotIndex)))
	else
		itemId = select(4, ZO_LinkHandler_ParseLink(GetStoreItemLink(rowControl.index)))
	end

	d(str.DESTOCK_ITEM_CONFIRMATION .. stock[itemId].itemName .. ".")
	stock[itemId] = nil
end

local function StockItem(rowControl)
	local itemId
	if rowControl.bagId then
		itemId = select(4, ZO_LinkHandler_ParseLink(GetItemLink(rowControl.bagId, rowControl.slotIndex)))
	else
		itemId = select(4, ZO_LinkHandler_ParseLink(GetStoreItemLink(rowControl.index)))
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
		itemId = select(4, ZO_LinkHandler_ParseLink(GetStoreItemLink(rowControl.index)))
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
	if(not BACKPACK:IsHidden() or not STORE:IsHidden() or not CRAFTBAG:IsHidden()) then
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
