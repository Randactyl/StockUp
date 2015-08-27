StockUpStrings = {
    ["de"] = {
        STOCK_UP_NAME = "Stock Up",
        PREFER_AP = "AP vorziehen",
        PREFER_AP_TOOLTIP = "Allianzpunkte benutzen um Gegenstände zu kaufen wenn verfügbar.",
        STOCK_UP_HEADER = "Vorrätige Gegenstände",
        REFRESH_LIST_BUTTON = "Aktualisieren",
        REFRESH_LIST_BUTTON_WARNING = "Lädt das Interface neu",
        STOCK_ITEM_MENU_OPTION = "Aufstocken",
        DESTOCK_ITEM_MENU_OPTION = "Aufstocken deaktivieren",
        STOCK_ITEM_CONFIRMATION = "Automatisches aufstocken von ", -- "Automatisches aufstocken von 15 [Großer Seelenstein]!"
        DESTOCK_ITEM_CONFIRMATION = "Aufstocken deaktiviert für ", -- "Aufstocken deaktiviert für [Großer Seelenstein]."
        PURCHASE_CONFIRMATION = "Kaufe", -- "Kaufe 15 [Großer Seelenstein]!"
    },
    ["en"] = {
        STOCK_UP_NAME = "Stock Up",
        PREFER_AP = "Prefer Alliance Points",
        PREFER_AP_TOOLTIP = "Use AP instead of gold to buy items.",
        STOCK_UP_HEADER = "Stocked Items",
        REFRESH_LIST_BUTTON = "Refresh",
        REFRESH_LIST_BUTTON_WARNING = "Reloads UI",
        STOCK_ITEM_MENU_OPTION = "Stock Item",
        DESTOCK_ITEM_MENU_OPTION = "Destock Item",
        STOCK_ITEM_CONFIRMATION = "Will stock ", --whole string is, for example, "Will stock 15 Pact Stone Trebuchet!"
        DESTOCK_ITEM_CONFIRMATION = "No longer stocking ", --"No longer stocking Pact Stone Trebuchet."
        PURCHASE_CONFIRMATION = "Bought " -- "Bought 15 Pact Stone Trebuchet!"
    },
    ["es"] = {},
    ["fr"] = {
        STOCK_UP_NAME = "Stock Up",
    },
    ["ru"] = {},
}

setmetatable(StockUpStrings["de"], {__index = StockUpStrings["en"]})
setmetatable(StockUpStrings["es"], {__index = StockUpStrings["en"]})
setmetatable(StockUpStrings["fr"], {__index = StockUpStrings["en"]})
setmetatable(StockUpStrings["ru"], {__index = StockUpStrings["en"]})
