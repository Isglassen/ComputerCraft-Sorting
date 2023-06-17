-- TODO: Add fluids
-- TODO: Option of extra outputs

term.clear()

local termFns = require("StorageData.terminal")
local itemFns = require("StorageData.items")
local fileFns = require("StorageData.files")

local ITEMS_START = 3
local ITEMS_END = termFns.H(term) - 2
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

local config = fileFns.readData("StorageData/config.txt")

local index = 1
local itemScroll = 1
local items = {}
local mode = MODES.select

local itemList = {}

local function loadItems()
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
end

local function loadModes()
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
end

local function drawList()
  for i = ITEMS_START, ITEMS_END, 1 do
    term.setCursorPos(1, i)
    local item = ""
    local readIndex = itemScroll + i - ITEMS_START
    item = items[readIndex]
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
    term.write("Moving from "..mode)
  end
  drawList()
  if itemScroll > 1 then
    termFns.SetTextColor(term, colors.yellow)
    term.setCursorPos(1, ITEMS_START)
    term.write("^")
    termFns.LeftWrite(term, termFns.W(term), ITEMS_START, "^")
    termFns.SetTextColor(term, colors.white)
  end
  if itemScroll + ITEMS_END - ITEMS_START < #items then
    termFns.SetTextColor(term, colors.yellow)
    term.setCursorPos(1, ITEMS_END)
    term.write("v")
    termFns.LeftWrite(term, termFns.W(term), ITEMS_END, "v")
    termFns.SetTextColor(term, colors.white)
  end

  -- Draw controls at bottom
end

loadModes()

--Main Loop
while true do
  -- Check that scroll is not out of range
  if #items < ITEM_AREA_SIZE then
    itemScroll = 1
  end
  if itemScroll + ITEM_AREA_SIZE - 1 > #items then
    itemScroll = #items - ITEM_AREA_SIZE
  end
  if itemScroll < 1 then
    itemScroll = 1
  end

  -- Check that index is not out of range
  if index > #items then
    index = #items
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
    if index < (#items) then
      index = index + 1
      if ((index - itemScroll) > ITEM_AREA_SIZE - 3) and (itemScroll < (#items - ITEM_AREA_SIZE + 1)) then
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
      mode = items[index].name
      loadItems()
    else
      --Move items and update list
      termFns.SetTextColor(term, colors.lime)
      termFns.LeftWrite(term, termFns.W(term), 1, "Moving " .. items[index].name .. "...")
      if mode == MODES.itemOutput then
        itemFns.insertItems(config, items[index].name)
      else
        itemFns.outputItems(config, items[index].name)
      end

      loadItems()
    end
  end

  -- TODO: Button to output/insert all
end
