---Splits a string by seperator, https://stackoverflow.com/a/7615129
---@param inputstr string The string to split
---@param sep string? The gmatch seperator to split by, or %s by default
---@return string[] strings The list of split strings
local function splitStr(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local fileFns = require("StorageData.files")
local termFns = require("StorageData.terminal")

local programPath = fs.combine(shell.getRunningProgram(), "../")

shell.openTab(fs.combine(programPath, "./storage_help.lua"))

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


---@class UIConfig
---@field monitors string[] List of monitors to display items on
---@field use_displayName boolean Use display names instead of internal names (some items may have the same display name)

---@type UIConfig
local config = fileFns.readData(fs.combine(programPath, "./storage.cfg"))

if not config.monitors then
  config.monitors = {}
end

if config.use_displayName == nil then
  config.use_displayName = false
end

fileFns.writeData(fs.combine(programPath, "./storage.cfg"), config)


---@type ItemManager
local manager = require("StorageData.items")(storages)

--[[
  TOUCH SOLUTIONS:

  SEARCH:
    Scroll while hovering over the search changes the offset
    Clicking on the search area sets the cursor to the position that was clicked
      Blink should be under the clicked character, and clamped to 0 or the search length if outside those

  ITEMS:
    *Navigation already implemented*
    Clicking on a list element will perform the Enter operation on that item
    Clicking on the source inventory in the corner will perform the Ctrl+Enter operation
    Clicking on the destination inventory in the corner will perform the Backspace operation

  TODO: OTHER MODES
]]

--[[
  TODO: List of things

  Item move limit
  Touch Screen
  Refresh all
  Refresh chest
    Listed by storage
    Redstone updates output, you can detect someone interacting with the chests
  Switch source
  Switch destination
  Swap storages
  Edit config

  Item Search
    Should support Ctrl+Backspace to erase full words

  Information:
    Operation progress
    Current mode
    List of items/chests/storages
    Free space in destination
      Also free space for specific items

  Config:
    Replace underscores with spaces in items
    Storages that should be updated before operations
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
  ctrl = false,
  terms = { term },
  state = "",
  step = "",
  source = "Main Storage",
  destination = "Output",
  mode = modes.move,
  search = {
    value = "",
    cursor = 1,
    active = false,
    offset = 0,
    first = false,
  },
  list = {
    values = {},
    index = 1,
    offset = 0,
  }
}

for _, v in pairs(config.monitors) do
  if peripheral.hasType(v, "monitor") then
    table.insert(info.terms, peripheral.wrap(v))
  end
end

local PARAMS = {
  ITEMS_START = function(PARAMS) return 4 end,
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
      if not colonIndex then colonIndex = 0 end

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
          leftString = leftString .. free
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

    -- Line 2
    term.setCursorPos(1, 2)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.gray)
    term.clearLine()

    if done and total and step and steps then
      termFns.DetailedProgress(term, done, total, step, steps, colors.lime, colors.black)
    else
      --[[
        TODO: Draw actions
        ]]
    end

    -- Line 3
    term.setCursorPos(1, 3)
    term.clearLine()

    term.write(info.state)
    termFns.LeftWrite(term, termFns.W(term), 3, info.step)

    -- Line -1
    term.setCursorPos(1, termFns.H(term) - 1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.gray)
    term.clearLine()

    if info.mode == modes.move then
      term.write(info.source)
      termFns.LeftWrite(term, termFns.W(term), termFns.H(term) - 1, info.destination)
    end


    -- Line -0
    term.setCursorPos(1, termFns.H(term))
    term.clearLine()

    if info.mode == modes.move then
      local txt, fg, bg =
          manager.storages[info.source].count .. "/" ..
          manager.storages[info.source].free + manager.storages[info.source].count, "", ""
      for _ = 1, #txt do
        fg = fg .. "0"
        bg = bg .. "7"
      end
      term.blit(txt, fg, bg)
      if manager.storages[info.source].reserved > 0 then
        txt, fg, bg = "(+" .. manager.storages[info.source].reserved .. ")", "", ""
        for _ = 1, #txt do
          fg = fg .. "8"
          bg = bg .. "7"
        end
        term.blit(txt, fg, bg)
      end

      txt = ""
      if manager.storages[info.destination].reserved > 0 then
        txt, fg, bg = "(+" .. manager.storages[info.destination].reserved .. ")", "", ""
        for _ = 1, #txt do
          fg = fg .. "8"
          bg = bg .. "7"
        end
        termFns.LeftBlit(term, termFns.W(term), termFns.H(term), txt, fg, bg)
      end

      local xOffset = #txt

      txt, fg, bg =
          manager.storages[info.destination].count .. "/" ..
          manager.storages[info.destination].free + manager.storages[info.destination].count, "", ""
      for _ = 1, #txt do
        fg = fg .. "0"
        bg = bg .. "7"
      end
      termFns.LeftBlit(term, termFns.W(term) - xOffset, termFns.H(term), txt, fg, bg)
    end
  end

  -- SelectArea
  if info.mode == modes.move then
    local list, counts, free = {}, {}, {}
    info.list.values = {}
    for k, v in pairs(manager.storages[info.source].items) do
      local valid = true

      if k == "empty" then
        valid = false
      end

      if v.count < 1 then
        valid = false
      end

      ---@type Item
      v = v
      for _, searchTerm in ipairs(splitStr(info.search.value)) do
        if not valid then break end
        if searchTerm:sub(1, 1) == "#" then
          local hasTag = false
          local searchTag = searchTerm:sub(2):lower()
          for tag, bool in pairs(v.tags) do
            if bool and tag:lower():find(searchTag, 1, true) then
              hasTag = true
              break
            end
          end

          valid = valid and hasTag
        else
          if config.use_displayName then
            if not v.displayName:lower():find(searchTerm:lower(), 1, true) then
              valid = false
            end
          else
            if not v.name:lower():find(searchTerm:lower(), 1, true) then
              valid = false
            end
          end
        end
      end

      if valid then
        ---@type Item
        v = v
        table.insert(list, v.displayName)
        table.insert(counts, "" .. v.count)
        table.insert(free, "/" .. v.free)

        table.insert(info.list.values, k)
      end
    end

    info.list.index, info.list.offset = drawList(list, info.list.index, info.list.offset, counts, free)
  end

  if info.search.cursor < 0 and info.search.active then
    info.search.cursor = 0
  end
  if info.search.cursor > info.search.value:len() then
    info.search.cursor = info.search.value:len()
  end
  if info.search.value:len() < termFns.W(term) - ("Search: "):len() - 3 then
    info.search.offset = 0
  else
    if info.search.active then
      if info.search.cursor - info.search.offset < 3 then
        info.search.offset = info.search.cursor - 3
      end
      if info.search.cursor - info.search.offset > termFns.W(term) - ("Search: "):len() - 3 then
        info.search.offset = info.search.cursor - (termFns.W(term) - ("Search: "):len() - 3)
      end
    end

    info.search.offset = math.min(info.search.value:len() - (termFns.W(term) - ("Search: "):len() - 1),
      math.max(0, info.search.offset))
  end

  -- Line 1
  for _, term in pairs(info.terms) do
    term.setBackgroundColor(colors.white)
    term.setCursorPos(1, 1)
    term.clearLine()

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.write("Search:")

    term.setBackgroundColor(colors.white)

    if info.search.value == "" and not info.search.active then
      term.setTextColor(colors.lightGray)
      term.write(" Press F to search")
    else
      term.setTextColor(colors.black)
      if info.search.offset == 0 then
        term.write(" " .. info.search.value)
      else
        term.write(info.search.value:sub(info.search.offset))
      end
    end

    if info.search.active then
      term.setCursorPos(("Search: "):len() + 1 + info.search.cursor - info.search.offset, 1)
      term.setTextColor(colors.black)
      term.setCursorBlink(true)
    else
      term.setCursorBlink(false)
    end
  end
end

local function clickHandling(button, x, y)
  --[[
    TODO
    ]]
end

local function keyHandling(key, holding)
  if key == keys.leftCtrl then
    info.ctrl = true
  end
  if info.search.active then
    if key == keys.enter then
      info.search.active = false
      drawUI()
    elseif key == keys.backspace then
      if info.ctrl then
        --[[
          TODO: Actualy erase only to last whitespace
          ]]
        info.search.value = ""
        info.search.cursor = 0
      else
        info.search.value = info.search.value:sub(1, info.search.cursor - 1) ..
            info.search.value:sub(info.search.cursor + 1)
        info.search.cursor = math.max(0, info.search.cursor - 1)
      end
      drawUI()
    elseif key == keys.left then
      info.search.cursor = math.max(0, info.search.cursor - 1)
      drawUI()
    elseif key == keys.right then
      info.search.cursor = math.min(info.search.value:len(), info.search.cursor + 1)
      drawUI()
    end
  else
    if key == keys.enter and info.ctrl and info.mode == modes.move then
      local oldState, oldStep = info.state, info.step

      info.state = "Optimizing " .. info.source
      info.step = ""

      manager:optimizeStorage(info.source, drawUI)

      info.state, info.step = oldState, oldStep

      drawUI()
    elseif key == keys.enter and info.mode == modes.move then
      local oldState, oldStep = info.state, info.step

      local item = info.list.values[info.list.index]

      if item ~= nil then
        info.state = "Moving " .. item
        info.step = "Refreshing " .. info.destination

        for k, chest in ipairs(manager.storages[info.destination].chests) do
          manager:removeChest(chest)
          manager:addChest(chest, drawUI, k, #manager.storages[info.destination].chests)
        end

        info.step = "Moving items"

        manager:changeStorage(info.source, info.destination, item, drawUI)

        info.state, info.step = oldState, oldStep

        drawUI()
      end
    end
    if key == keys.backspace and info.mode == modes.move then
      local oldState, oldStep = info.state, info.step

      info.state = "Emptying " .. info.destination
      info.step = "Refreshing " .. info.destination

      for k, chest in ipairs(manager.storages[info.destination].chests) do
        manager:removeChest(chest)
        manager:addChest(chest, drawUI, k, #manager.storages[info.destination].chests)
      end

      info.step = "Moving items"

      local step, steps = 0, 0
      for _, _ in pairs(manager.storages[info.destination].items) do
        steps = steps + 1
      end

      for item, _ in pairs(manager.storages[info.destination].items) do
        if item ~= "empty" then
          step = step + 1
          manager:changeStorage(info.destination, info.source, item, drawUI, step, steps)
        end
      end

      info.state, info.step = oldState, oldStep

      drawUI()
    elseif key == keys.s or key == keys.down then
      info.list.index = info.list.index + 1
      drawUI()
    elseif key == keys.w or key == keys.up then
      info.list.index = info.list.index - 1
      drawUI()
    elseif key == keys.f then
      info.search.first = true
      info.search.cursor = info.search.value:len()
      info.search.active = true
      drawUI()
    end
  end
end

local function main()
  local eventQueue = {}

  -- Loading
  local function catchLoading()
    while true do
      local eventData = { os.pullEventRaw() }
      if eventData[1] == "peripheral" or eventData[1] == "peripheral_detach" then
        table.insert(eventQueue, eventData)
      end
    end
  end

  local function loading()
    info.state = "Loading..."
    info.step = "Reading Items"

    manager:refreshAll(drawUI)

    info.state = info.source .. " -> " .. info.destination
    info.step = "(count/free)"

    drawUI()
  end

  parallel.waitForAny(catchLoading, loading)
  local queueLen = #eventQueue

  -- Main Loop
  local function catchEvents()
    if queueLen == 0 then
      os.pullEventRaw()
    end
    while true do
      table.insert(eventQueue, { os.pullEventRaw() })
    end
  end

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
    elseif eventData[1] == "key_up" then
      if eventData[2] == keys.leftCtrl then
        info.ctrl = false
      end
    elseif eventData[1] == "char" and info.search.active then
      if info.search.first then
        info.search.first = false
      else
        info.search.value = info.search.value:sub(1, info.search.cursor) ..
            eventData[2] .. info.search.value:sub(info.search.cursor + 1)
        info.search.cursor = info.search.cursor + eventData[2]:len()
        drawUI()
      end
    elseif eventData[1] == "paste" and info.search.active then
      info.search.value = info.search.value:sub(1, info.search.cursor) ..
          eventData[2] .. info.search.value:sub(info.search.cursor + 1)
      info.search.cursor = info.search.cursor + eventData[2]:len()
      drawUI()
    elseif eventData[1] == "mouse_click" then
      clickHandling(eventData[1], eventData[3], eventData[4])
    elseif eventData[1] == "mouse_scroll" then
      if eventData[4] <= PARAMS:ITEMS_END(term) and eventData[4] >= PARAMS:ITEMS_START() then
        info.list.index = info.list.index + eventData[2]
        drawUI()
      elseif (eventData[3] > ("Search:"):len()) and (eventData[4] == 1) then
        if info.search.active then
          info.search.cursor = info.search.cursor - eventData[2]
        else
          info.search.offset = info.search.offset - eventData[2]
        end
        drawUI()
      end
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
