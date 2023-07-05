local fileFns = require("StorageData.files")
local termFns = require("StorageData.terminal")

local programPath = fs.combine(shell.getRunningProgram(), "../")

---Returns information for a storage from a file
---@param file CCFileRead
---@return string? name Name of the storage, or nil if the file is empty
---@return string[] chests Chests in the storage
local function parseStorage(file)
  local name = file.readLine()
  local chests = {}
  local read = file.readLine()
  while read ~= nil do
    table.insert(chests, read)
    read = file.readLine()
  end
  return name, chests
end

-- TODO Load storages from ./storages/*.storage
-- Format is line 1: Storage name, one chest per line after that
local storages = {}

for _, path in pairs(fs.find(fs.combine(programPath, "./storages/*.storage"))) do
  ---@type CCFileRead
  ---@diagnostic disable-next-line: assign-type-mismatch
  local file = fs.open(path, "r")
  if file ~= nil then
    local name, chests = parseStorage(file)
    file.close()

    if name then
      if storages[name] ~= nil then
        for _, chest in ipairs(chests) do
          table.insert(storages[name], chest)
        end
      else
        storages[name] = chests
      end
    end
  end
end

---@type {monitors: string[]}
local config = fileFns.readData(fs.combine(programPath, "./storage.cfg"))

---@type ItemManager
local manager = require("StorageData.items")(storages)


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

  Config:

  Replace underscores with spaces in items
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
  terms = { term },
  state = "",
  step = "",
  source = "Main Storage",
  destination = "Output",
  mode = modes.move,
  list = {
    index = -1,
    offset = 0,
  }
}

for _, v in pairs(config.monitors) do
  if peripheral.hasType(v, "monitor") then
    table.insert(info.terms, peripheral.wrap(v))
  end
end

local PARAMS = {
  ITEMS_START = function(PARAMS) return 3 end,
  ITEMS_END = function(PARAMS, terminal) return termFns.H(terminal) - 2 end,
  ITEMS_LENGTH = function(PARAMS, terminal) return PARAMS:ITEMS_END(terminal) - PARAMS:ITEMS_START() + 1 end,
}

---Draws a list of items to the middle area of the screen
---@param list string[] List of items
---@param index integer Selected index in the list
---@param offset integer Offset to where the list starts
---@param countList? string[] Count of item
---@param freeList? string[] Free items (needs count)
---@return integer newIndex A new index in case the given one was invalid
---@return integer newOffset A new offset in case the given one was invalid
local function drawList(list, index, offset, countList, freeList)
  if index < 1 then
    index = 1
  end
  if index > #list then
    index = #list
  end
  if #list < PARAMS:ITEMS_LENGTH(term) then
    offset = 0
  else
    if index - offset < 3 then
      offset = index - 3
    end
    if index - offset > PARAMS:ITEMS_LENGTH(term) - 2 then
      offset = index - (PARAMS:ITEMS_LENGTH(term) - 2)
    end

    offset = math.min(#list - PARAMS:ITEMS_LENGTH(term), math.max(0, offset))
  end

  for _, term in pairs(info.terms) do
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    for i = 1, PARAMS:ITEMS_LENGTH(term), 1 do
      local readIndex = offset + i
      local screenIndex = i + PARAMS:ITEMS_START() - 1

      local item = list[readIndex]
      if item == nil then
        break
      end

      local itemBlitT, itemBlitB = "", ""
      local colonIndex = item:find(":", nil, true)

      for i = 1, colonIndex do
        if readIndex == index then
          itemBlitT = itemBlitT .. "9"
        else
          itemBlitT = itemBlitT .. "8"
        end

        itemBlitB = itemBlitB .. "f"
      end

      for i = colonIndex + 1, item:len() do
        if readIndex == index then
          itemBlitT = itemBlitT .. "3"
        else
          itemBlitT = itemBlitT .. "0"
        end

        itemBlitB = itemBlitB .. "f"
      end

      local count, free

      if countList then
        count = countList[readIndex]
      end

      if freeList then
        free = freeList[readIndex]
      end

      local leftString, leftBlitT, leftBlitB
      if count then
        leftString = count
        leftBlitT, leftBlitB = "", ""
        for _ = 1, count:len() do
          if readIndex == index then
            leftBlitT = leftBlitT .. "3"
          else
            leftBlitT = leftBlitT .. "0"
          end

          leftBlitB = leftBlitB .. "f"
        end
        if free then
          leftString = leftString .. "/" .. free
          for _ = 1, free:len() do
            if readIndex == index then
              leftBlitT = leftBlitT .. "9"
            else
              leftBlitT = leftBlitT .. "8"
            end

            leftBlitB = leftBlitB .. "f"
          end
        end
      end

      -- Draw List
      term.setCursorPos(1, screenIndex)
      term.clearLine()
      if readIndex == index then
        term.setTextColor(colors.lightBlue)
        term.blit(
          "[" .. item .. "]",
          "3" .. itemBlitT .. "3",
          "f" .. itemBlitB .. "f")
        termFns.LeftBlit(term, termFns.W(term), screenIndex,
          "[" .. leftString .. "]",
          "3" .. leftBlitT .. "3",
          "f" .. leftBlitB .. "f")
      else
        term.setCursorPos(2, screenIndex)
        term.setTextColor(colors.white)
        term.blit(
          item,
          itemBlitT,
          itemBlitB)
        termFns.LeftBlit(term, termFns.W(term) - 1, screenIndex,
          leftString,
          leftBlitT,
          leftBlitB)
      end
    end

    -- Draw List Indicators
    if offset > 0 then
      term.setTextColor(colors.yellow)
      term.setCursorPos(1, PARAMS:ITEMS_START())
      term.write("^")
      termFns.LeftWrite(term, termFns.W(term), PARAMS:ITEMS_START(), "^")
    end
    if #list - offset > PARAMS:ITEMS_LENGTH(term) then
      term.setTextColor(colors.yellow)
      term.setCursorPos(1, PARAMS:ITEMS_END(term))
      term.write("v")
      termFns.LeftWrite(term, termFns.W(term), PARAMS:ITEMS_END(term), "v")
    end
  end

  return index, offset
end

---Draws the ui
---@param done? integer If loading something, current progress
---@param total? integer If loading something, end progress
---@param step? integer If loading something, current step
---@param steps? integer If loading something, total step
local function drawUI(done, total, step, steps)
  for _, term in pairs(info.terms) do
    pcall(term.setTextScale, 0.5)

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()

    -- Line 1
    term.setCursorPos(1, 1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.gray)
    term.clearLine()

    if done and total and step and steps then
      termFns.DetailedProgress(term, done, total, step, steps, colors.lime, colors.black)
    else

    end

    -- Line 2
    term.setCursorPos(1, 2)
    term.clearLine()

    term.write(info.state)
    termFns.LeftWrite(term, termFns.W(term), 2, info.step)

    -- Line -1
    term.setCursorPos(1, termFns.H(term) - 1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.gray)
    term.clearLine()


    -- Line -0
    term.setCursorPos(1, termFns.H(term))
    term.clearLine()
  end

  -- SelectArea
  if info.mode == modes.move then
    local list, counts, free = {}, {}, {}
    for k, v in pairs(manager.storages[info.source].items) do
      if k ~= "empty" then
        table.insert(list, k)
        table.insert(counts, "" .. v.count)
        table.insert(free, "" .. v.free)
      end
    end

    info.list.index, info.list.offset = drawList(list, info.list.index, info.list.offset, counts, free)
  end
end

local function clickHandling(button, x, y)
  -- TODO
end

local function keyHandling(key, holding)
  if key == keys.s or key == keys.down then
    info.list.index = info.list.index + 1
    drawUI()
  elseif key == keys.w or key == keys.up then
    info.list.index = info.list.index - 1
    drawUI()
  end
end

local function main()
  info.state = "Loading..."
  info.step = "Reading Items"

  manager:refreshAll(drawUI)

  info.state = info.source .. " -> " .. info.destination
  info.step = "(count/free)"
  info.list.index = 1

  drawUI()

  local eventQueue = {}
  local queueLen = 0

  local function execute()
    local eventData
    if queueLen == 0 then
      eventData = { os.pullEventRaw() }
    else
      eventData = table.remove(eventQueue, 1)
    end

    if eventData[1] == "peripheral" then
      for _, v in pairs(config.monitors) do
        if v == eventData[2] then
          table.insert(info.terms, peripheral.wrap(v))
          drawUI()
          break
        end
      end

      if peripheral.hasType(eventData[2], "inventory") then
        local oldState, oldStep = info.state, info.step
        info.state = "Updating Chest..."
        info.step = "Reading Items"

        manager:addChest(eventData[2], drawUI)

        info.state = oldState
        info.step = oldStep

        drawUI()
      end
    elseif eventData[1] == "peripheral_detach" then
      for k, v in pairs(info.terms) do
        local ok, name = pcall(peripheral.getName, v)
        if ok then
          if name == eventData[2] then
            if peripheral.hasType(v, "monitor") then
              table.remove(info.terms, k)
            end
            break
          end
        end
      end

      if manager.chests[eventData[2]] then
        manager:removeChest(eventData[2])
      end

      drawUI()
    elseif eventData[1] == "term_resize" or eventData[1] == "monitor_resize" then
      drawUI()
    elseif eventData[1] == "key" then
      keyHandling(eventData[2], eventData[3])
    elseif eventData[1] == "mouse_click" then
      clickHandling(eventData[1], eventData[3], eventData[4])
    elseif eventData[1] == "mouse_scroll" then
      if eventData[4] <= PARAMS:ITEMS_END(term) and eventData[4] >= PARAMS:ITEMS_START() then
        info.list.index = info.list.index + eventData[2]
        drawUI()
      end
    end
  end

  local function catchEvents()
    if queueLen == 0 then
      os.pullEventRaw()
    end
    while true do
      table.insert(eventQueue, { os.pullEventRaw() })
    end
  end

  while true do
    parallel.waitForAny(catchEvents, execute)
    queueLen = #eventQueue
  end
end

local function terminateHandler()
  os.pullEventRaw("terminate")
  for _, term in pairs(info.terms) do
    term.setTextColor(colors.red)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
  end
  print("Terminated")
end

parallel.waitForAny(terminateHandler, main)
