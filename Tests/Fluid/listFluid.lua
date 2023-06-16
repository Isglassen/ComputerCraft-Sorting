local fluids = require("fluidUtils")
local files = require("fileUtils")
local config = files.readData("config.txt")
local pretty = require("cc.pretty")
local tArgs = {...}

for i = 1, #tArgs do
    if tArgs[i] == "." then tArgs[i] = nil end
end

pretty.pretty_print(fluids.listFluid(config, tArgs[1]))