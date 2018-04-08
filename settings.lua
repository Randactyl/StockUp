local SU = StockUp
SU.settings = {
    varsVersion = "2.0",
}

local util = SU.util
local settings = SU.settings

local vars

function settings.InitializeSettings()
    local defaultVars = {
        preferAP = true,
        stock = {},
    }

    settings.vars = ZO_SavedVars:NewCharacterNameSettings("StockUp_Settings", settings.varsVersion, nil, defaultVars)
    vars = settings.vars

    local function createOptionsMenu()
        local function buildStockDescription()
            local oddDescription, evenDescription = "", ""
            local count = 0

            for _, v in pairs(vars.stock) do
                count = count + 1

                if count % 2 == 1 then
                    oddDescription = string.format("%s (%d) %s\n", oddDescription, v.amount, v.itemName)
                else
                    evenDescription = string.format("%s (%d) %s\n", evenDescription, v.amount, v.itemName)
                end
            end

            return oddDescription, evenDescription
        end

        local oddDescription, evenDescription = buildStockDescription()

        local panel = {
            type = "panel",
            name = SU.name,
            displayName = SI_STOCKUP_STOCK_UP_NAME,
            author = "Randactyl",
            version = SU.addonVersion,
            website = "http://www.esoui.com/downloads/info705-StockUp.html",
            slashCommand = "/stockup",
            registerForRefresh = true
        }
        local optionsData = {
            {
                type = "checkbox",
                name = SI_STOCKUP_PREFER_AP,
                tooltip = SI_STOCKUP_PREFER_AP_TOOLTIP,
                getFunc = function() return vars.preferAP end,
                setFunc = function(value) vars.preferAP = value end,
            },
            {
                type = "header",
                name = SI_STOCKUP_STOCK_UP_HEADER,
            },
            {
                type = "description",
                text = oddDescription,
                width = "half",
                reference = "StockUpSettingsDescriptionOdd",
            },
            {
                type = "description",
                text = evenDescription,
                width = "half",
                reference = "StockUpSettingsDescriptionEven",
            },
            {
                type = "button",
                name = SI_STOCKUP_REFRESH_LIST_BUTTON,
                width = "half",
                func = function()
                    oddDescription, evenDescription = buildStockDescription()

                    StockUpSettingsDescriptionOdd.data.text = oddDescription
                    StockUpSettingsDescriptionEven.data.text = evenDescription
                end,
            },
        }

        util.LAM:RegisterAddonPanel("StockUpSettingsPanel", panel)
        util.LAM:RegisterOptionControls("StockUpSettingsPanel", optionsData)
    end

    createOptionsMenu()
end

function settings.DestockItem(itemId)
    if not settings.IsItemStocked(itemId) then return end

    local name = vars.stock[itemId].itemName

    vars.stock[itemId] = nil

    util.SystemMessage(string.format("%s %s.", GetString(SI_STOCKUP_DESTOCK_ITEM_CONFIRMATION), ZO_SELECTED_TEXT:Colorize(name)))
end

function settings.IsAPPreferred()
    return vars.preferAP
end

function settings.IsItemStocked(itemId)
    if vars.stock[itemId] then return true end
    return false
end

function settings.GetStockedItemInfo(itemId)
    return vars.stock[itemId]
end

function settings.StockItem(itemId, itemLink, amount)
    if not itemId then return end

    vars.stock[itemId] = {
        itemName = zo_strformat("<<t:1>>", GetItemLinkName(itemLink)),
        amount = amount,
    }

    util.SystemMessage(string.format("%s %dx %s!", GetString(SI_STOCKUP_STOCK_ITEM_CONFIRMATION), vars.stock[itemId].amount, ZO_SELECTED_TEXT:Colorize(vars.stock[itemId].itemName)))
end