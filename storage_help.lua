-- Write help
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

print("MOVING")
print("Enter: Move all items of type to destination")
print("Backspace: Move all items from destination to storage")
print("Up/Down/W/S/Scroll: Change item")
print("F: Search")
print("")
print("SEARCH")
print("Enter: End search")
print("LCtrl+Backspace: Clear search")
print("Left/Right: Move cursor")
print("Ctrl+V: Paste from clipboard")

while true do
  os.pullEvent()
end
