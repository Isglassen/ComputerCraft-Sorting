local fluids = require("fluidUtils")
local files = require("fileUtils")
local config = files.readData("config.txt")

fluids.insertFluid(config)