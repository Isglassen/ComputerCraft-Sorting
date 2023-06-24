local fileFns = require("StorageData.files")
local termFns = require("StorageData.terminal")

local config = fileFns.readData("storage_config.txt")

local items = require("StorageData.items")(config)

term.clear()

local function updateFunction(done, total, step, steps)
  term.clear()
  term.setCursorPos(1, 1)
  termFns.DetailedProgress(term, done, total, step, steps, colors.lime, colors.gray)
end

items:refreshAll(updateFunction)

sleep(5)

items:refreshChest("minecraft:chest_5", updateFunction)

sleep(5)

items:pullItems(updateFunction, "minecraft:chest_6", "minecraft:chest_1", 1)
items:pullItems(updateFunction, "minecraft:chest_6", "minecraft:chest_1", 2)

fileFns.writeData("out.log", { items = items.items, chests = items.chests, config = items.config })
