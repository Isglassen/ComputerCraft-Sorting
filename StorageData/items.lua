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

		refreshAll = function(t)
			local chests = {peripheral.find("inventory")}

			for _, chest in pairs(chests) do
				local chestData = {
					count = 0,
					empty = {
						emptyCapacity = 0,
						slots = {}
					},
					slots = {}
				}

				for slot = 1, chest.size() do
					-- Add chest data and update item data
				end

				t.chests[peripheral.getName(chest)] = chestData
			end
		end,

		refreshChest = function (t, chest)
			-- TODO
		end,
		
		pullItems = function (t, baseName, fromName, fromSlot, limit, toSlot)
			-- pullItems on baseName, and update the database accordingly
			-- TODO
		end
	}

	return items
end

return itemsInstancer
