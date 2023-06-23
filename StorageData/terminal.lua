local ccexpect = dofile("rom/modules/main/cc/expect.lua")
local expect, field, range = ccexpect.expect, ccexpect.field, ccexpect.range

local function H(terminal)
	local w, h = terminal.getSize()
	return h
end
local function W(terminal)
	local w, h = terminal.getSize()
	return w
end
local function Speaker()
	return peripheral.find("speaker")
end
local function Color(terminal)
	return terminal.isColor()
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
local function DetailedProgress(terminal, done, total, step, steps, fillCol, emptyCol)
	local endString = " "..done.."/"..total
	if steps > 1 then
		endString = endString.." ["..step.."/"..steps.."]"
	end
	WriteProgressBar(terminal, terminal.getSize() - (#endString + #(""..total) - #(""..done)), done / total, fillCol, emptyCol)
  for _ = 1, #(""..total) - #(""..done) do terminal.write(" ") end
  terminal.write(endString)
end

return {
	H = H,
	W = W,
	Speaker = Speaker,
	Color = Color,
	SetBackgroundColor = SetBackgroundColor,
	SetTextColor = SetTextColor,
	CenterWrite = CenterWrite,
	LeftWrite = LeftWrite,
	WriteProgressBar = WriteProgressBar,
	DetailedProgress = DetailedProgress
}
