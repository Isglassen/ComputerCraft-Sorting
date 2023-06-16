---@meta

---@alias ColorSet integer
---@alias Color 1 | 2 | 4 |8 | 16 | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 | 4096 | 8192 | 16384 | 32768
---@alias CCRedirect CCTerm
---@alias Blit "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "a" | "b" | "c" | "d" | "e" | "f"

local oldUnpack = unpack

---Returns the elements from the given list.
---@generic T : any
---@param list T[]
---@param i? integer
---@param j? integer
---@return ...T items
function unpack(list, i, j)
    return list[i]
end

unpack = oldUnpack

---@class CCTerm
term = term

local oldNativeColour = term.nativePaletteColour
local oldWrite = term.write
local oldScroll = term.scroll
local oldGetCursor = term.getCursorPos
local oldSetCursor = term.setCursorPos
local oldGetBlink = term.getCursorBlink
local oldSetBlink = term.setCursorBlink
local oldGetSize = term.getSize
local oldClear = term.clear
local oldClearLine = term.clearLine
local oldGetText = term.getTextColour
local oldSetText = term.setTextColour
local oldGetBack = term.getBackgroundColour
local oldSetBack = term.setBackgroundColour
local oldColour = term.isColour
local oldBlit = term.blit
local oldSetPalette = term.setPaletteColour
local oldGetPalette = term.getPaletteColour
local oldRedirect = term.redirect
local oldCurrent = term.current
local oldNative = term.native

---Get the default palette value for a colour.
---@param colour Color The colour the get the default rgb for
---@return number r The amount of red from 0 to 1
---@return number g The amount of green from 0 to 1
---@return number b The amount of blue from 0 to 1
function term.nativePaletteColour(colour) local _ return _, _, _ end
---Get the default palette value for a colour.
---@param colour Color The colour the get the default rgb for
---@return number The amount of red from 0 to 1
---@return number The amount of green from 0 to 1
---@return number The amount of blue from 0 to 1
function term.nativePaletteColor(colour) local _ return _, _, _ end
---Write text at the current cursor position, moving the cursor to the end of the text.
---@param text string The text to write
function term.write(text) end
---Move all positions up (or down) by y pixels.
---@param y integer The amount to scroll by
function term.scroll(y) end
---Get the position of the cursor.
---@return integer x The x position of the cursor
---@return integer y The y position of the cursor
function term.getCursorPos() local _ return _, _ end
---Set the position of the cursor.
---@param x integer The x position to set the cursor at
---@param y integer The y position to set the cursor at
function term.setCursorPos(x, y) end
---Checks if the cursor is currently blinking.
---@return boolean blinking Whether the cursor is blinking
function term.getCursorBlink() local _ return _ end
---Sets whether the cursor should be visible (and blinking) at the current cursor position.
---@param blink boolean Whether the cursor should be blinking
function term.setCursorBlink(blink) end
---Get the size of the terminal.
---@return integer x The size on the x axis
---@return integer y The size on the y axis
function term.getSize() local _ return _, _ end
---Clears the terminal, filling it with the current background colour.
function term.clear() end
---Clears the line the cursor is currently on, filling it with the current background colour.
function term.clearLine() end
---Return the colour that new text will be written as.
---@return Color colour The colour that text will be written as
function term.getTextColour() local _ return _ end
---Return the colour that new text will be written as.
---@return Color colour The colour that text will be written as
function term.getTextColor() local _ return _ end
---Set the colour that new text will be written as.
---@param colour Color The colour to write new text as
function term.setTextColour(colour) end
---Set the colour that new text will be written as.
---@param colour Color The colour to write new text as
function term.setTextColor(colour) end
---Return the current background colour.
---@return Color colour The color that the background has
function term.getBackgroundColour() local _ return _ end
---Return the current background colour.
---@return Color colour The color that the background has
function term.getBackgroundColor() local _ return _ end
---Set the current background colour.
---@param colour Color The colour the background will have
function term.setBackgroundColour(colour) end
---Set the current background colour.
---@param colour Color The colour the background will have
function term.setBackgroundColor(colour) end
---Determine if this terminal supports colour.
---@return boolean isColour Whether the terminal supports colour 
function term.isColour() local _ return _ end
---Determine if this terminal supports colour.
---@return boolean isColour Whether the terminal supports colour 
function term.isColor() local _ return _ end
---Writes text to the terminal with the specific foreground and background characters.
---@param text string The text to write
---@param textColour string The hexadecimal for the colour to write text in for each character
---@param backgroundColour string The hexadecimal for the colour to write the background in for each character
function term.blit(text, textColour, backgroundColour) end
---Set the palette for a specific colour
---@param index Color The colour to change
---@param colour integer The decimal value for the rgb colour
function term.setPaletteColour(index, colour) end
---Set the palette for a specific colour
---@param index Color The colour to change
---@param r number The red value from 0 to 1
---@param g number The green value from 0 to 1
---@param b number The blue value from 0 to 1
function term.setPaletteColour(index, r, g, b) end
---Set the palette for a specific colour.
---@param index Color The colour to change
---@param colour integer The decimal value for the rgb colour
function term.setPaletteColor(index, colour) end
---Set the palette for a specific colour.
---@param index Color The colour to change
---@param r number The red value from 0 to 1
---@param g number The green value from 0 to 1
---@param b number The blue value from 0 to 1
function term.setPaletteColor(index, r, g, b) end
---Get the current palette for a specific colour.
---@param colour Color The colour to get
---@return number r The red value from 0 to 1
---@return number g The green value from 0 to 1
---@return number b The blue value from 0 to 1
function term.getPaletteColour(colour) local _ return _, _, _ end
---Get the current palette for a specific colour.
---@param colour Color The colour to get
---@return number r The red value from 0 to 1
---@return number g The green value from 0 to 1
---@return number b The blue value from 0 to 1
function term.getPaletteColor(colour) local _ return _, _, _ end
---Redirects terminal output to a monitor, a window, or any other custom terminal object.
---@param target CCRedirect The new terminal object
---@return CCRedirect previous The old terminal object
function term.redirect(target) local _ return _ end
---Returns the current terminal object of the computer.
---@return CCRedirect terminal The current terminal
function term.current() local _ return _ end
---Get the native terminal object of the current computer.
---@return CCRedirect terminal The default terminal
function term.native() local _ return _ end

term.nativePaletteColour = oldNativeColour
term.nativePaletteColor = oldNativeColour
term.write = oldWrite
term.scroll = oldScroll
term.getCursorPos = oldGetCursor
term.setCursorPos = oldSetCursor
term.getCursorBlink = oldGetBlink
term.setCursorBlink = oldSetBlink
term.getSize = oldGetSize
term.clear = oldClear
term.clearLine = oldClearLine
term.getTextColour = oldGetText
term.getTextColor = oldGetText
term.setTextColour = oldSetText
term.setTextColor = oldSetText
term.getBackgroundColour = oldGetBack
term.getBackgroundColor = oldGetBack
term.setBackgroundColour = oldSetBack
term.setBackgroundColor = oldSetBack
term.isColour = oldColour
term.isColor = oldColour
term.blit = oldBlit
term.setPaletteColour = oldSetPalette
term.setPaletteColor = oldSetPalette
term.getPaletteColour = oldGetPalette
term.getPaletteColor = oldGetPalette
term.redirect = oldRedirect
term.current = oldCurrent
term.native = oldNative

---@class CCColors
---@field white 1
---@field orange 2
---@field magenta 4
---@field lightBlue 8
---@field yellow 16
---@field lime 32
---@field pink 64
---@field gray 128
---@field lightGray 256
---@field cyan 512
---@field purple 1024
---@field blue 2048
---@field brown 4096
---@field green 8192
---@field red 16384
---@field black 32768
colors = colors

local oldCombine = colors.combine
local oldSubtract = colors.subtract
local oldTest = colors.test
local oldPack = colors.packRGB
local oldUnpack = colors.unpackRGB
local oldRgb8 = colors.rgb8
local oldBlit = colors.toBlit

---Combines a set of colors (or sets of colors) into a larger set
---@vararg ColorSet
---@return ColorSet combined Combined colors
function colors.combine(...) local _ return _ end
---Removes one or more colors (or sets of colors) from an initial set.
---@param colors ColorSet Set of colors to remove from
---@vararg ColorSet
---@return ColorSet new New set of colors
function colors.subtract(colors, ...) local _ return _ end
---Tests whether color is contained within colors.
---@param colors ColorSet Colors to check in
---@param color ColorSet Colors to check for 
---@return boolean Whether color is contained in colors
function colors.test(colors, color) local _ return _ end
---Combine a three-colour RGB value into one hexadecimal representation.
---@param r number 0-1 red brightness
---@param g number 0-1 green brightness
---@param b number 0-1 blue brightness
---@return integer hex Hexadecimal color
function colors.packRGB(r, g, b) local _ return _ end
---Separate a hexadecimal RGB colour into its three constituent channels.
---@param rgb integer Hexadecimal color
---@return number r 0-1 red brightness
---@return number g 0-1 green brightness
---@return number b 0-1 blue brightness
function colors.unpackRGB(rgb) local _ return _, _, _ end
---Calls colors.packRGB
---@param r number 0-1 red brightness
---@param g number 0-1 green brightness
---@param b number 0-1 blue brightness
---@return integer hex Hexadecimal color
---@deprecated Use colors.packRGB
function colors.rgb8(r, g, b) local _ return _ end
---Calls colors.unpackRGB
---@param rgb integer Hexadecimal color
---@return number r 0-1 red brightness
---@return number g 0-1 green brightness
---@return number b 0-1 blue brightness
---@deprecated Use colors.unpackRGB
function colors.rgb8(rgb) local _ return _, _, _ end
---Converts the given color to a paint/blit hex character (0-9a-f).
---@param color Color Color to convert
---@return Blit blit Blit string
function colors.toBlit(color) local _ return _ end

colors.combine = oldCombine
colors.subtract = oldSubtract
colors.test = oldTest
colors.packRGB = oldPack
colors.unpackRGB = oldUnpack
colors.rgb8 = oldRgb8
colors.toBlit = oldBlit

---@class CCFS
fs = fs

local oldIsDrive = fs.isDriveRoot
local oldComplete = fs.complete
local oldList = fs.list
local oldCombine = fs.combine
local oldName = fs.getName
local oldDir = fs.getDir
local oldSize = fs.getSize
local oldExists = fs.exists
local oldIsDir = fs.isDir
local oldReadOnly = fs.isReadOnly
local oldMkDir = fs.makeDir
local oldMove = fs.move
local oldCopy = fs.copy
local oldDelete = fs.delete
local oldOpen = fs.open
local oldDrive = fs.getDrive
local oldFree = fs.getFreeSpace
local oldFind = fs.find
local oldCap = fs.getCapacity
local oldAttributes = fs.attributes

---Returns true if a path is mounted to the parent filesystem
---@param path string The path to check
---@return boolean return If the path is mounted, rather than a normal file/folder
function fs.isDriveRoot(path) local _ return _ end

---Provides completion for a file or directory name
---@param path string The path to complete
---@param location string The location where paths are resolved from
---@param include_files boolean When false, only directories will be included in the returned list
---@param include_dirs boolean When false, "raw" directories will not be included in the returned list
---@return string[] completions A list of possible completion candidates
function fs.complete(path, location, include_files, include_dirs) local _ return _ end

---Returns a list of files in a directory
---@param path string The path to list
---@return string[] files A table with a list of files in the directory
function fs.list(path) local _ return _ end

---Combines several parts of a path into one full path, adding separators as needed
---@param ... string Path parts to combine
---@return string path The new path, with separators added between parts as needed
function fs.combine(...) local _ return _ end

---Returns the file name portion of a path
---@param path string The path to get the name from
---@return string name The final part of the path (the file name)
function fs.getName(path) local _ return _ end

---Returns the parent directory portion of a path
---@param path string The path to get the directory from
---@return string dir The path with the final part removed (the parent directory)
function fs.getDir(path) local _ return _ end

---Returns the size of the specified file
---@param path string The file to get the file size of
---@return integer size The size of the file, in bytes
function fs.getSize(path) local _ return _ end

---Returns whether the specified path exists
---@param path string The path to check the existence of
---@return boolean exists Whether the path exists
function fs.exists(path) local _ return _ end

---Returns whether the specified path is a directory
---@param path string The path to check
---@return boolean isDir Whether the path is a directory
function fs.isDir(path) local _ return _ end

---Returns whether a path is read-only
---@param path string The path to check
---@return boolean isReadOnly Whether the path cannot be written to
function fs.isReadOnly(path) local _ return _ end

---Creates a directory, and any missing parents, at the specified path
---@param path string The path to the directory to create
function fs.makeDir(path) end

---Moves a file or directory from one path to another
---@param path string The current file or directory to move from
---@param dest string The destination path for the file or directory
function fs.move(path, dest) end

---Copies a file or directory to a new path
---@param path string The file or directory to copy
---@param dest string The path to the destination file or directory
function fs.copy(path, dest) end

---Deletes a file or directory
---@param path string The path to the file or directory to delete
function fs.delete(path) end

---Opens a file for reading or writing at a path
---@param path string The path to the file to open
---@param mode "r" The mode to open the file with
---@return CCFileRead handle A file handle object for the file
---@return string? message A message explaining why the file cannot be opened
function fs.open(path, mode) local _ return _, _ end

---Opens a file for reading or writing at a path
---@param path string The path to the file to open
---@param mode "w"|"a" The mode to open the file with
---@return CCFileWrite? handle A file handle object for the file
---@return string? message A message explaining why the file cannot be opened
function fs.open(path, mode) local _ return _, _ end

---Opens a file for reading or writing at a path
---@param path string The path to the file to open
---@param mode "rb" The mode to open the file with
---@return CCFileBinaryRead? handle A file handle object for the file
---@return string? message A message explaining why the file cannot be opened
function fs.open(path, mode) local _ return _, _ end

---Opens a file for reading or writing at a path
---@param path string The path to the file to open
---@param mode "wb"|"ab" The mode to open the file with
---@return CCFileBinaryWrite? handle A file handle object for the file
---@return string? message A message explaining why the file cannot be opened
function fs.open(path, mode) local _ return _, _ end

---Returns the name of the mount that the specified path is located on
---@param path string The path to get the drive of
---@return string mount The name of the drive that the file is on; e.g. hdd for local files, or rom for ROM files
function fs.getDrive(path) local _ return _ end

---Returns the amount of free space available on the drive the path is located on
---@param path string The path to check the free space for
---@return integer | "unlimited" space The amount of free space available, in bytes, or "unlimited"
function fs.getFreeSpace(path) local _ return _ end

---Searches for files matching a string with wildcards
---@param path string The wildcard-qualified path to search for
---@return string[] paths A list of paths that match the search string
function fs.find(path) local _ return _ end

---Returns the capacity of the drive the path is located on
---@param path string The path of the drive to get
---@return number | nil capacity This drive's capacity. This will be nil for "read-only" drives, such as the ROM or treasure disks
function fs.getCapacity(path) local _ return _ end

---Get attributes about a specific file or folder. The creation and modification times are given as the number of milliseconds since the UNIX epoch
---@param path string The path to get attributes for
---@return {size:number, isDir: boolean, isReadOnly: boolean, created: integer, modified: number} attributes The resulting attributes
function fs.attributes(path) local _ return _ end

fs.isDriveRoot = oldIsDrive
fs.complete = oldComplete
fs.list = oldList
fs.combine = oldCombine
fs.getName = oldName
fs.getDir = oldDir
fs.getSize = oldSize
fs.exists = oldExists
fs.isDir = oldIsDir
fs.isReadOnly = oldReadOnly
fs.makeDir = oldMkDir
fs.move = oldMove
fs.copy = oldCopy
fs.delete = oldDelete
fs.open = oldOpen
fs.getDrive = oldDrive
fs.getFreeSpace = oldFree
fs.find = oldFind
fs.getCapacity = oldCap
fs.attributes = oldAttributes

---@class CCFileRead
local fileR = {}

---Read a line from the file
---@param withTrailing boolean? Whether to include the newline characters with the returned string. Defaults to false
---@return string | nil text The read line or nil if at the end of the file
function fileR.readLine(withTrailing) local _ return _ end

---Read the remainder of the file
---@return nil | string text The remaining contents of the file, or nil if we are at the end
function fileR.readAll() local _ return _ end

---Read a number of characters from this file
---@param count integer? The number of characters to read, defaulting to 1
---@return string | nil text The read characters, or nil if at the of the file
function fileR.read(count) local _ return _ end

---Close this file, freeing any resources it uses
function fileR.close() end

---@class CCFileBinaryRead
local fileRB = {}

---Read a number of bytes from this file
---@param count integer? The number of bytes to read. When absent, a single byte will be read as a number. This may be 0 to determine we are at the end of the file
---@return nil | integer | string bytes nil if eof, int if count is nil, string otherwise
function fileRB.read(count) local _ return _ end

---Read the remainder of the file
---@return string | nil bytes The remaining contents of the file, or nil if we are at the end
function fileRB.readAll() local _ return _ end

---Read a line from the file
---@param withTrailing boolean? Whether to include the newline characters with the returned string. Defaults to false
---@return string | nil bytes The read line or nil if at the end of the file
function fileRB.readLine(withTrailing) local _ return _ end

---Close this file, freeing any resources it uses
function fileRB.close() end

---Seek to a new position within the file, changing where bytes are written to. 
---The new position is an offset given by offset, relative to a start position determined by whence:
---"set": offset is relative to the beginning of the file.
---"cur": Relative to the current position. This is the default.
---"end": Relative to the end of the file.
---@param whence "set"|"cur"|"end" Where the offset is relative to
---@param offset integer The offset to seek to
---@return integer? pos The new position or nil if seeking failed
---@return string? reason The reason seeking failed
function fileRB.seek(whence, offset) local _ return _, _ end

---@class CCFileWrite
local fileW = {}

---Write a string of characters to the file
---@param value any The value to write to the file
function fileW.write(value) end

---Write a string of characters to the file, follwing them with a new line character
---@param value any The value to write to the file
function fileW.writeLine(value) end

---Save the current file without closing it
function fileW.flush() end

---Close this file, freeing any resources it uses
function fileW.close() end

---@class CCFileBinaryWrite
local fileWB = {}

---Write a string or byte to the file
---@param byte integer byte to write
function fileWB.write(byte) end

---Write a string or byte to the file
---@param ... string string to write
function fileWB.write(...) end

---Save the current file without closing it
function fileWB.flush() end

---Close this file, freeing any resources it uses
function fileWB.close() end

---Seek to a new position within the file, changing where bytes are written to. 
---The new position is an offset given by offset, relative to a start position determined by whence:
---"set": offset is relative to the beginning of the file.
---"cur": Relative to the current position. This is the default.
---"end": Relative to the end of the file.
---@param whence "set"|"cur"|"end" Where the offset is relative to
---@param offset integer The offset to seek to
---@return integer? pos The new position or nil if seeking failed
---@return string? reason The reason seeking failed
function fileWB.seek(whence, offset) local _ return _, _ end

---@class CCRednet
---@field CHANNEL_BROADCAST 65535 The channel used by the Rednet API to broadcast messages.
---@field CHANNEL_REPEAT 65533 The channel used by the Rednet API to repeat messages.
---@field MAX_ID_CHANNELS 65500 The number of channels rednet reserves for computer IDs. Computers with IDs greater or equal to this limit wrap around to 0.
rednet = rednet

local oldOpen = rednet.open
local oldClose = rednet.close
local oldSend = rednet.send
local oldBroadcast = rednet.broadcast
local oldReceive = rednet.receive
local oldIsOpen = rednet.isOpen
local oldHost = rednet.host
local oldUnhost = rednet.unhost
local oldLookup = rednet.lookup
local oldRun = rednet.run

---Opens a modem with the given peripheral name, allowing it to send and receive messages over rednet.
---@param modem string The name of the modem to open.
function rednet.open(modem) end

---Close a modem with the given peripheral name, meaning it can no longer send and receive rednet messages.
---@param modem? string The side the modem exists on. If not given, all open modems will be closed.
function rednet.close(modem) end

---Determine if rednet is currently open.
---@param modem string Which modem to check. If not given, all connected modems will be checked.
---@return boolean isOpen If the given modem is open.
function rednet.isOpen(modem) local _ return _ end

---Allows a computer or turtle with an attached modem to send a message intended for a sycomputer with a specific ID. At least one such modem must first be opened before sending is possible.
---@param recipient number The ID of the receiving computer.
---@param message any The message to send. Like with modem.transmit, this can contain any primitive type (numbers, booleans and strings) as well as tables. Other types (like functions), as well as metatables, will not be transmitted.
---@param protocol? string The "protocol" to send this message under. When using rednet.receive one can filter to only receive messages sent under a particular protocol.
---@return boolean sent If this message was successfully sent (i.e. if rednet is currently open). Note, this does not guarantee the message was actually received.
function rednet.send(recipient, message, protocol) local _ return _ end

---Broadcasts a string message over the predefined CHANNEL_BROADCAST channel. The message will be received by every device listening to rednet.
---@param message any The message to send. This should not contain coroutines or functions, as they will be converted to nil.
---@param protocol? string The "protocol" to send this message under. When using rednet.receive one can filter to only receive messages sent under a particular protocol.
function rednet.broadcast(message, protocol) end

---Wait for a rednet message to be received, or until timeout seconds have elapsed.
---@param protocolFilter? string The protocol the received message must be sent with. If specified, any messages not sent under this protocol will be discarded.
---@param timeout number The number of seconds to wait if no message is received.
---@return number | nil senderID The computer which sent this message OR nil if the timeout elapsed and no message was received.
---@return any message The received message
---@return string | nil protocol The protocol this message was sent under.
function rednet.receive(protocolFilter, timeout) local _ return _, _, _ end

---Wait for a rednet message to be received, or until timeout seconds have elapsed.
---@param protocolFilter? string The protocol the received message must be sent with. If specified, any messages not sent under this protocol will be discarded.
---@param timeout nil The number of seconds to wait if no message is received.
---@return number senderID The computer which sent this message OR nil if the timeout elapsed and no message was received.
---@return any message The received message
---@return string | nil protocol The protocol this message was sent under.
function rednet.receive(protocolFilter, timeout) local _ return _, _, _ end

---Register the system as "hosting" the desired protocol under the specified name. If a rednet lookup is performed for that protocol (and maybe name) on the same network, the registered system will automatically respond via a background process, hence providing the system performing the lookup with its ID number.
---@param protocol string The protocol this computer provides.
---@param hostname string The name this computer exposes for the given protocol.
function rednet.host(protocol, hostname) end

---Stop hosting a specific protocol, meaning it will no longer respond to rednet.lookup requests.
---@param protocol string The protocol to unregister your self from.
function rednet.unhost(protocol) end

---Search the local rednet network for systems hosting the desired protocol and returns any computer IDs that respond as "registered" against it.
---@param protocol string The protocol to search for.
---@param hostname? string The hostname to search for.
---@return number | nil ids Ccomputer IDs hosting the given protocol. nil of none exist
---@return ... More ids
function rednet.lookup(protocol, hostname) local _ return _ end

---Listen for modem messages and converts them into rednet messages, which may then be received. This is automatically started in the background on computer startup, and should not be called manually.
function rednet.run() end

rednet.open = oldOpen
rednet.close = oldClose
rednet.send = oldSend
rednet.broadcast = oldBroadcast
rednet.receive = oldReceive
rednet.isOpen = oldIsOpen
rednet.host = oldHost
rednet.unhost = oldUnhost
rednet.lookup = oldLookup
rednet.run = oldRun