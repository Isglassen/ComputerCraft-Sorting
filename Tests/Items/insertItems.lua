local items = require("inventoryUtils")
local files = require("fileUtils")
local config = files.readData("config.txt")

items.insertItems(config)