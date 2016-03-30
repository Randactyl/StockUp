StockUpSettings = ZO_Object:Subclass()

local LAM = LibStub("LibAddonMenu-2.0")
local settings = nil
local version = "1.3.0.1"
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
	settings = ZO_SavedVars:New("StockUp_Settings", "2.0", nil, defaults)

	self:CreateOptionsMenu()
end

function StockUpSettings:GetLanguage()
	local lang = GetCVar("language.2")

	if(lang == "en") then return lang end

	return "en"
end

function StockUpSettings:CreateOptionsMenu()
	local oddDescription, evenDescription = self:BuildStockDescription()

	local panel = {
		type = "panel",
		name = str.STOCK_UP_NAME,
		author = "Randactyl",
		version = version,
		slashCommand = "/stockupsettings",
		registerForRefresh = true
	}
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = str.PREFER_AP,
			tooltip = str.PREFER_AP_TOOLTIP,
			getFunc = function() return settings.preferAP end,
			setFunc = function(value) settings.preferAP = value end,
		},
		[2] = {
			type = "header",
			name = str.STOCK_UP_HEADER,
		},
		[3] = {
			type = "button",
			name = str.REFRESH_LIST_BUTTON,
			func = function()
				local oddDescription, evenDescription = self:BuildStockDescription()

				StockUpSettingsDescriptionOdd.data.text = oddDescription
				StockUpSettingsDescriptionEven.data.text = evenDescription
			end,
		},
		[4] = {
			type = "description",
			text = oddDescription,
			width = "half",
			reference = "StockUpSettingsDescriptionOdd",
		},
		[5] = {
			type = "description",
			text = evenDescription,
			width = "half",
			reference = "StockUpSettingsDescriptionEven",
		},
	}

	LAM:RegisterAddonPanel("StockUpSettingsPanel", panel)
	LAM:RegisterOptionControls("StockUpSettingsPanel", optionsData)
end

function StockUpSettings:BuildStockDescription()
	local oddDescription = ""
	local evenDescription = ""
	local count = 0
	local stock = ZO_ShallowTableCopy(settings.stock)
	--table.sort(stock)

	for _, v in pairs(stock) do
		count = count + 1
		if count % 2 == 1 then
			oddDescription = oddDescription .. "(" .. v.amount .. ") " .. v.itemName .. "\n"
		else
			evenDescription = evenDescription .. "(" .. v.amount .. ") " .. v.itemName .. "\n"
		end
	end

	return oddDescription, evenDescription
end

function StockUpSettings:GetStockedItems()
	return settings.stock
end

function StockUpSettings:GetAPPreference()
	return settings.preferAP
end
