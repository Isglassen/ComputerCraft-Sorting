local ccexpect = dofile("rom/modules/main/cc/expect.lua")
local expect, field, range = ccexpect.expect, ccexpect.field, ccexpect.range

local function H(term)
	local w, h = term.getSize()
	return h
end
local function W(term)
	local w, h = term.getSize()
	return w
end
local function Speaker()
	return peripheral.find("speaker")
end
local function Color(term)
	return term.isColor()
end
local function SetTextColor(terminal, color)
	expect(1, terminal, "table")
	expect(2, color, "number")
	if Color(terminal) then
		terminal.setTextColor(color)
	end
end
local function SetBackgroundColor(terminal, color)
	expect(1, terminal, "table")
	expect(2, color, "number")
	if Color(terminal) then
		terminal.setBackgroundColor(color)
	end
end
local function CenterWrite(terminal, y, s)
	expect(1, terminal, "table")
	expect(2, y, "number")
	expect(3, s, "string")
	local w = W(terminal)
	terminal.setCursorPos(math.floor((w / 2) - (s:len() / 2)), y)
	terminal.write(s)
end
local function LeftWrite(terminal, x, y, s)
	expect(1, terminal, "table")
	expect(2, x, "number")
	expect(3, y, "number")
	expect(4, s, "string")
	terminal.setCursorPos(x + 1 - s:len(), y)
	terminal.write(s)
end

return {
	H = H,
	W = W,
	Speaker = Speaker,
	Color = Color,
	SetBackgroundColor = SetBackgroundColor,
	SetTextColor = SetTextColor,
	CenterWrite = CenterWrite,
	LeftWrite = LeftWrite
}
