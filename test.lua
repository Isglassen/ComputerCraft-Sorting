local programPath = fs.combine(shell.getRunningProgram(), "../")

-- Load all tests/*.lua files and run them
for _, path in pairs(fs.find(fs.combine(programPath, "./tests/*.lua"))) do
  shell.run(path)
end
