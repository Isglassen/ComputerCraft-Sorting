local ccexpect = dofile("rom/modules/main/cc/expect.lua")
local expect = ccexpect.expect

---Returns the height of a terminal
---@param terminal CCRedirect
---@return integer
local function H(terminal)
	local _, h = terminal.getSize()
	return h
end
---Returns the width of a terminal
---@param terminal CCRedirect
---@return integer
local function W(terminal)
	local w, _ = terminal.getSize()
	return w
end
---Returns whether the terminal supports color
---@param terminal CCRedirect
---@return boolean
local function Color(terminal)
	return terminal.isColor()
end
---Sets the text color of the terminal if color is supported
---@param terminal CCRedirect
---@param color Color
local function SetTextColor(terminal, color)
	expect(1, terminal, "table")
	expect(2, color, "number")
	if Color(terminal) then
		terminal.setTextColor(color)
	end
end
---Sets the background color of the terminal if color is supported
---@param terminal CCRedirect
---@param color Color
local function SetBackgroundColor(terminal, color)
	expect(1, terminal, "table")
	expect(2, color, "number")
	if Color(terminal) then
		terminal.setBackgroundColor(color)
	end
end
---Writes text to the center of the terminal, on the specified y
---@param terminal CCRedirect
---@param y integer
---@param s string
local function CenterWrite(terminal, y, s)
	expect(1, terminal, "table")
	expect(2, y, "number")
	expect(3, s, "string")
	local w = W(terminal)
	terminal.setCursorPos(math.floor((w / 2) - (s:len() / 2)), y)
	terminal.write(s)
end
---Writes text so that the last character is at the specified x
---@param terminal CCRedirect
---@param x integer
---@param y integer
---@param s string
local function LeftWrite(terminal, x, y, s)
	expect(1, terminal, "table")
	expect(2, x, "number")
	expect(3, y, "number")
	expect(4, s, "string")
	terminal.setCursorPos(x + 1 - s:len(), y)
	terminal.write(s)
end
---Blits text so that the last character is at the specified x, see term.blit()
---@param terminal CCRedirect
---@param x integer
---@param y integer
---@param s string
---@param fg string
---@param bg string
local function LeftBlit(terminal, x, y, s, fg, bg)
	expect(1, terminal, "table")
	expect(2, x, "number")
	expect(3, y, "number")
	expect(4, s, "string")
	expect(5, fg, "string")
	expect(6, bg, "string")
	terminal.setCursorPos(x + 1 - s:len(), y)
	terminal.blit(s, fg, bg)
end
---Writes a progress bar to the screen
---@param terminal CCRedirect
---@param length integer Progress bar character length
---@param fillLevel number Fraction of bar filled
---@param fillCol Color The color of the filled area
---@param emptyCol Color The color of the empty area
local function WriteProgressBar(terminal, length, fillLevel, fillCol, emptyCol)
  local text, tCol, bCol = "", "", ""

  local doneSteps = length * fillLevel

  for i = 1, length do
    text = text .. " "
    tCol = tCol .. "0"
    if i <= doneSteps then
      bCol = bCol .. colors.toBlit(fillCol)
    else
      bCol = bCol .. colors.toBlit(emptyCol)
    end
  end
	
  terminal.blit(text, tCol, bCol)
end
---Writes a progress bar with added details to an entire row
---@param terminal CCRedirect
---@param done integer Amount of bar done
---@param total integer Total amount to fill the bar
---@param step integer Number of progress bar in a sequence
---@param steps integer Total number of progress bars in the sequence
---@param fillCol Color The color of the filled area
---@param emptyCol Color The color of the empty area
local function DetailedProgress(terminal, done, total, step, steps, fillCol, emptyCol)
	local _, y = terminal.getCursorPos()
	terminal.setCursorPos(1, y)
	local endString1 = " "..done.."/"..total
	local endString2

	local subAmount = endString1:len() + (""..total):len() - (""..done):len()
	if steps > 1 then
		endString2 = " ["..step.."/"..steps.."]"
		subAmount = subAmount + endString2:len() + (""..steps):len() - (""..step):len()
	end
	WriteProgressBar(terminal, terminal.getSize() - subAmount, done / total, fillCol, emptyCol)
  for _ = 1, (""..total):len() - (""..done):len() do terminal.write(" ") end
  terminal.write(endString1)
	if endString2 then
		for _ = 1, (""..steps):len() - (""..step):len() do terminal.write(" ") end
		terminal.write(endString2)
	end
end

return {
	H = H,
	W = W,
	Color = Color,
	SetBackgroundColor = SetBackgroundColor,
	SetTextColor = SetTextColor,
	CenterWrite = CenterWrite,
	LeftWrite = LeftWrite,
	LeftBlit = LeftBlit,
	WriteProgressBar = WriteProgressBar,
	DetailedProgress = DetailedProgress
}
