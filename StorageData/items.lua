local DEFAULT_STORAGE = "Main Storage"

---Checks if an item is included in the table
---@generic T item type
---@param table T[] Table to check
---@param item T Item to check for
---@return boolean found Item found
local function tableIncludes(table, item)
	for k, v in pairs(table) do
		if v == item then return true end
	end
	return false
end

---@alias StorageConfig {[string]: string[]} List of storages other than "Storage", all chests not listed are part of "Storage", a chest may only have one storage, and will use the one first found by pairs()

---@alias UpdateFn fun(done, total, step, steps)


---@class Storage
---@field count integer      Number of items
---@field free integer       Number of total maxCount of empty slots
---@field reserved integer   Number of total free of all non-empty items
---@field chests string[]    List of chests in the storage
---@field items ItemList     List of items and empty slots in storage

---@class ItemList
---@field empty EmptyItem   Empty slots
---@field [string] Item     Items

---@class EmptyItem
---@field count integer                  Number of free slots
---@field free integer                   Number of items that fit in the slots
---@field chests {[string]: integer[]}   Chest -> Slots

---@class Item
---@field displayName string             The displayName of the first of this item, most likely unnamed
---@field tags {[string]: boolean}       The tags of the first of this item, most likely correct (and I don't think they can change)
---@field count integer                  Total number of item
---@field free integer                   Total maxCount - count
---@field chests {[string]: integer[]}   Chest -> Slots


---@class Chest
---@field count integer      Current number of items in chest
---@field free integer       Total maxCount of all empty slots
---@field reserved integer   Total maxCount - count of all non-empty slots
---@field storage string     The first storage the chest was listed as in the config
---@field slots ItemSlot[]   List of slots in the chest

---@class ItemSlot
---@field count integer                      Amount of item
---@field maxCount integer                   Item limit of the slot
---@field name string | nil                  Internal name of item, nil if empty
---@field displayName string                 Display name of the item, should be "" if empty
---@field nbt string | nil                   Nbt hash, nil if empty or no nbt tags
---@field tags { [string]: boolean } | nil   Table of item tags, nil if empty


--[[
{
	storages: {
		[storage]: {
			count: integer      Number of items
			free: integer       Number of total maxCount of empty slots
			reserved: integer   Number of total free of all non-empty items
			chests: string[]    List of chests in the storage
			items: {
				empty: {
					count: integer         Number of free slots
					free: integer          Number of items that fit in the slots
					chests: {
						[chest]: integer[]   Chest -> Slots
					}
				},
				[item]: {
					displayName: string         The displayName of the first of this item, most likely unnamed
					tags: {[string]: boolean}   The tags of the first of this item, most likely correct (and I don't think they can change)
					count: integer              Total number of item
					free: integer               Total maxCount - count
					chests: {
						[string]: integer[]       Chest -> Slots
					}
				}
			}
		}
	}
	chests: {
		[chest]: {
			count: integer      Current number of items in chest
			free: integer       Total maxCount of all empty slots
			reserved: integer   Total maxCount - count of all non-empty slots
			storage: string     The first storage the chest was listed as in the config
			slots: {
        count: integer                      Amount of item
        maxCount: integer                   Item limit of the slot
        name: string | nil                  Internal name of item, nil if empty
				displayName: string                 Display name of the item, should be "" if empty
        nbt: string | nil                   Nbt hash, nil if empty or no nbt tags
        tags: { [string]: boolean } | nil   Table of item tags, nil if empty
			}[]
		}
	}
}
]]


---Creates an Items object
---@param storageConfig StorageConfig
---@return ItemManager
local function itemsInstancer(storageConfig)
	---@type {[string]: Storage}
	local storages = {}

	for storage, chests in pairs(storageConfig) do
		local newChests = {}

		for _, chest in ipairs(chests) do
			if not tableIncludes(newChests, chest) then
				local used = false

				for _, storageData in pairs(storages) do
					if tableIncludes(storageData.chests, chest) then
						used = true
						break
					end
				end

				if not used then
					table.insert(newChests, chest)
				end
			end
		end

		storages[storage] = {
			count = 0,
			free = 0,
			reserved = 0,
			chests = chests,
			items = {
				empty = {
					count = 0,
					free = 0,
					chests = {}
				}
			}
		}
	end

	if not storages[DEFAULT_STORAGE] then
		storages[DEFAULT_STORAGE] = {
			count = 0,
			free = 0,
			reserved = 0,
			chests = {},
			items = {
				empty = {
					count = 0,
					free = 0,
					chests = {}
				}
			}
		}
	end

	---@class ItemManager
	---@field storages {[string]: Storage}
	---@field chests {[string]: Chest}
	local items = {
		storages = storages,
		chests = {},

		---Generates ItemSlot for a chest slot, creating the correct empty data if the details are nil
		---@param chest string The chest of the slot
		---@param slot integer The slot to get the details of
		---@return ItemSlot detials The details of the slot
		getDetails = function(chest, slot)
			local details, maxCount

			parallel.waitForAll(function()
				details = peripheral.call(chest, "getItemDetail", slot)
			end, function()
				maxCount = peripheral.call(chest, "getItemLimit", slot)
			end)

			if not details then
				details = {
					count = 0,
					maxCount = maxCount,
					displayName = ""
				}
			end

			return details
		end,

		---Finds the storage that includes the chest, should only be needed when creating new chest data
		---@param t ItemManager
		---@param chest string
		---@return string storage
		findStorage = function(t, chest)
			for storage, storageData in pairs(t.storages) do
				if tableIncludes(storageData.chests, chest) then
					return storage
				end
			end

			table.insert(t.storages[DEFAULT_STORAGE].chests, chest)
			return DEFAULT_STORAGE
		end,

		---Removes a slot from an existing chest
		---@param t ItemManager
		---@param chest string The chest to remove from
		---@param slot integer The slot to remove
		removeSlot = function(t, chest, slot)
			local oldData = t.chests[chest].slots[slot]

			if oldData then
				if oldData.name then
					-- chest, storage, storage.item; counts
					t.chests[chest].count =
							t.chests[chest].count - oldData.count
					t.storages[t.chests[chest].storage].count =
							t.storages[t.chests[chest].storage].count - oldData.count
					t.storages[t.chests[chest].storage].items[oldData.name].count =
							t.storages[t.chests[chest].storage].items[oldData.name].count - oldData.count

					-- chest, storage, storage.item; reserved
					t.chests[chest].reserved =
							t.chests[chest].reserved - oldData.maxCount + oldData.count
					t.storages[t.chests[chest].storage].reserved =
							t.storages[t.chests[chest].storage].reserved - oldData.maxCount + oldData.count
					t.storages[t.chests[chest].storage].items[oldData.name].free =
							t.storages[t.chests[chest].storage].items[oldData.name].free - oldData.maxCount + oldData.count

					for k, v in pairs(t.storages[t.chests[chest].storage].items[oldData.name].chests[chest]) do
						if v == slot then
							table.remove(t.storages[t.chests[chest].storage].items[oldData.name].chests[chest], k)
							break
						end
					end
				else
					-- storage.item; counts
					t.storages[t.chests[chest].storage].items.empty.count =
							t.storages[t.chests[chest].storage].items.empty.count - 1

					-- chest, storage, storage.item; free
					t.chests[chest].free =
							t.chests[chest].free - oldData.maxCount
					t.storages[t.chests[chest].storage].free =
							t.storages[t.chests[chest].storage].free - oldData.maxCount
					t.storages[t.chests[chest].storage].items.empty.free =
							t.storages[t.chests[chest].storage].items.empty.free - oldData.maxCount

					for k, v in pairs(t.storages[t.chests[chest].storage].items.empty.chests[chest]) do
						if v == slot then
							table.remove(t.storages[t.chests[chest].storage].items.empty.chests[chest], k)
							break
						end
					end
				end
			end

			t.chests[chest].slots[slot] = nil
		end,

		---Adds a slot to an existing chest
		---@param t ItemManager
		---@param chest string The chest to add to
		---@param slot integer The slot to add
		---@param newData ItemSlot The data to add
		addSlot = function(t, chest, slot, newData)
			if newData.name then
				if not t.storages[t.chests[chest].storage].items[newData.name] then
					t.storages[t.chests[chest].storage].items[newData.name] = {
						displayName = newData.displayName,
						tags = newData.tags,
						count = 0,
						free = 0,
						chests = {}
					}
				end
			end

			if newData.name then
				-- chest, storage, storage.item; counts
				t.chests[chest].count =
						t.chests[chest].count + newData.count
				t.storages[t.chests[chest].storage].count =
						t.storages[t.chests[chest].storage].count + newData.count
				t.storages[t.chests[chest].storage].items[newData.name].count =
						t.storages[t.chests[chest].storage].items[newData.name].count + newData.count

				-- chest, storage, storage.item; reserved
				t.chests[chest].reserved =
						t.chests[chest].reserved + newData.maxCount - newData.count
				t.storages[t.chests[chest].storage].reserved =
						t.storages[t.chests[chest].storage].reserved + newData.maxCount - newData.count
				t.storages[t.chests[chest].storage].items[newData.name].free =
						t.storages[t.chests[chest].storage].items[newData.name].free + newData.maxCount - newData.count

				if not t.storages[t.chests[chest].storage].items[newData.name].chests[chest] then
					t.storages[t.chests[chest].storage].items[newData.name].chests[chest] = { slot }
				else
					table.insert(t.storages[t.chests[chest].storage].items[newData.name].chests[chest], slot)
				end
			else
				-- storage.item; counts
				t.storages[t.chests[chest].storage].items.empty.count =
						t.storages[t.chests[chest].storage].items.empty.count + 1

				-- chest, storage, storage.item; free
				t.chests[chest].free =
						t.chests[chest].free + newData.maxCount
				t.storages[t.chests[chest].storage].free =
						t.storages[t.chests[chest].storage].free + newData.maxCount
				t.storages[t.chests[chest].storage].items.empty.free =
						t.storages[t.chests[chest].storage].items.empty.free + newData.maxCount

				if not t.storages[t.chests[chest].storage].items.empty.chests[chest] then
					t.storages[t.chests[chest].storage].items.empty.chests[chest] = { slot }
				else
					table.insert(t.storages[t.chests[chest].storage].items.empty.chests[chest], slot)
				end
			end

			t.chests[chest].slots[slot] = newData
		end,

		---Removes all data from a chest
		---@param t ItemManager
		---@param chest string The chest to remove
		removeChest = function(t, chest)
			if t.chests[chest] then
				for slot = 1, #t.chests[chest].slots do
					t:removeSlot(chest, slot)
				end
			end

			t.chests[chest] = nil
		end,

		---Loads all data from a chest from scratch
		---@param t ItemManager
		---@param chest string The chest to remove
		---@param updateFunction? UpdateFn
		addChest = function(t, chest, updateFunction, step, steps)
			if not peripheral.hasType(chest, "inventory") then
				return
			end

			if not updateFunction then
				updateFunction = function(done, total, step, steps) end
			end
			if not step or not steps then
				step, steps = 1, 1
			end

			t.chests[chest] = {
				count = 0,
				free = 0,
				reserved = 0,
				storage = t:findStorage(chest),
				slots = {}
			}

			local size = peripheral.call(chest, "size")

			for slot = 1, size do
				updateFunction(slot - 1, size, step, steps)

				local details = t.getDetails(chest, slot)

				t:addSlot(chest, slot, details)
			end

			updateFunction(size, size, step, steps)
		end,

		---Clears all data and loads it from scratch
		---@param t ItemManager
		---@param updateFunction? UpdateFn
		refreshAll = function(t, updateFunction)
			for storage, _ in pairs(t.storages) do
				t.storages[storage].count = 0
				t.storages[storage].free = 0
				t.storages[storage].reserved = 0
				t.storages[storage].items = {
					empty = {
						count = 0,
						free = 0,
						chests = {}
					}
				}
			end

			t.chests = {}

			local invens = { peripheral.find("inventory") }

			for k, inven in pairs(invens) do
				t:addChest(peripheral.getName(inven), updateFunction, k, #invens)
				sleep(0.05)
			end
		end,

		---Call pullItems on baseName, and update the database accordingly
		---@param t ItemManager
		---@param fromName string Name of the chest to move items from
		---@param fromSlot integer The slot index to move items from
		---@param toName string Name of the peripheral to call this function on
		---@param toSlot integer The slot index to move items to
		---@param limit? integer The maximum amount of items to move
		---@return integer moved The number of items moved
		moveItems = function(t, fromName, fromSlot, toName, toSlot, limit)
			local oldData = t.chests[fromName].slots[fromSlot]
			if oldData.name == nil then return 0 end
			local transfered = peripheral.call(toName, "pullItems", fromName, fromSlot, limit, toSlot)

			if transfered == 0 then return 0 end

			local newCount = oldData.count - transfered
			local newData
			if newCount == 0 then
				newData = {
					count = 0,
					maxCount = peripheral.call(fromName, "getItemLimit", fromSlot),
					displayName = ""
				}
			else
				newData = {}
				for k, v in pairs(oldData) do
					newData[k] = v
				end
				newData.count = newCount
			end

			t:removeSlot(fromName, fromSlot)
			t:addSlot(fromName, fromSlot, newData)

			local oldToData = t.chests[toName].slots[toSlot]
			local newToData
			if oldToData.name == nil then
				newToData = {}
				for k, v in pairs(oldData) do
					newToData[k] = v
				end
				newToData.count = transfered
				newToData.maxCount = peripheral.call(toName, "getItemLimit", toSlot)
			else
				newToData = {}
				for k, v in pairs(oldToData) do
					newToData[k] = v
				end
				newToData.count = oldToData.count + transfered
			end

			t:removeSlot(toName, toSlot)
			t:addSlot(toName, toSlot, newToData)

			return transfered
		end,

		---Tries to merge non-full stacks into as few as possible
		---@param t ItemManager
		---@param storage string The storage to optimize items in
		---@param updateFunction? UpdateFn
		optimizeStorage = function(t, storage, updateFunction)
			if not updateFunction then updateFunction = function(done, total, step, steps) end end

			local steps = #t.storages[storage].chests
			for step, chest in t.storages[storage].chests do
				updateFunction(0, #t.chests[chest].slots, step, steps)
				if t.chests[chest] then
					for slot = 1, #t.chests[chest].slots do
						local data = t.chests[chest].slots[slot]

						if data.count < data.maxCount and data.name then
							for toChest, _ in pairs(t.storages[storage].items[data.name].chests) do
								if t.chests[chest].slots[slot].count == 0 then
									break
								end

								local toSlots = {}

								for _, toSlot in ipairs(t.storages[storage].items[data.name].chests[toChest]) do
									table.insert(toSlots, toSlot)
								end

								for _, toSlot in ipairs(toSlots) do
									if t.chests[chest].slots[slot].count == 0 then
										break
									end

									if not (toChest == chest and toSlot == slot) and t.chests[toChest].slots[toSlot].count < t.chests[toChest].slots[toSlot].maxCount then
										t:moveItems(chest, slot, toChest, toSlot)
									end
								end
							end
						end

						updateFunction(slot, #t.chests[chest].slots, step, steps)
					end
				end
			end
		end,

		---Moves items of a type between storages
		---@param t ItemManager
		---@param source string The storage to move from
		---@param destination string The storage to move to
		---@param item string The type of item to move
		---@param updateFunction? UpdateFn
		---@param limit integer? The max amount of the item to move
		changeStorage = function(t, source, destination, item, updateFunction, limit)
			if not updateFunction then updateFunction = function(done, total, step, steps) end end

			local moved = 0

			local step, steps = 0, 0

			for _, _ in pairs(t.storages[source].items[item].chests) do
				steps = steps + 1
			end

			for fromChest, slots in pairs(t.storages[source].items[item].chests) do
				step = step + 1

				local total = #slots

				updateFunction(0, total, step, steps)
				if limit and moved >= limit then
					break
				end

				local fromSlots = {}

				for _, slot in ipairs(slots) do
					table.insert(fromSlots, slot)
				end

				for done, fromSlot in ipairs(fromSlots) do
					if limit and moved >= limit then
						break
					end

					if t.storages[destination].items[item] then
						for toChest, slots in pairs(t.storages[destination].items[item].chests) do
							if t.chests[fromChest].slots[fromSlot].count < 1 or (limit and moved >= limit) then
								break
							end

							local toSlots = {}

							for _, slot in ipairs(slots) do
								if t.chests[toChest].slots[slot].count < t.chests[toChest].slots[slot].maxCount then
									table.insert(toSlots, slot)
								end
							end

							for _, toSlot in ipairs(toSlots) do
								if t.chests[fromChest].slots[fromSlot].count < 1 or (limit and moved >= limit) then
									break
								end

								local left
								if limit then left = limit - moved end

								moved = moved + t:moveItems(fromChest, fromSlot, toChest, toSlot, left)
							end
						end
					end

					for toChest, slots in pairs(t.storages[destination].items.empty.chests) do
						if t.chests[fromChest].slots[fromSlot].count < 1 or (limit and moved >= limit) then
							break
						end

						local toSlots = {}

						for _, slot in ipairs(slots) do
							table.insert(toSlots, slot)
						end

						for _, toSlot in ipairs(toSlots) do
							if t.chests[fromChest].slots[fromSlot].count < 1 or (limit and moved >= limit) then
								break
							end

							local left
							if limit then left = limit - moved end

							moved = moved + t:moveItems(fromChest, fromSlot, toChest, toSlot, left)
						end
					end

					updateFunction(done, total, step, steps)
				end
			end
		end
	}

	return items
end

return itemsInstancer
