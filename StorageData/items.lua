---@class EmptyItem
---@field count number Number of free slots
---@field free number Number of items that fit in the slots
---@field chests {[string]: number[]} Reference to a slot in the chest list

---@class Item
---@field count number Total number of item
---@field free number Amount of empty space that can be added
---@field chests {[string]: number[]} Reference to a slot in the chest list

---@class Enchantment

---@class ItemDetails
---@field count number Amount of item
---@field displayName string Display name of item
---@field maxCount number Item limit of item stack
---@field enchantments Enchantment[] | nil Enchantments on item
---@field name string Name of item
---@field nbt string | nil Nbt hash i guess
---@field tags { [string]: boolean } Table of item tags

---@class Chest
---@field count number Current number of items in chest
---@field empty {maxCapacity: number, slots: number[]} Information about empty slots
---@field slots {[number]: ItemDetails}

---@class Items
---@field items {empty: EmptyItem, [string]: Item}
---@field chests {[string]: Chest}
local items = {
	items = {
		empty = {
			count = 0,
			free = 0,
			chests = {}
		}
	},
	chests = {}
}