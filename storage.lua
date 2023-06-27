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
  source = "Storage",
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
---@param countList? integer[] Count of item
---@param freeList? integer[] Free items (needs count)
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
    termFns.SetTextColor(term, colors.white)
    termFns.SetBackgroundColor(term, colors.black)

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
        leftString = "" .. count
        leftBlitT, leftBlitB = "", ""
        for _ = 1, ("" .. count):len() do
          if readIndex == index then
            leftBlitT = leftBlitT .. "3"
          else
            leftBlitT = leftBlitT .. "0"
          end

          leftBlitB = leftBlitB .. "f"
        end
        if free then
          leftString = leftString .. "/" .. free
          for _ = 1, ("/" .. free):len() do
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
        termFns.SetTextColor(term, colors.lightBlue)
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
        termFns.SetTextColor(term, colors.white)
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
      termFns.SetTextColor(term, colors.yellow)
      term.setCursorPos(1, PARAMS:ITEMS_START())
      term.write("^")
      termFns.LeftWrite(term, termFns.W(term), PARAMS:ITEMS_START(), "^")
    end
    if #list - offset > PARAMS:ITEMS_LENGTH(term) then
      termFns.SetTextColor(term, colors.yellow)
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
    termFns.SetTextColor(term, colors.white)
    termFns.SetBackgroundColor(term, colors.black)
    term.clear()

    -- Line 1
    term.setCursorPos(1, 1)
    termFns.SetTextColor(term, colors.white)
    termFns.SetBackgroundColor(term, colors.gray)
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
    termFns.SetTextColor(term, colors.white)
    termFns.SetBackgroundColor(term, colors.gray)
    term.clearLine()


    -- Line -0
    term.setCursorPos(1, termFns.H(term))
    term.clearLine()
  end

  -- SelectArea
  if info.mode == modes.move then
    local list, counts, free = {}, {}, {}
    for k, v in pairs(items.items) do
      if k ~= "empty" then
        table.insert(list, k)
        table.insert(counts, v.count)
        table.insert(free, v.free)
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

  items:refreshAll(drawUI)

  info.state = info.source .. " -> " .. info.destination
  info.step = "(count/free)"
  info.list.index = 1

  drawUI()

  while true do
    local eventData = { os.pullEventRaw() }

    if eventData[1] == "peripheral" or eventData[1] == "peripheral_detatch" then
      if eventData[1] == "peripheral" then
        for _, v in pairs(config.monitors) do
          if v == eventData[2] then
            table.insert(info.terms, peripheral.wrap(v))
            break
          end
        end
      elseif eventData[1] == "peripheral_detatch" then
        for k, v in pairs(info.terms) do
          if peripheral.getName(v) == eventData[2] then
            if peripheral.hasType(v, "monitor") then
              table.remove(info.terms, k)
            end
            break
          end
        end
      end
      local oldState, oldStep = info.state, info.step
      info.state = "Updating Chest..."
      info.step = "Reading Items"

      items:refreshChest(eventData[2], drawUI)

      info.state = oldState
      info.step = oldStep

      drawUI()
    elseif eventData[1] == "term_resize" then
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
end

local function terminateHandler()
  os.pullEventRaw("terminate")
  for _, term in pairs(info.terms) do
    termFns.SetTextColor(term, colors.red)
    termFns.SetBackgroundColor(term, colors.black)
    term.clear()
    term.setCursorPos(1, 1)
  end
  print("Terminated")
end

parallel.waitForAny(terminateHandler, main)