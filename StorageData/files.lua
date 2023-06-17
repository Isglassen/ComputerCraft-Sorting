--Functions to easily read and write files

---Reads data from a file
---@param name string File name
---@return any data File data
local function readData(name)
	local file = fs.open(name, "r")
	local outData = textutils.unserialise(file.readAll())
	file.close()
	return outData
end

---Writes data to a file
---@param name string File name
---@param data any File data
local function writeData(name, data)
	local file = fs.open(name, "w")
	file.write(textutils.serialise(data))
	file.close()
end

---Reads text from a file
---@param name string File name
---@return string text File text
local function readText(name)
	local file = fs.open(name, "r")
	local outData = file.readAll()
	file.close()
	return outData
end

---Writes text to a file
---@param name string File name
---@param text string File text
local function writeText(name, text)
	local file = fs.open(name, "w")
	file.write(text)
	file.close()
end

---Appends text to a file
---@param name string File name
---@param text string File text
local function appendText(name, text)
	local file = fs.open(name, "a")
	file.write(text)
	file.close()
end

return {
	readData = readData,
	writeData = writeData,
	readText = readText,
	writeText = writeText,
	appendText = appendText
}
