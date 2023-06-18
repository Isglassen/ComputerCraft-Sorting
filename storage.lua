-- TODO: Add fluids
-- TODO: Option of extra outputs

term.clear()

local termFns = require("StorageData.terminal")
local itemFns = require("StorageData.items")
local fileFns = require("StorageData.files")

local ITEMS_START = 3
local ITEMS_END = termFns.H(term) - 3
local ITEM_AREA_SIZE = ITEMS_END - ITEMS_START + 1

local MODES = {
  select = "Select",
  fluid = "Fluids",
  items = "Items",
  fluidOutput = "Fluid Output",
  fluidStorage = "Fluid Storage",
  itemOutput = "Item Output",
  itemStorage = "Item Storage",
}

local config = fileFns.readData("storage_config.txt")

local index = 1
local itemScroll = 1

---@type { name: string, count: number, chests: { chest: string, slot: number }[] }[]
local items = {}
local filter = ""
---@type { name: string, count: number, chests: { chest: string, slot: number }[] }[]
local filteredItems = {}
local mode = MODES.select

local function filterList()
  filteredItems = {}
  for _, v in pairs(items) do
    if v.name:find(filter, 1, true) then
      table.insert(filteredItems, v)
    end
  end
end

local function loadItems()
  filteredItems = {}
  local loadOutChest = mode == MODES.itemOutput

  items = {}
  local localItems, storedItems = itemFns.getItems(config)

  if loadOutChest then
    for k, v in pairs(localItems) do
      if k ~= "empty" then
        table.insert(items, { name = k, count = v.count, chests = v.chests })
      end
    end
  else
    for k, v in pairs(storedItems) do
      if k ~= "empty" then
        table.insert(items, { name = k, count = v.count, chests = v.chests })
      end
    end
  end

  filterList()
end

local function loadModes()
  filteredItems = {}
  filter = ""
  mode = MODES.itemStorage
  loadItems()
  local storageCount = 0
  for _, v in pairs(items) do
    storageCount = storageCount + v.count
  end
  mode = MODES.itemOutput
  loadItems()
  local localCount = 0
  for _, v in pairs(items) do
    localCount = localCount + v.count
  end
  items = {
    { name = MODES.itemOutput,  count = localCount },
    { name = MODES.itemStorage, count = storageCount }
  }
  mode = MODES.select
  filteredItems = items
end

local function drawList()
  for i = ITEMS_START, ITEMS_END, 1 do
    term.setCursorPos(1, i)
    local item
    local readIndex = itemScroll + i - ITEMS_START
    item = filteredItems[readIndex]
    if item == nil then
      break
    end
    if readIndex == index then
      termFns.SetTextColor(term, colors.lightBlue)
      term.write("[" .. item.name .. "]")
      termFns.LeftWrite(term, termFns.W(term), i, "[x" .. item.count .. "]")
    else
      termFns.SetTextColor(term, colors.white)
      term.write(" " .. item.name)
      termFns.LeftWrite(term, termFns.W(term) - 1, i, "x" .. item.count)
    end
  end
end

local function drawMain()
  term.clear()
  term.setCursorPos(1, 1)
  termFns.SetTextColor(term, colors.white)
  if mode == MODES.select then
    term.write("Select where to move from")
  else
    term.write("Moving from " .. mode)
  end
  drawList()
  if itemScroll > 1 then
    termFns.SetTextColor(term, colors.yellow)
    term.setCursorPos(1, ITEMS_START)
    term.write("^")
    termFns.LeftWrite(term, termFns.W(term), ITEMS_START, "^")
    termFns.SetTextColor(term, colors.white)
  end
  if itemScroll + ITEMS_END - ITEMS_START < #filteredItems then
    termFns.SetTextColor(term, colors.yellow)
    term.setCursorPos(1, ITEMS_END)
    term.write("v")
    termFns.LeftWrite(term, termFns.W(term), ITEMS_END, "v")
    termFns.SetTextColor(term, colors.white)
  end

  -- Draw controls at bottom

  if mode == MODES.select then
    term.setCursorPos(1, termFns.H(term) - 1)
    term.blit(
      "Enter: Select  E:           Backspace: Exit",
      "4444400000000004000000000000444444444000000",
      "fffffffffffffffffffffffffffffffffffffffffff")
    term.setCursorPos(1, termFns.H(term))
    term.blit(
      "F:             R: Reload",
      "400000000000000400000000",
      "ffffffffffffffffffffffff")
  else
    term.setCursorPos(1, termFns.H(term) - 1)
    term.blit(
      "Enter: Move    E: Move all  Backspace: Back",
      "4444400000000004000000000000444444444000000",
      "fffffffffffffffffffffffffffffffffffffffffff")
    term.setCursorPos(1, termFns.H(term))
    term.blit(
      "F: Search      R: Reload",
      "400000000000000400000000",
      "ffffffffffffffffffffffff")
  end
end

loadModes()

--Main Loop
while true do
  -- Check that scroll is not out of range
  if #filteredItems < ITEM_AREA_SIZE then
    itemScroll = 1
  end
  if itemScroll + ITEM_AREA_SIZE - 1 > #filteredItems then
    itemScroll = #filteredItems - ITEM_AREA_SIZE
  end
  if itemScroll < 1 then
    itemScroll = 1
  end

  -- Check that index is not out of range
  if index > #filteredItems then
    index = #filteredItems
  end
  if index < 1 then
    index = 1
  end

  drawMain()

  local type, key = os.pullEvent("key")

  if key == keys.up or key == keys.w then
    --Item above
    if index > 1 then
      index = index - 1
      if ((index - itemScroll) < 2) and (itemScroll > 1) then
        itemScroll = itemScroll - 1
      end
    end
  elseif key == keys.down or key == keys.s then
    --Item below
    if index < (#filteredItems) then
      index = index + 1
      if ((index - itemScroll) > ITEM_AREA_SIZE - 3) and (itemScroll < (#filteredItems - ITEM_AREA_SIZE + 1)) then
        itemScroll = itemScroll + 1
      end
    end
  elseif key == keys.backspace then
    if (mode ~= MODES.select) then
      index = 0
      loadModes()
    else
      term.clear()
      term.setCursorPos(1, 1)
      termFns.SetTextColor(term, colors.white)
      return
    end
  elseif key == keys.enter then
    if mode == MODES.select then
      mode = filteredItems[index].name
      loadItems()
    else
      --Move items and update list
      termFns.SetTextColor(term, colors.lime)
      term.setCursorPos(1, 1)
      term.clearLine()
      term.write("Moving " .. filteredItems[index].name .. " from " .. mode .. "...")
      if mode == MODES.itemOutput then
        itemFns.insertItems(config, filteredItems[index].name)
      else
        itemFns.outputItems(config, filteredItems[index].name)
      end

      loadItems()
    end
  elseif key == keys.e then
    if mode == MODES.itemOutput then
      termFns.SetTextColor(term, colors.lime)
      term.setCursorPos(1, 1)
      term.clearLine()
      term.write("Emptying items from output...")
      itemFns.insertItems(config)
      loadItems()
    elseif mode == MODES.itemStorage then
      itemFns.insertItems(config)
      loadItems()
      for k, v in pairs(items) do
        termFns.SetTextColor(term, colors.lime)
        term.setCursorPos(1, 1)
        term.clearLine()
        term.write("Re-sorting items in storage... (" .. k .. "/" .. #items .. ")")
        itemFns.outputItems(config, v.name)
      end
      itemFns.insertItems(config)
      loadItems()
    end
  elseif key == keys.r then
    loadItems()
  elseif key == keys.f then
    term.setCursorPos(1, termFns.H(term) - 1)
    term.blit(
      "Enter: Search",
      "4444400000000",
      "fffffffffffff")
    term.setCursorPos(1, termFns.H(term))
    termFns.SetTextColor(term, colors.white)
    term.write("Type nothing to remove search")
    term.setCursorPos(1, 1)
    term.clearLine()
    term.write("> ")
    filter = read(nil, nil, nil, filter)
    filterList()
  end
end
