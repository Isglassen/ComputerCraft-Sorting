--Functions to easily mange fluid storages

-- TODO: Probably needs optimizing (only try if we know we can find something, don't try if destination is full)
-- TODO: Count empty slots

---@class config
---@field outTank string Name of the fluid output tank
---@field outChest string Name of the item output chest

---@class tank
---@field amount number Fluid amount
---@field name string Fluid name

---@class fluidCount
---@field amount number Fluid amount
---@field tanks string[] Tanks with fluid

---Lists all fluids and what tanks to find them
---@param config config config
---@return (tank | nil)[]
---@return {string: fluidCount, ["empty"]: fluidCount}
local function _getFluids(config)
	local outTank = peripheral.wrap(config.outTank)
	local tanks = { peripheral.find("fluid_storage", function(name, wrap) return name ~= config.outTank end) }
	local fluids = { empty = { tanks = {}, amount = 0 } }
	for _, tank in pairs(tanks) do
		local contents = tank.tanks()
		if #contents == 0 then
			table.insert(fluids.empty.tanks, peripheral.getName(tank))
		end
		for _, data in pairs(contents) do
			if fluids[data.name] == nil then
				fluids[data.name] = { amount = 0, tanks = {} }
			end
			table.insert(fluids[data.name].tanks, peripheral.getName(tank))
			fluids[data.name].amount = fluids[data.name].amount + data.amount
		end
	end
	-- TODO: Don't just return outTank.tanks()
	return outTank.tanks(), fluids
end

-- TODO: Add filter for insert

---Remove all fluids from output tank
---@param config config config
---@param type string | nil Fluid name
local function insertFluid(config, type)
	local _, tanks = _getFluids(config)
	local input_tank = peripheral.wrap(config.outTank)
	for _, tank in pairs(input_tank.tanks()) do
		local fluid = tank.name
		if type == nil or fluid == type then
			if tanks[fluid] then
				for _, output in pairs(tanks[fluid].tanks) do
					input_tank.pushFluid(output, nil, fluid)
				end
			end
			for _, output in pairs(tanks.empty.tanks) do
				input_tank.pushFluid(output, nil, fluid)
			end
		end
	end
end

---Move all fluids of type into output tank
---@param config config config
---@param type string Fluid name
local function outputFluid(config, type)
	insertFluid(config)   --Remove fluids from the output tank

	local _, tanks = _getFluids(config)
	local output_tank = peripheral.wrap(config.outTank)
	for _, tank in pairs(tanks[type].tanks) do
		output_tank.pullFluid(tank, nil, type)
	end
end

---List all fluids in system, or amount of certain type
---@param config config config
---@param type string | nil Fluid type to find
---@return { string: number } | number amounts fluid: number or just number if a type is specified
local function listFluid(config, type)
	local _, tanks = _getFluids(config)
	if type ~= nil then
		return tanks[type].amount
	end
	local out = {}
	for name, tank in pairs(tanks) do
		if name ~= "empty" then
			out[name] = tank.amount
		end
	end
	return out
end

return {
	insertFluid = insertFluid,
	outputFluid = outputFluid,
	listFluid = listFluid,
}
