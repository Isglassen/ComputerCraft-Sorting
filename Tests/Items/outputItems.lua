local items = require("inventoryUtils")
local files = require("fileUtils")
local config = files.readData("config.txt")
local tArgs = {...}

for i = 1, #tArgs do
    if tArgs[i] == "." then tArgs[i] = nil end
end

if tArgs[4] then
    tArgs[4] = tonumber(tArgs[4])
end

local enchantments = nil
if tArgs[3] ~= nil  then enchantments = {{name=tArgs[3],level=tArgs[4]}} end
local tags = nil
if tArgs[5] ~= nil then tags = {tArgs[5]} end
items.outputItems(config, tArgs[1], tArgs[2], enchantments, tags)