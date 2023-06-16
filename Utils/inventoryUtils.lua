--Functions to easily manage item storages

-- TODO: Probably needs optimizing (only try if we know we can find something, don't try if destination is full)
-- TODO: Count empty slots

---@class itemSlot
---@field count number Amount of item
---@field name string Name of item
---@field nbt string | nil nbt hash of item

---@class enchantment
---@field displayName string Display name of enchantment
---@field level number Enchantment level
---@field name string Name of enchantment

---@class detailedItemSlot
---@field count number Amount of item
---@field displayName string Display name of item
---@field maxCount number Item limit of item stack
---@field enchantments enchantment[] | nil Enchantments on item
---@field name string Name of item
---@field nbt string | nil
---@field tags { [string]: boolean } Table of item tags

---@class itemCount
---@field count number Item amount
---@field chests { chest: string, slot: number }[] Slots with item

---Lists all items and what chests to find them
---@param config config config
---@return { [string]: itemCount, ["empty"]: itemCount} outChest Items in outChest
---@return { [string]: itemCount, ["empty"]: itemCount} storage Items in storage
local function getItems(config)
	local outChest = peripheral.wrap(config.outChest)
	local chests = { peripheral.find("inventory", function(name, wrap) return name ~= config.outChest end) }
	local items = { empty = { chests = {}, count = 0 } }
	for _, chest in pairs(chests) do
		local contents = chest.list()
		local emptySlots = {}
		local removed = 0
		for i = 1, chest.size() do
			table.insert(emptySlots, i)
		end
		for i, data in pairs(contents) do
			table.remove(emptySlots, i - removed)
			if items[data.name] == nil then
				items[data.name] = { count = 0, chests = {} }
			end
			table.insert(items[data.name].chests, { chest = peripheral.getName(chest), slot = i })
			items[data.name].count = items[data.name].count + data.count
		end
		for _, i in pairs(emptySlots) do
			table.insert(items.empty.chests, { chest = peripheral.getName(chest), slot = i })
		end
	end

	local outItems = { empty = { chests = {}, count = 0 } }
	local contents = outChest.list()
	local emptySlots = {}
	local removed = 0
	for i = 1, outChest.size() do
		table.insert(emptySlots, i)
	end
	for i, data in pairs(contents) do
		table.remove(emptySlots, i - removed)
		if outItems[data.name] == nil then
			outItems[data.name] = { count = 0, chests = {} }
		end
		table.insert(outItems[data.name].chests, { chest = peripheral.getName(outChest), slot = i })
		outItems[data.name].count = outItems[data.name].count + data.count
	end
	for _, i in pairs(emptySlots) do
		table.insert(outItems.empty.chests, { chest = peripheral.getName(outChest), slot = i })
	end

	return outItems, items
end

---@alias key string | number

---Checks if a table includes an item
---@generic TableType
---@generic ItemType
---@param table { [key]: TableType } The table to check
---@param item ItemType The item to check for
---@param filter fun(key: key, entry: TableType, item: ItemType): boolean Function to use when checking, defaults to entry == item
---@return boolean
local function _tableIncludes(table, item, filter)
	if filter == nil then
		filter = function(key, entry, item)
			return entry == item
		end
	end
	for key, entry in pairs(table) do
		if filter(key, entry, item) then return true end
	end
	return false
end

---Checks if an item matches filters
---@param item detailedItemSlot
---@param name string | nil Item display name
---@param enchantments { ["name"]: string, ["level"]: number } | nil Item must have all enchantments at these levels
---@param tags string[] | nil Tags item must have
---@return boolean
local function _itemMatches(item, name, enchantments, tags)
	local ok = true
	if name ~= nil and item.displayName ~= name then ok = false end
	if enchantments ~= nil then
		if item.enchantments == nil then ok = false end
		for _, enchantment in pairs(enchantments) do
			if not _tableIncludes(item.enchantments, enchantment.name, function(_, entry, item)
						return entry.name == item
					end) then
				ok = false
			end
			if not _tableIncludes(item.enchantments, enchantment.level, function(_, entry, item)
						return item == nil or entry.level == item
					end) then
				ok = false
			end
		end
	end
	if tags ~= nil then
		for _, tag in pairs(tags) do
			if not _tableIncludes(item.tags, tag, function(key, entry, item)
						return key == item and entry
					end) then
				ok = false
			end
		end
	end
	return ok
end

---Remove all items from output chest
---@param config config config
---@param type string | nil Item name
---@param name string | nil Item display name
---@param enchantments { ["name"]: string, ["level"]: number } | nil Item must have all enchantments at these levels
---@param tags string[] | nil Tags items must have
local function insertItems(config, type, name, enchantments, tags)
	local outChest = peripheral.wrap(config.outChest)

	local localItems, storageItems = getItems(config)

	if type == nil then
		for slot = 1, outChest.size() do
			local slotCount = 0
			for _, _ in pairs(outChest.list()) do
				slotCount = slotCount + 1
			end
			if slotCount < 1 then
				break
			end
			if outChest.getItemDetail(slot) ~= nil then
				local ok = true
				if not _itemMatches(outChest.getItemDetail(slot), name, enchantments, tags) then ok = false end
				if ok then
					local chests = {}
					local itemStorage = storageItems[outChest.getItemDetail(slot).name]
					if itemStorage ~= nil then
						chests = itemStorage.chests
					end
					for _, chest in pairs(storageItems["empty"].chests) do
						if not _tableIncludes(chests, chest, function(key, entry, item)
									return entry.chest == item.chest
								end) then
							table.insert(chests, chest)
						end
					end
					for _, chest in pairs(chests) do
						if outChest.getItemDetail(slot) == nil then
							break
						end
						peripheral.wrap(chest.chest).pullItems(config.outChest, slot)
					end
				end
			end
		end
	else
		local localSlots = {}
		local localStorage = localItems[type]
		if localStorage ~= nil then
			for _, v in pairs(localStorage.chests) do
				table.insert(localSlots, v.slot)
			end
		end
		for _, slot in pairs(localSlots) do
			local slotCount = 0
			for _, _ in pairs(outChest.list()) do
				slotCount = slotCount + 1
			end
			if slotCount < 1 then
				break
			end
			if outChest.getItemDetail(slot) ~= nil then
				local ok = true
				if not _itemMatches(outChest.getItemDetail(slot), name, enchantments, tags) then ok = false end
				if ok then
					local chests = {}
					local itemStorage = storageItems[type]
					if itemStorage ~= nil then
						chests = itemStorage.chests
					end
					for _, chest in pairs(storageItems["empty"].chests) do
						if not _tableIncludes(chests, chest, function(key, entry, item)
									return entry.chest == item.chest
								end) then
							table.insert(chests, chest)
						end
					end
					for _, chest in pairs(chests) do
						if outChest.getItemDetail(slot) == nil then
							break
						end
						peripheral.wrap(chest.chest).pullItems(config.outChest, slot)
					end
				end
			end
		end
	end
end

---Move all matching items into output chest
---@param config config config
---@param type string | nil Item name
---@param name string | nil Item display name
---@param enchantments { ["name"]: string, ["level"]: number } | nil Item must have all enchantments at these levels
---@param tags string[] | nil Tags items must have
local function outputItems(config, type, name, enchantments, tags)
	insertItems(config) --Remove items from the output chest

	-- TODO: Probably needs optimizing

	local output_chest = peripheral.wrap(config.outChest)
	if type == nil then
		for _, chest in pairs({ peripheral.find("inventory", function(name, wrap) return name ~= config.outChest end) }) do
			for slot, _ in pairs(chest.list()) do
				local data = chest.getItemDetail(slot)
				if _itemMatches(data, name, enchantments, tags) then
					output_chest.pullItems(peripheral.getName(chest),
						slot)
				end
			end
		end
	else
		local _, chests = getItems(config)
		for _, slot in pairs(chests[type].chests) do
			local data = peripheral.call(slot.chest, "getItemDetail", slot.slot)
			if _itemMatches(data, name, enchantments, tags) then output_chest.pullItems(slot.chest, slot.slot) end
		end
	end
end

---Lists all matching items, or count of type if it is not nil
---@param config config config
---@param type string | nil Item name
---@param name string | nil Item display name
---@param enchantments { ["name"]: string, ["level"]: number } | nil Item must have all enchantments at these levels
---@param tags string[] | nil Tags items must have
---@return { [string]: number } | number counts item: number or just number if a type is specified
local function listItems(config, type, name, enchantments, tags)
	if type == nil then
		local out = {}
		for _, chest in pairs({ peripheral.find("inventory", function(name, wrap) return name ~= config.outChest end) }) do
			for slot, _ in pairs(chest.list()) do
				local data = chest.getItemDetail(slot)
				if _itemMatches(data, name, enchantments, tags) then
					if out[data.name] == nil then out[data.name] = 0 end
					out[data.name] = out[data.name] + data.count
				end
			end
		end
		return out
	end
	local _, chests = getItems(config)
	local out = 0
	for _, slot in pairs(chests[type].chests) do
		local data = peripheral.call(slot.chest, "getItemDetail", slot.slot)
		if _itemMatches(data, name, enchantments, tags) then out = out + data.count end
	end
	return out
end

---Lists all matching items, or count of type if it is not nil
---@param config config config
---@param type string | nil Item name
---@param name string | nil Item display name
---@param enchantments { ["name"]: string, ["level"]: number } | nil Item must have all enchantments at these levels
---@param tags string[] | nil Tags items must have
---@return { [string]: number } | number counts item: number or just number if a type is specified
local function listOutputed(config, type, name, enchantments, tags)
	if type == nil then
		local out = {}
		local chest = peripheral.wrap(config.outChest)
		for slot, _ in pairs(chest.list()) do
			local data = chest.getItemDetail(slot)
			if _itemMatches(data, name, enchantments, tags) then
				if out[data.name] == nil then out[data.name] = 0 end
				out[data.name] = out[data.name] + data.count
			end
		end
		return out
	end
	local _, chests = getItems(config)
	local out = 0
	for _, slot in pairs(chests[type].chests) do
		local data = peripheral.call(slot.chest, "getItemDetail", slot.slot)
		if _itemMatches(data, name, enchantments, tags) then out = out + data.count end
	end
	return out
end

return {
	getItems = getItems,
	insertItems = insertItems,
	outputItems = outputItems,
	listItems = listItems,
	listOutputed = listOutputed,
}
