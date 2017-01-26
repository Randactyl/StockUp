local SU = StockUp
SU.settings = {}

local strings = SU.strings
local util = SU.util
local settings = SU.settings
settings.varsVersion = "2.0"

local vars

function settings.InitializeSettings()
    local defaultVars = {
        preferAP = false,
        stock = {},
    }

    settings.vars = ZO_SavedVars:NewCharacterNameSettings("StockUp_Settings", settings.varsVersion, nil, defaultVars)
    vars = settings.vars

    local function createOptionsMenu()
        local function buildStockDescription()
            local oddDescription = ""
            local evenDescription = ""
            local count = 0
            local stock = ZO_ShallowTableCopy(vars.stock)

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
        local oddDescription, evenDescription = buildStockDescription()
        local panel = {
            type = "panel",
            name = strings.STOCK_UP_NAME,
            author = "Randactyl",
            version = SU.addonVersion,
            website = "http://www.esoui.com/downloads/info705-StockUp.html",
            slashCommand = "/stockup",
            registerForRefresh = true
        }
        local optionsData = {
            [1] = {
                type = "checkbox",
                name = strings.PREFER_AP,
                tooltip = strings.PREFER_AP_TOOLTIP,
                getFunc = function() return vars.preferAP end,
                setFunc = function(value) vars.preferAP = value end,
            },
            [2] = {
                type = "header",
                name = strings.STOCK_UP_HEADER,
            },
            [3] = {
                type = "button",
                name = strings.REFRESH_LIST_BUTTON,
                func = function()
                    local oddDescription, evenDescription = buildStockDescription()

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

        util.LAM:RegisterAddonPanel("StockUpSettingsPanel", panel)
        util.LAM:RegisterOptionControls("StockUpSettingsPanel", optionsData)
    end
    createOptionsMenu()
end

function settings.DestockItem(itemId)
    if not settings.IsItemStocked(itemId) then return end

    local name = vars.stock[itemId].itemName

    vars.stock[itemId] = nil
    d(strings.DESTOCK_ITEM_CONFIRMATION .. name .. ".")
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
    d(strings.STOCK_ITEM_CONFIRMATION .. vars.stock[itemId].amount .. " " .. vars.stock[itemId].itemName .. "!")
end