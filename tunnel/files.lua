-- 
-- Table saveing and loading

function save(sPath, table)
	local file = fs.open(sPath,"w")
	if file then
		file.write(textutils.serialize(table))
		file.close()
	end
end
function load(sPath)
	local file = fs.open(sPath,"r")
	if file then
		local data = file.readAll()
		file.close()
		return textutils.unserialize(data)
	end
end

-- if you want to write text to a file do this:
function write(sPath, text)
	if type(text) == "table" then
		text = table.concat(text, "\n")
	end
	local file = fs.open(sPath,"w")
	if file then
		file.write(text)
		file.close()
	end
end
function read(sPath)
	local file = fs.open(sPath,"r")
	if file then
		local data = file.readAll()
		file.close()
		return data
	end
end
function append(sPath, text)
	local fHandle = fs.open(sPath, fs.exists(sPath) and "a" or "w")
	if fHandle then
		fHandle.writeLine(text)
		fHandle.close()
	end
end
