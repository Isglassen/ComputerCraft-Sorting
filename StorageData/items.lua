---@class EmptyItem
---@field count integer Number of free slots
---@field free integer Number of items that fit in the slots
---@field chests {[string]: integer[]} Reference to a slot in the chest list

---@class Item
---@field count integer Total number of item
---@field free integer Amount of empty space that can be added
---@field chests {[string]: integer[]} Reference to a slot in the chest list

---@class Enchantment
---@field displayName string Display name of enchantment
---@field level integer Enchantment level
---@field name string Internal name of enchantment

---@class ItemDetails
---@field count integer Amount of item
---@field displayName string Display name of item
---@field maxCount integer Item limit of item stack
---@field enchantments Enchantment[] | nil Enchantments on item
---@field name string | nil Internal name of item
---@field nbt string | nil Nbt hash i guess
---@field tags { [string]: boolean } | nil Table of item tags

---@class Chest
---@field count integer Current number of items in chest
---@field empty {emptyCapacity: integer, slots: integer[]} Information about empty slots
---@field slots ItemDetails[]

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

			for _, chest in ipairs(chests) do
				total = total + chest.size()
			end

			if updateFunction then
				updateFunction(done, total, 1, 1)
			end

			for _, chest in ipairs(chests) do
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
							maxCount = chest.getItemLimit(slot)
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

				for slot, info in ipairs(t.chests[chest].slots) do
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
			if inven and peripheral.hasType(inven, "inventory") then
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
							maxCount = inven.getItemLimit(slot)
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

		---Call pullItems on baseName, and update the database accordingly
		---@param t Items
		---@param updateFunction? fun(done, total, step, steps) Function called after each slot is finished
		---@param baseName string Name of the peripheral to call this function on
		---@param fromName string Name of the chest to move items from
		---@param fromSlot integer The slot index to move items from
		---@param limit? integer The maximum amount of items to move
		---@param toSlot? integer The slot index to move items to
		---@return integer? moved The number of items moved
		pullItems = function(t, updateFunction, baseName, fromName, fromSlot, limit, toSlot)
			if not peripheral.hasType(baseName, "inventory") then
				return 0
			end
			if not peripheral.hasType(fromName, "inventory") then
				return 0
			end

			if t.chests[fromName] and t.chests[fromName].slots[fromSlot].name == nil then
				return 0
			end

			local baseChest = peripheral.wrap(baseName)
			local fromChest = peripheral.wrap(fromName)

			baseChest.pullItems(fromName, fromSlot, limit, toSlot)

			if (not t.chests[baseName]) or (not t.chests[fromName]) then
				local prevDone = 0
				local trueStep = 1
				local combinedUpdate = function(done, total, step, steps)
					if updateFunction then
						if prevDone > done then
							trueStep = trueStep + 1
						end
						prevDone = done
						updateFunction(done, total, trueStep, steps * 2)
					end
				end
				t:refreshChest(baseName, combinedUpdate)
				t:refreshChest(fromName, combinedUpdate)
				return
			end

			local oldDetails = t.chests[fromName].slots[fromSlot]
			---@type ItemDetails
			local newDetails = fromChest.getItemDetail(fromSlot)

			if newDetails == nil then
				newDetails = {
					count = 0,
					displayName = "",
					maxCount = fromChest.getItemLimit(fromSlot)
				}

				table.insert(t.chests[fromName].empty.slots, fromSlot)
				t.chests[fromName].empty.emptyCapacity = t.chests[fromName].empty.emptyCapacity + newDetails.maxCount

				t.items.empty.count = t.items.empty.count + 1
				if t.items.empty.chests[fromName] == nil then
					t.items.empty.chests[fromName] = { fromSlot }
				else
					table.insert(t.items.empty.chests[fromName], fromSlot)
				end
				t.items.empty.free = t.items.empty.free + newDetails.maxCount

				---@type string
				local itemName = oldDetails.name
				if t.items[itemName].chests[fromName] then
					for k, v in pairs(t.items[itemName].chests[fromName]) do
						if v == fromSlot then
							table.remove(t.items[itemName].chests[fromName], k)
							break
						end
					end
				end
				t.items[itemName].free = t.items[itemName].free + newDetails.maxCount
			end

			t.chests[fromName].slots[fromSlot] = newDetails

			local difference = oldDetails.count - newDetails.count

			t.chests[baseName].count = t.chests[baseName].count + difference
			t.chests[fromName].count = t.chests[fromName].count - difference

			if difference == 0 then
				return 0
			end

			if oldDetails.nbt then
				t:refreshChest(baseName, updateFunction)
				return difference
			end

			if toSlot ~= nil then
				local count = t.chests[baseName].slots[toSlot].count + difference
				t.chests[baseName].slots[toSlot] = oldDetails
				t.chests[baseName].slots[toSlot].count = count
				return difference
			end

			local remaining = difference

			for slot = 1, #t.chests[baseName].slots do
				if remaining < 1 then
					break
				end

				local slotData = t.chests[baseName].slots[slot]

				if slotData.name == oldDetails.name and not slotData.nbt then
					local space = slotData.maxCount - slotData.count
					local change = math.min(space, remaining)

					remaining = remaining - change

					t.chests[baseName].slots[slot].count = slotData.count + change

					-- items[item].chests, items[item].free
				elseif slotData.name == nil then
					---@type ItemDetails
					local newSlot = baseChest.getItemDetail(slot)
					if newSlot == nil then
						newSlot = {
							count = 0,
							displayName = "",
							maxCount = baseChest.getItemLimit(slot)
						}
					end

					if newSlot.name ~= nil then
						t.chests[baseName].empty.emptyCapacity = t.chests[baseName].empty.emptyCapacity - slotData.maxCount
						for k, v in pairs(t.chests[baseName].empty.slots) do
							if v == slot then
								table.remove(t.chests[baseName].empty.slots, k)
								break
							end
						end

						t.items.empty.count = t.items.empty.count - 1
						if t.items.empty.chests[baseName] then
							for k, v in pairs(t.items.empty.chests[baseName]) do
								if v == slot then
									table.remove(t.items.empty.chests[baseName], k)
									break
								end
							end
						end
						t.items.empty.free = t.items.empty.free - slotData.maxCount

						---@type string
						local itemName = newSlot.name

						if not t.items[itemName].chests[baseName] then
							t.items[itemName].chests[baseName] = { slot }
						else
							table.insert(t.items[itemName].chests[baseName], slot)
						end
						t.items[itemName].free = t.items[itemName].free + newSlot.maxCount - newSlot.count
					end

					remaining = remaining - newSlot.count

					t.chests[baseName].slots[slot] = newSlot
				end
			end

			return difference
		end
	}

	return items
end

return itemsInstancer
