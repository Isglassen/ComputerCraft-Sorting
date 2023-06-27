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

  Refresh chest on peripheral and peripheral_detatch events
]]

local modes = {
  move = "Move",
  source = "Change Source",
  destination = "Change Destination",
  reChest = "Refresh Chest",
  reAll = "Refresh All",
  config = "Config"
}

local info = {
  state = "",
  step = "",
  source = "Storage",
  destination = "Output",
  mode = modes.move,
  list = {
    index = 1,
    offset = 0,
  }
}

local PARAMS = {
  ITEMS_START = 3,
  ITEMS_END = termFns.H(term) - 2,
  ITEMS_LENGTH = 0,
}

PARAMS.ITEMS_LENGTH = PARAMS.ITEMS_END - PARAMS.ITEMS_START + 1

local function drawList(list, index, offset, countList, freeList)
  for i = 1, PARAMS.ITEMS_LENGTH, 1 do
    local readIndex = offset + i
    local screenIndex = i + PARAMS.ITEMS_START - 1

    local item = list[readIndex]
    if item == nil then
      break
    end

    local count, free

    if countList then
      count = countList[readIndex]
    end

    if freeList then
      free = freeList[readIndex]
    end

    local leftString = nil
    if count then
      leftString = "" .. count
      if free then
        leftString = leftString .. "/" .. free
      end
    end

    -- Draw List
    term.setCursorPos(1, screenIndex)
    term.clearLine()
    if readIndex == index then
      termFns.SetTextColor(term, colors.lightBlue)
      term.write("[" .. item .. "]")
      termFns.LeftWrite(term, termFns.W(term), screenIndex, "[" .. leftString .. "]")
    else
      term.setCursorPos(2, screenIndex)
      termFns.SetTextColor(term, colors.white)
      term.write(item)
      termFns.LeftWrite(term, termFns.W(term) - 1, screenIndex, leftString)
    end

    -- Draw List Indicators
    if offset > 0 then
      termFns.SetTextColor(term, colors.yellow)
      term.setCursorPos(1, PARAMS.ITEMS_START)
      term.write("^")
      termFns.LeftWrite(term, termFns.W(term), PARAMS.ITEMS_START, "^")
    end
    if #list > PARAMS.ITEMS_LENGTH then
      termFns.SetTextColor(term, colors.yellow)
      term.setCursorPos(1, PARAMS.ITEMS_END)
      term.write("v")
      termFns.LeftWrite(term, termFns.W(term), PARAMS.ITEMS_END, "v")
    end
  end
end

---Draws the ui
---@param done? integer If loading something, current progress
---@param total? integer If loading something, end progress
---@param step? integer If loading something, current step
---@param steps? integer If loading something, total step
local function drawUI(done, total, step, steps)
  termFns.SetTextColor(term, colors.white)
  termFns.SetBackgroundColor(term, colors.black)
  term.clear()

  -- Line 1
  term.setCursorPos(1, 1)
  termFns.SetTextColor(term, colors.white)
  termFns.SetBackgroundColor(term, colors.gray)
  term.clearLine()

  if done then
    termFns.DetailedProgress(term, done, total, step, steps, colors.lime, colors.black)
  else

  end

  -- Line 2
  term.setCursorPos(1, 2)
  term.clearLine()

  term.write(info.state)
  termFns.LeftWrite(term, termFns.W(term), 2, info.step)

  -- SelectArea
  termFns.SetTextColor(term, colors.white)
  termFns.SetBackgroundColor(term, colors.black)
  if info.mode == modes.move then
    local list, counts, free = {}, {}, {}
    for k, v in pairs(items.items) do
      if k ~= "empty" then
        table.insert(list, k)
        table.insert(counts, v.count)
        table.insert(free, v.free)
      end
    end

    drawList(list, info.list.index, info.list.offset, counts, free)
  end

  -- Line -0


  -- Line -1
end

local function main()
  info.state = "Loading..."
  info.step = "Reading Items"

  items:refreshAll(drawUI)

  info.state = info.source .. " -> " .. info.destination
  info.step = ""

  drawUI()

  while true do
    local eventData = { os.pullEvent() }
  end
end

local function terminateHandler()
  os.pullEventRaw("terminate")
  termFns.SetTextColor(term, colors.red)
  termFns.SetBackgroundColor(term, colors.black)
  term.clear()
  term.setCursorPos(1, 1)
  print("Terminated")
end

parallel.waitForAny(main, terminateHandler)
