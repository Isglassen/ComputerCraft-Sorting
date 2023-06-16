local fluids = require("fluidUtils")
local files = require("fileUtils")
local config = files.readData("config.txt")
local tArgs = {...}

for i = 1, #tArgs do
    if tArgs[i] == "." then tArgs[i] = nil end
end

fluids.outputFluid(config, tArgs[1])