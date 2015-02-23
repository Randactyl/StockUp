StockUpSettings = ZO_Object:Subclass()

local LAM = LibStub("LibAddonMenu-2.0")
local settings = nil
local version = "2.0"
local str = nil

function StockUpSettings:New()
	local obj = ZO_Object.New(self)
	obj:Initialize()
	return obj
end

function StockUpSettings:Initialize()
	local defaults = {
		preferAP = false,

		--non-settings data
		stock = {}
	}

	str = StockUpStrings[self:GetLanguage()]
	settings = ZO_SavedVars:New("StockUp_Settings", version, nil, defaults)

	self:CreateOptionsMenu()
end

function StockUpSettings:GetLanguage()
	local lang = GetCVar("language.2")

	if(lang == "en") then return lang end

	return "en"
end

function StockUpSettings:CreateOptionsMenu()
	local panel = {
		type = "panel",
		name = str.STOCK_UP_NAME,
		author = "Randactyl",
		version = version,
		slashCommand = "/stockupsettings",
		registerForRefresh = true
	}
	local optionsData = {}
	local data = {
		type = "checkbox",
		name = str.PREFER_AP,
		tooltip = str.PREFER_AP_TOOLTIP,
		getFunc = function() return settings.preferAP end,
		setFunc = function(value) settings.preferAP = value end
	}
	table.insert(optionsData, data)
	data = {
		type = "header",
		name = str.STOCK_UP_HEADER
	}
	table.insert(optionsData, data)
	data = {
		type = "button",
		name = str.REFRESH_LIST_BUTTON,
		func = function() ReloadUI() end,
		warning = str.REFRESH_LIST_BUTTON_WARNING
	}
	table.insert(optionsData, data)
	if(settings) then
		for _,v in pairs(settings.stock) do
			data = {
				type = "description",
				text = v.itemName .. " (" .. v.amount .. ")",
				width = "half",
			}
			table.insert(optionsData, data)
		end
	end

	LAM:RegisterAddonPanel("StockUpSettingsPanel", panel)
	LAM:RegisterOptionControls("StockUpSettingsPanel", optionsData)
end

function StockUpSettings:GetStockedItems()
	return settings.stock
end

function StockUpSettings:GetCurrencyPreference()
	return settings.preferAP
end