local strings = {
	SI_STOCKUP_STOCK_UP_NAME = "Stock Up",
	SI_STOCKUP_PREFER_AP = "Prefer Alliance Points",
	SI_STOCKUP_PREFER_AP_TOOLTIP = "Use AP instead of gold to buy items.",
	SI_STOCKUP_STOCK_UP_HEADER = "Stocked Items",
	SI_STOCKUP_REFRESH_LIST_BUTTON = "Refresh",
	SI_STOCKUP_STOCK_ITEM_MENU_OPTION = "Stock Item",
	SI_STOCKUP_DESTOCK_ITEM_MENU_OPTION = "Destock Item",
	SI_STOCKUP_STOCK_ITEM_CONFIRMATION = "Will stock ",
	SI_STOCKUP_DESTOCK_ITEM_CONFIRMATION = "No longer stocking ",
	SI_STOCKUP_PURCHASE_CONFIRMATION = "Bought",
	SI_STOCKUP_NOT_ENOUGH_CURRENCY = "Not enough %s to buy %s.",
	SI_STOCKUP_LSC_DESCRIPTION_SETTINGS = "Open Stock Up settings",
	SI_STOCKUP_LSC_DESCRIPTION_DEBUG = "Toggle debug mode on/off",
	SI_STOCKUP_DEBUG_MODE = "Debug Mode is %s",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end