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
local function ReadData(path)
    expect(1, path, "string")
    local file = fs.open(path, "r")
    local data = textutils.unserialize(file.readAll())
    file.close()
    return data
end
local function ReadFile(path)
    expect(1, path, "string")
    local file = fs.open(path, "r")
    local data = file.readAll()
    file.close()
    return data
end
local function WriteData(path, data)
    expect(1, path, "string")
    local file = fs.open(path, "w")
    file.write(textutils.serialize(data))
    file.close()
end
local function WriteFile(path, data)
    expect(1, path, "string")
    expect(2, data, "string")
    local file = fs.open(path, "w")
    file.write(data)
    file.close()
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
local function VersionCompare(oldVersion, newVersion)
    expect(1, oldVersion, "table")
    field(oldVersion, "major", "number")
    field(oldVersion, "update", "number")
    field(oldVersion, "patch", "number")
    field(oldVersion, "branch", "string")
    expect(2, newVersion, "table")
    field(newVersion, "major", "number")
    field(newVersion, "update", "number")
    field(newVersion, "patch", "number")
    field(newVersion, "branch", "string")
    if oldVersion.major > newVersion.major then
        return false
    elseif oldVersion.major == newVersion.major then
        if oldVersion.update > newVersion.update then
            return false
        elseif oldVersion.update == newVersion.update then
            if oldVersion.patch < newVersion.patch then
                return true
            else
                return false
            end
        else
            return true
        end
    else
        return true
    end
end
local function VersionString(version)
    expect(1, version, "table")
    field(version, "major", "number")
    field(version, "update", "number")
    field(version, "patch", "number")
    field(version, "branch", "string")
    return tostring(version.major).."."..tostring(version.update).."."..tostring(version.patch)..version.branch
end
local function CenterWrite(terminal, y, s)
    expect(1, terminal, "table")
    expect(2, y, "number")
    expect(3, s, "string")
    local w = W(terminal)
    terminal.setCursorPos(math.floor((w/2) - (s:len()/2)), y)
    terminal.write(s)
end
local function LeftWrite(terminal, x, y, s)
    expect(1, terminal, "table")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, s, "string")
    terminal.setCursorPos(x+1-s:len(), y)
    terminal.write(s)
end

return {
    H = H,
    W = W,
    Speaker = Speaker,
    Color = Color,
    ReadData = ReadData,
    ReadFile = ReadFile,
    WriteData = WriteData,
    WriteFile = WriteFile,
    SetBackgroundColor = SetBackgroundColor,
    SetTextColor = SetTextColor,
    VersionCompare = VersionCompare,
    VersionString = VersionString,
    CenterWrite = CenterWrite,
    LeftWrite = LeftWrite
}