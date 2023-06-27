--Functions to easily read and write files

---Reads data from a file
---@param name string File name
---@return any data File data
local function readData(name)
	local file = fs.open(name, "r")
	if not file then return nil end
	local outData = textutils.unserialise(file.readAll())
	file.close()
	return outData
end

---Writes data to a file
---@param name string File name
---@param data any File data
---@return boolean success
local function writeData(name, data)
	local file = fs.open(name, "w")
	if not file then return false end
	file.write(textutils.serialise(data))
	file.close()

	return true
end

---Reads text from a file
---@param name string File name
---@return string text File text
local function readText(name)
	local file = fs.open(name, "r")
	if not file then return "" end
	local outData = file.readAll()
	file.close()
	if not outData then return "" end
	return outData
end

---Writes text to a file
---@param name string File name
---@param text string File text
---@return boolean success
local function writeText(name, text)
	local file = fs.open(name, "w")
	if not file then return false end
	file.write(text)
	file.close()

	return true
end

---Appends text to a file
---@param name string File name
---@param text string File text
---@return boolean success
local function appendText(name, text)
	local file = fs.open(name, "a")
	if not file then return false end
	file.write(text)
	file.close()

	return true
end

return {
	readData = readData,
	writeData = writeData,
	readText = readText,
	writeText = writeText,
	appendText = appendText
}
