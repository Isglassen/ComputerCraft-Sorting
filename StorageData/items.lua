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
		refreshAll = function(t)
			t.chests = {}
			t.items = {
				empty = {
					count = 0,
					free = 0,
					chests = {}
				}
			}
			local chests = { peripheral.find("inventory") }

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
				end

				t.chests[chestName] = chestData
			end
		end,

		---Removes all data from a chest and loads it from scratch
		---@param t Items
		---@param chest string Name of the chest
		refreshChest = function(t, chest)
			-- TODO Remove exising values
			-- TODO Add new values
		end,

		pullItems = function(t, baseName, fromName, fromSlot, limit, toSlot)
			-- pullItems on baseName, and update the database accordingly
			-- TODO
		end
	}

	return items
end

return itemsInstancer
