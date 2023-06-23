---@class EmptyItem
---@field count number Number of free slots
---@field free number Number of items that fit in the slots
---@field chests {[string]: number[]} Reference to a slot in the chest list

---@class Item
---@field count number Total number of item
---@field free number Amount of empty space that can be added
---@field chests {[string]: number[]} Reference to a slot in the chest list

---@class Enchantment
---@field displayName string Display name of enchantment
---@field level number Enchantment level
---@field name string Internal name of enchantment

---@class ItemDetails
---@field count number Amount of item
---@field displayName string Display name of item
---@field maxCount number Item limit of item stack
---@field enchantments Enchantment[] | nil Enchantments on item
---@field name string | nil Internal name of item
---@field nbt string | nil Nbt hash i guess
---@field tags { [string]: boolean } | nil Table of item tags

---@class Chest
---@field count number Current number of items in chest
---@field empty {emptyCapacity: number, slots: number[]} Information about empty slots
---@field slots {[number]: ItemDetails}

---@class ItemsConfig
---@field outChest string Output chest name

---Creates an Items object
---@param config ItemsConfig
---@return Items
local function itemsInstancer(config)
	---@class Items
	---@field items {empty: EmptyItem, [string]: Item}
	---@field chests {[string]: Chest}
	---@field config ItemsConfig
	local items = {
		items = {
			empty = {
				count = 0,
				free = 0,
				chests = {}
			}
		},
		chests = {},
		config = config,

		---Clears all data and loads it from scratch
		---@param t Items
		---@param updateFunction? fun(done, total, step, steps) Function called after each slot is finished 
		refreshAll = function(t, updateFunction)
			t.chests = {}
			t.items = {
				empty = {
					count = 0,
					free = 0,
					chests = {}
				}
			}
			local chests = { peripheral.find("inventory") }

			local done, total = 0, 0

			for _, chest in pairs(chests) do
				total = total + chest.size()
			end

			if updateFunction then
				updateFunction(done, total, 1, 1)
			end

			for _, chest in pairs(chests) do
				local chestName = peripheral.getName(chest)

				local chestData = {
					count = 0,
					empty = {
						emptyCapacity = 0,
						slots = {}
					},
					slots = {}
				}

				for slot = 1, chest.size() do
					---@type ItemDetails
					local details = chest.getItemDetail(slot)

					if details == nil then
						details = {
							count = 0,
							displayName = "",
							maxCount = chest.getItemLimit(slot),
							name = nil
						}

						chestData.empty.emptyCapacity = chestData.empty.emptyCapacity + details.maxCount
						table.insert(chestData.empty.slots, slot)

						t.items.empty.count = t.items.empty.count + 1
						t.items.empty.free = t.items.empty.free + details.maxCount
						if t.items.empty.chests[chestName] == nil then
							t.items.empty.chests[chestName] = {}
						end
						table.insert(t.items.empty.chests[chestName], slot)
					else
						chestData.count = chestData.count + details.count

						if t.items[details.name] == nil then
							t.items[details.name] = {
								count = details.count,
								free = details.maxCount - details.count,
								chests = {
									[chestName] = { slot }
								}
							}
						else
							t.items[details.name].count = t.items[details.name].count + details.count
							t.items[details.name].free = t.items[details.name].free + details.maxCount - details.count
							if t.items[details.name].chests[chestName] == nil then
								t.items[details.name].chests[chestName] = { slot }
							else
								table.insert(t.items[details.name].chests[chestName], slot)
							end
						end
					end

					chestData.slots[slot] = details

					done = done + 1
					if updateFunction then
						updateFunction(done, total, 1, 1)
					end
				end

				t.chests[chestName] = chestData
			end

			if updateFunction then
				updateFunction(done, total, 1, 1)
			end
		end,

		---Removes all data from a chest and loads it from scratch
		---@param t Items
		---@param chest string Name of the chest
		---@param updateFunction? fun(done, total, step, steps) Function called after each slot is finished 
		refreshChest = function(t, chest, updateFunction)
			-- Remove exising values (Logging is commented because it's too quick)

			local step, steps = 0, 1

			-- step, steps = 1, 2

			local done, total = 0, 0
			if t.chests[chest] then
				total = #t.chests[chest].slots
				-- if updateFunction then
				-- 	updateFunction(done, total, step, steps)
				-- end

				for slot, info in pairs(t.chests[chest].slots) do
					if info.name == nil then
						t.items.empty.chests[chest] = nil
						t.items.empty.count = t.items.empty.count - 1
						t.items.empty.free = t.items.empty.free - info.maxCount
					else
						if t.items[info.name] then
							t.items[info.name].chests[chest] = nil
							t.items[info.name].count = t.items[info.name].count - info.count
							t.items[info.name].free = t.items[info.name].free + info.count - info.maxCount
						end
					end

					done = done + 1
					-- if updateFunction then
					-- 	updateFunction(done, total, step, steps)
					-- end
				end
			end

			-- if updateFunction then
			-- 	updateFunction(done, total, step, steps)
			-- end

			t.chests[chest] = nil

			-- Add new values
			step = step + 1

			done, total = 0, 0
			local inven = peripheral.wrap(chest)
			if inven then
				total = inven.size()

				if updateFunction then
					updateFunction(done, total, step, steps)
				end

				local chestData = {
					count = 0,
					empty = {
						emptyCapacity = 0,
						slots = {}
					},
					slots = {}
				}

				for slot = 1, inven.size() do
					---@type ItemDetails
					local details = inven.getItemDetail(slot)

					if details == nil then
						details = {
							count = 0,
							displayName = "",
							maxCount = inven.getItemLimit(slot),
							name = nil
						}

						chestData.empty.emptyCapacity = chestData.empty.emptyCapacity + details.maxCount
						table.insert(chestData.empty.slots, slot)

						t.items.empty.count = t.items.empty.count + 1
						t.items.empty.free = t.items.empty.free + details.maxCount
						if t.items.empty.chests[chest] == nil then
							t.items.empty.chests[chest] = {}
						end
						table.insert(t.items.empty.chests[chest], slot)
					else
						chestData.count = chestData.count + details.count

						if t.items[details.name] == nil then
							t.items[details.name] = {
								count = details.count,
								free = details.maxCount - details.count,
								chests = {
									[chest] = { slot }
								}
							}
						else
							t.items[details.name].count = t.items[details.name].count + details.count
							t.items[details.name].free = t.items[details.name].free + details.maxCount - details.count
							if t.items[details.name].chests[chest] == nil then
								t.items[details.name].chests[chest] = { slot }
							else
								table.insert(t.items[details.name].chests[chest], slot)
							end
						end
					end

					chestData.slots[slot] = details

					done = done + 1
					if updateFunction then
						updateFunction(done, total, step, steps)
					end
				end

				t.chests[chest] = chestData
			end

			if updateFunction then
				updateFunction(done, total, step, steps)
			end
		end,

		pullItems = function(t, baseName, fromName, fromSlot, limit, toSlot)
			-- pullItems on baseName, and update the database accordingly
			-- TODO
		end
	}

	return items
end

return itemsInstancer
