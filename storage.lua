local fileFns = require("StorageData.files")
local termFns = require("StorageData.terminal")

local config = fileFns.readData("storage_config.txt")

local items = require("StorageData.items")(config)

--[[
  Needed things:

  Features:

  Touch Screen
  Refresh all
  Refresh chest
    Listed by storage
  Move items
    You can now select two storage systems to move between (by default Output and Storage)
  Switch source
  Switch destination
  Swap storages
  Edit config
  Item Search
    Should match based on name, displayName, or tags if starting with a #
    Should support Ctrl+Backspace to erase full words

  Information:

  Operation progress
  Current mode
  List of items/chests/storages
  Free space in destination
    Also free space for specific items
  
  Background operations:

  Refresh peripheral on peripheral and peripheral_detatch peripheral_detach
]]

local function drawUI()

end

local function watchTerminate()
  os.pullEventRaw("terminate")
  term.clear()
  term.setCursorPos(1, 1)
  termFns.SetTextColor(term, colors.red)
  print("Terminated")
end

local function main()

end

parallel.waitForAny(watchTerminate, main)
