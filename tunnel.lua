-- version: 0.7.1.20

--[[

			--  Written by JJSax  --
	Feel free to change any code to fit your needs.
	Any of my code you use credit me.

]]

--[[ -- todo section --
	Rednet to manipulate anywhere with correct protocall
		mostly for being able to recall/pause/resume from a home terminal
	logging events
	make block/torch configs a table
	dig chest config does nothing
]]

assert(http, 
[[

	HTTP is not enabled on your server.
	Please enable it in the config files,
	or ask your server admins to do it.
	Otherwise, visit the websites directly.

]])

local apis = {
	["files"] = "https://raw.githubusercontent.com/JJSax/computercraft/main/files.lua",
	["turtle"] = "https://raw.githubusercontent.com/JJSax/computercraft/main/turtle.lua",
	["location"] = "https://raw.githubusercontent.com/lyqyd/location/master/location",
}

for k,v in pairs(apis) do
	local path = "APIs/"..k..".lua"
	if not fs.exists(path) then 

		local response = http.get(v)
		assert(response, 
	[[
		
		No reply from server.  
		Check internet connection.  
		Github.com may be down.
		Otherwise, visit the websites directly.
		Stopped at file ]]..k
		)
		local file = fs.open(path, "w")
		if file then
			file.write(response.readAll())
			response.close()
			file.close()
		else
			error("There was a problem creating the file.")
		end
	end
end
os.loadAPI("APIs/files.lua")
os.loadAPI("APIs/location.lua")
require("APIs.turtle")


local function logPrefix()
	return os.day().." : "..os.clock().." -- "
end

local function clear()
	term.clear()
	term.setCursorPos(1,1)
end

local logList = {}
-- This may be uneccessary.  Creating a file to a non-existent dir creates the dir.
local function createFile(file, dir)
	-- create the file structure
	-- file is a table for file structure, key is folder or file name
	-- dir is mostly to be added recursively
	assert(type(file) == "table", "Parameter 1 needs to be a table.")
	dir = dir and dir or ""
	for k, v in pairs(file) do
		local f = dir.."/"..k
		if type(v) == "table" then
			if not fs.exists(f) then
				table.insert(logList, logPrefix().."Creating folder: "..f)
				fs.makeDir(f)
			end
			createFile(v, f) -- create new sub-folder
		elseif type(v) == "string" then
			local ndir = dir.."/"..k
			if not fs.exists(ndir) then
				table.insert(logList, logPrefix().."Creating file: "..ndir)
				files.write(ndir, v)
			end
		end
	end
end


-- init

local initFiles = {
	["config"] = {
		["tunnel.lua"] = 
[[return {
	["deposit_to_start_chest"] = true, -- will go back to start to deposit to chest at the start.
	["deposit_with_inv_chests"] = false, -- will use chests from the turtles inventory.
	["halt_if_full"] = true, -- if it has no chest to deposit to or inv gets full it will halt until emptied
	["suck_entities"] = true,
	["auto_refuel"] = true, -- true will use what it mines to refuel if needed. default is false
	["low_fuel_level"] = 500, -- warn when low on fuel. default 500
	["fuel_prerequisite"] = false, -- true means it needs enough fuel to complete mining

	["log_mining_list"] = true, -- will calculate blocks mined and what type at the end of run
	["mining_log_folder"] = "logs/tunnel",
	["mining_save_file"] = "saves/tunnel.lua",

	["wait_to_make_bridge"] = false, -- if true turtle will stop if it has no block to make bridge with and wait.
	["max_bridge_block_stock"] = 64, -- recommended as math.huge for valuable bridge blocks.
	["replace_bridge_blocks"] = false, -- if a block exists where it needs to place bridge, it will replace block.
	["block_prerequisite"] = 0, -- require block_minimum before run. number for minimum required

	-- nested tables.  [1] is full block name [2] is metadata.  Order by priority
	["default_bridge_blocks"] = {
		{"minecraft:cobblestone", 0}
	},
	["garbage_blocks"] = {
		{"minecraft:cobblestone", 0}
	},
	["inventories"] = { -- chests to use if it needs to deposit.
		{"minecraft:chest", 0},
		{"minecraft:barrel", 0},
		{"minecraft:trapped_chest", 0},

	},
	["fuel_blacklist"] = { -- fuel types to ignore.
		{"minecraft:chest", 0},
		{"minecraft:barrel", 0},
		{"minecraft:trapped_chest", 0},
	},
	["light_sources"] = {
		{"minecraft:torch", 0}
	},

	["light_frequency"] = 5, -- default 5
	["light_prerequisite"] = 0, -- number of light_sources needed torches to start on its own

	["distance_limit"] = math.huge, -- default math.huge
	["dig_chests"] = false, -- pause when it finds a chest where it needs to dig.

	["return_to_start"] = true -- goes to start when it is done
}
]]
	}, 
	-- ["saves"] = {},
	-- ["logs"] = {
	-- 	["tunnel"] = {}
	-- }
}



createFile(initFiles)
local config = require("config.tunnel")

local logName = #fs.list(config.mining_log_folder)..".txt"
local function log(str)
	local file = fs.combine(config.mining_log_folder, logName)
	files.append(file, logPrefix()..str)
end

local tArgs = {...}
if tArgs[1] == nil then
	clear()
	print("How far do you want to go?")
	tArgs[1] = read()
end
tArgs[1] = tonumber(tArgs[1])
assert(tArgs[1], "First argument needs to be a number.")
assert(tArgs[1] <= config.distance_limit, "Distance exeeds maximum limit of "..config.distance_limit)

local info = files.load(config.mining_save_file) or {
	traveled = 0,
	distance = tArgs[1] - 1,
	curMovement = 18,
	totalDug = 0,
	mineList = {},
	dumpTimes = 0,
	-- these are for ensuring item space in inventory before mining.
	matchSet = {}, -- blocks that drop same items as their block form.
	differSet = {}, -- blocks that drop other items (like coal ore)
	position = location.new(0,0,0,0),
	runTime = 0,
}


local startTime = os.clock()-info.runTime
local fuelStart = turtle.getFuelLevel()
files.save(config.mining_save_file, info)
files.write(config.mining_log_folder.."/"..logName, logList)
if config.deposit_with_inv_chests and config.deposit_to_start_chest then
	log(
[[Both deposit methods enabled.  
	Defaulting to depositing to start chest.]])
	config.deposit_with_inv_chests = false
end
log("Finished initializing file")

-- Main

function mainScreen()

end

-- cleanup
fs.delete(config.mining_save_file) -- delete save file

error("EOF")

function mainScreen() -- try moving to top\
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1, 1)
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)

	jj.output.setBackgroundColor(colors.lightBlue)
	jj.output.clearLines()
	jj.output.setTextColor(colors.gray)
	jj.output.write("Fuel used: ", 1, 1)
	jj.output.setTextColor(colors.blue)
	jj.output.write(fuelStart - turtle.getFuelLevel())
	jj.output.setTextColor(colors.gray)
	jj.output.write(" - Current Fuel: ")
	if turtle.getFuelLevel() < (distance - dist) * 9 + distance * 2 then
		jj.output.setTextColor(colors.red)
	elseif turtle.getFuelLevel() < settings.get("low_fuel_level") then
		jj.output.setTextColor(colors.orange)
	else
		jj.output.setTextColor(colors.blue)
	end
	jj.output.write(turtle.getFuelLevel())

	jj.output.setTextColor(colors.white)
	jj.output.setBackgroundColor(colors.blue)
	jj.output.write("Blocks dug:", 1, 5)
	jj.progressBar(totalDug, (dist + 1) * 9, 13, 5, 26, 1, true, {text = colors.black, inactive = colors.lightBlue, active = colors.blue})
	if totalDug > (distance + 1) * 9 then
		jj.output.setBackgroundColor(colors.red)
		jj.output.write(" ", jj.output.getWidth(), 5)
	end

	--* making the pause button
	-- jj.output.setBackgroundColor(colors.orange)	
	-- jj.graphics.circle("fill", 25, 5, 2.1)
	-- jj.output.setBackgroundColor(colors.white)
	-- jj.output.setCursorPos(23, 4)
	-- jj.output.write(" ")
	-- jj.output.setCursorPos(25, 4)
	-- jj.output.write(" ")
	-- jj.output.setCursorPos(23, 5)
	-- jj.output.write(" ")
	-- jj.output.setCursorPos(25, 5)
	-- jj.output.write(" ")

	jj.output.setTextColor(colors.lightBlue)
	jj.output.setBackgroundColor(colors.black)
	jj.output.write("- Distance Traveled -", "center", 7)
	jj.progressBar(dist, distance+1, 2, 8, 36, 1, true, {active = colors.green, inactive = colors.orange, text = colors.black})
end

function sort()
	for c = 1 , 15 do
		if ( turtle.getItemCount( c ) > 0 ) and ( turtle.getItemSpace( c ) > 0 )then
			turtle.select( c )
			for t = c + 1 , 16 do
				if turtle.compareTo( t ) and (turtle.getItemSpace( c ) > 0) then
					local items0 = turtle.getItemSpace( c )
					turtle.select( t )
					turtle.transferTo(c, items0)
					turtle.select( c )
				end
			end
		end
	end

	for c = 1 , 15 do
		if turtle.getItemCount( c ) == 0 then
			for t = c + 1 , 16 do
				if turtle.getItemCount( t ) > 0 then
					turtle.select( t )
					turtle.transferTo(c, turtle.getItemCount( t ))
					turtle.select( c )
				end
			end
		end
	end
end

function checkTorches()
	torchesNeeded = math.floor((distance - traveled) / settings.get("torch_frequency")) + 1
	torchNumb = 0
	if settings.get("torch_prerequisite") == true then
		for i = 1, 16 do
			if turtle.getItemCount(i) > 0 then
				local data = turtle.getItemDetail(i)
				if data.name == settings.get("torch_name") and
				data.damage == settings.get("torch_id") then
					torchNumb = torchNumb + turtle.getItemCount(i)
				end
			end
		end
		if torchNumb >= torchesNeeded then
			return true
		end
	elseif settings.get("torch_prerequisite") == false then 
		return true
	end
	return math.floor(torchesNeeded-torchNumb) --* not always right
end

function placeTorch()
	if jjt.findItem(settings.get("torch_name"), settings.get("torch_id")) then
		jjt.place(settings.get("torch_name"), settings.get("torch_id"),true)
		turtle.select(1)
	end
end

function placeChest() -- may just use what is in the function.
	jjt.place("minecraft:chest")
end

function checkFuel() --* add log for why things are false
	if settings.get("fuel_prerequisite") == true then
		local fuelAdd = 0
		if settings.get("3_wide_bridge") == true then
			fuelAdd = 4
		end
		if turtle.getFuelLevel() < (5 * distance) + fuelAdd then
			return (5 * distance) + fuelAdd - turtle.getFuelLevel()
		end	
	else
		if turtle.getFuelLevel() < settings.get("low_fuel_level") then
			return settings.get("low_fuel_level") - turtle.getFuelLevel()
		end
		return true
	end
	return true
end

function refuel(minFuel)
	local fuellev = minFuel
	if fuellev == nil then
		fuellev = settings.get("low_fuel_level")
	end
	if turtle.getFuelLevel() > fuellev then return end
	for i = 1, 16 do
		if turtle.getItemCount(i) > 0 then
			local data = turtle.getItemDetail(i)
			if data.name ~= "minecraft:chest" then
				turtle.select(i)
				if turtle.refuel(0) then
					local fuelNeeded = fuellev - turtle.getFuelLevel()
					local fuelStart = turtle.getFuelLevel()
					turtle.refuel(1)
					local fuelGained = turtle.getFuelLevel() - fuelStart
					if turtle.getItemCount(i) >= math.ceil(fuelNeeded / fuelGained) then
						turtle.refuel(math.ceil(fuelNeeded / fuelGained))
						turtle.select(1)
						return true
					else
						turtle.refuel(turtle.getItemCount(i))
					end
				end
			end
		end
	end
	turtle.select(1)
end

function checkBlocks()
	local blocks = 0
	if settings.get("block_prerequisite") == true then
		for i = 1, 16 do
			if turtle.getItemCount(i) > 0 then
				data = turtle.getItemDetail(i)
				if data.name == settings.get("default_bridge_block") and 
				data.damage == settings.get("default_bridge_meta") then
					blocks = blocks + turtle.getItemCount(i)
				end
				if blocks >= settings.get("block_minimum") then
					return true
				end
			end
		end
	elseif settings.get("block_prerequisite") == false then
		return true
	end
	return settings.get("block_minimum") - blocks
end

function checkInventory()
	-- checks for full inventory
	for i = 1, 16 do
		if turtle.getItemCount(i) == 0 then
			return false
		end
	end
	return true
end

function dumpInventory(  )
	local build = 0
	for i = 1, 16 do
		if turtle.getItemCount(i) > 0 then
			data = turtle.getItemDetail(i)

			if data.name ~= "minecraft:chest" then
				if data.name ~= settings.get("torch_name") or data.damage ~= settings.get("torch_id") then
					turtle.select(i)
					if data.name == settings.get("default_bridge_block") and build < settings.get("block_minimum") then
						if turtle.getItemCount(i) > settings.get("block_minimum") then
							turtle.drop(turtle.getItemCount(i) - settings.get("block_minimum"))
						end
						build = build + turtle.getItemCount(i)
					else
						turtle.drop()
					end
				end
			end
		end
	end
	sort()
	dumpTimes = dumpTimes + 1
	turtle.select(1)
end

--* log the type of blocks dug
local function checkdig()
	while turtle.detect() do
		local _, data = turtle.inspect()
		addToMiningLog(data.name)
		turtle.dig()
		totalDug=totalDug+1
		mainScreen()
		save()
		sleep(.5)
	end
	while settings.get("suck_entities") == true and turtle.suck() do end
	while settings.get("halt_if_full") == true and 
	settings.get("deposit_with_inv_chests") == false and 
	settings.get("deposit_to_start_chest") == false and
	checkInventory() == true do
		sleep(.5)
	end
end

local function checkdigUp()
	while settings.get("suck_entities") == true and turtle.suckUp() do end
	while turtle.detectUp() do
		local _, data = turtle.inspectUp()
		addToMiningLog(data.name)
		turtle.digUp()
		totalDug=totalDug+1
		mainScreen()
		save()
		sleep(.5)
	end
	while settings.get("halt_if_full") == true and 
	settings.get("deposit_with_inv_chests") == false and 
	settings.get("deposit_to_start_chest") == false and
	checkInventory() == true do
		sleep(.5)
	end
end

local function checkdigDown()
	while settings.get("suck_entities") == true and turtle.suckDown() do end
	while turtle.detectDown() do
		local _, data = turtle.inspectDown()
		addToMiningLog(data.name)
		turtle.digDown()
		totalDug=totalDug+1
		mainScreen()
		save()
		sleep(.5)
	end
	while settings.get("halt_if_full") == true and 
	settings.get("deposit_with_inv_chests") == false and 
	settings.get("deposit_to_start_chest") == false and
	checkInventory() == true do
		sleep(.5)
	end
end

function checkdigLeft()
	turtle.turnLeft()
	curMovement = jj.numberLoop(curMovement, 1, 18, 1)
	save()
	checkdig()
	turtle.turnRight()
	curMovement = jj.numberLoop(curMovement, 1, 18, 1)
	save()
end

function checkdigRight()
	turtle.turnRight()
	curMovement = jj.numberLoop(curMovement, 1, 18, 1)
	save()
	checkdig()
	turtle.turnLeft()
	curMovement = jj.numberLoop(curMovement, 1, 18, 1)
	save()
end


function checkplaceDown()
	if type(jjt.findItem(settings.get("default_bridge_block"), settings.get("default_bridge_meta"))) == "number" then
		select(jjt.findItem(settings.get("default_bridge_block"),settings.get("default_bridge_meta")))
		jjt.placeDown(settings.get("default_bridge_block"), settings.get("default_bridge_meta"), settings.get("replace_bridge_blocks"))
		return
	end
	while not turtle.detectDown() do
		for i = 1, 16 do
			if turtle.getItemCount(i) > 0 then
				local data = turtle.getItemDetail(i)
				if data.name ~= "minecraft:chest" and
				data.name ~= settings.get("torch_name") then
					turtle.select(i)
					if turtle.placeDown() then break end
				end
			end
		end
		if settings.get("wait_to_make_bridge") == true then
			sleep(.5)
			checkplaceDown()
		else
			return
		end
	end
end

function startingScreen()
	--* change line if previous is met or say it's fulfilled?
	jj.output.setTextColor(colors.white)
	jj.output.setBackgroundColor(colors.black)
	if checkTorches() ~= true then
		jj.output.write("Need "..checkTorches().." more torches.", 1, 1)
	else
		jj.output.clearLines(1, 1)
	end
	if checkBlocks() ~= true then
		jj.output.write("Need "..checkBlocks().." more blocks.", 1, 2)
	else
		jj.output.clearLines(2, 2)
	end
	if checkFuel() ~= true then
		jj.output.write("Need "..checkFuel().." more fuel.", 1, 3)
	else
		jj.output.clearLines(3, 3)
	end
	jj.output.write("Press any key to skip", "center", 8)
end



i = 0
timer = os.startTimer(1)
jj.output.clear()

while checkTorches() ~= true or checkBlocks() ~= true or checkFuel() ~= true do 
	startingScreen()
	if settings.get("fuel_prerequisite") == true and settings.get("auto_refuel") == true then
		refuel(9 * (distance - traveled))
	end
	local evt, arg = os.pullEvent()
	if evt == "timer" then
		if arg == timer then
			timer = os.startTimer(1)
		end
	elseif evt == "char" then
		break
	end
end

jj.output.clear()
torch = settings.get("torch_frequency")
for i = traveled, distance do
	dist = i
	checkdig()
	while not turtle.forward() do end
	mainScreen()
	checkdigLeft()
	checkdigRight()
	checkdigUp()
	while not turtle.up() do end
	mainScreen()
	checkdigLeft()
	if i % settings.get("torch_frequency") == 0 then
		turtle.turnRight()
		placeTorch()
		turtle.turnLeft()
	else
		checkdigRight()
	end
	checkdigDown()
	while not turtle.down() do end
	checkdigDown()
	while not turtle.down() do end
	mainScreen()
	if settings.get("narrow_bridge") == true then
		checkplaceDown()
		checkdigLeft()
		checkdigRight()
	elseif settings.get("3_wide_bridge") == true then
		checkplaceDown()
		turtle.turnLeft()
		checkdig()
		while not turtle.forward() do end
		mainScreen()
		checkplaceDown()
		jjt.flip()
		while not turtle.forward() do end
		mainScreen()
		checkdig()
		while not turtle.forward() do end
		mainScreen()
		checkplaceDown()
		turtle.back()
		mainScreen()
		turtle.turnLeft()
	elseif settings.get("3_wide_bridge") == false and settings.get("narrow_bridge") == false then
		checkdigLeft()
		checkdigRight()
	end
	-- check full inv if chest condition
	if checkInventory() == true then
		if settings.get("deposit_with_inv_chests") == true then
			if jjt.findItem("minecraft:chest", 0) ~= false then
				-- place and deposit into chest
				turtle.turnRight()
				jjt.place("minecraft:chest", 0)
				dumpInventory()
				turtle.turnLeft()
			else
				-- wait to clear inventory
				--* this may not work properly.  Will wait for a chest instead of cleared inv
				print("waiting")
				sleep(10)
			end
		end
	end
	while not turtle.up() do end
	if turtle.getFuelLevel() < settings.get("low_fuel_level") then
		refuel()
	end
	if checkInventory() == true then
		if settings.get("deposit_to_start_chest") == true then
			jjt.flip()
			for di = 1, i+1 do 
				while not turtle.forward() do end
			end
			mainScreen()
			dumpInventory()
			jjt.flip()
			for di = 1, i+1 do 
				while not turtle.forward() do end
			end
			mainScreen()
		end
	end

end

if settings.get("return_to_start") then
	jjt.flip()
	for i = 1, distance + 1 do
		while not turtle.forward() do end
	end
	mainScreen()
	dumpInventory()
	jjt.flip()
end

jj.output.setBackgroundColor(colors.black)
jj.output.clear()
jj.output.setTextColor(colors.lime)
jj.output.write("Tunneling Complete!", "center", 1)
jj.output.setTextColor(colors.magenta)
jj.output.write("- Statistics -", "center", 3)
-- jj.output.setBackgroundColor(colors.lime)
-- jj.output.clearLines(4, 15)
jj.output.setTextColor(colors.white)
jj.output.setBackgroundColor(colors.blue)
jj.output.write("Blocks dug:", 1, 4)
jj.progressBar(totalDug, (distance + 1) * 9, 13, 4, 26, 1, true, {text = colors.black, inactive = colors.lightBlue, active = colors.blue})
if totalDug > (distance + 1) * 9 then
	jj.output.setBackgroundColor(colors.red)
	jj.output.write(" ", jj.output.getWidth(), 4)
end

jj.output.setCursorPos(1, 13)
jj.output.setBackgroundColor(colors.green)
jj.output.setTextColor(colors.gray)
jj.output.clearLines( 6, 12)
jj.output.write("Dumped to the chest ", 1, 7)
jj.output.setTextColor(colors.blue)
jj.output.write(dumpTimes)
jj.output.setTextColor(colors.gray)
jj.output.write(" times.")

jj.output.setBackgroundColor(colors.green)
jj.output.setTextColor(colors.gray)
jj.output.write("Fuel used: ", 1, 9)
jj.output.setTextColor(colors.blue)
jj.output.write(fuelStart - turtle.getFuelLevel())
jj.output.setTextColor(colors.gray)
jj.output.write(" - Current Fuel: ")
if turtle.getFuelLevel() < settings.get("low_fuel_level") then
	jj.output.setTextColor(colors.red)
else
	jj.output.setTextColor(colors.blue)
end
jj.output.write(turtle.getFuelLevel())

local time = os.clock() - startTime
local minutes = time / 60
if minutes < 1 then minutes = 0 end
local seconds = math.floor(time - time / 60)
jj.output.setBackgroundColor(colors.green)
jj.output.setTextColor(colors.gray)
jj.output.setCursorPos(1, 11)
jj.output.write("It took ")
jj.output.setTextColor(colors.blue)
jj.output.write(minutes)
jj.output.setTextColor(colors.gray)
jj.output.write(" minutes and ")
jj.output.setTextColor(colors.blue)
jj.output.write(seconds)
jj.output.setTextColor(colors.gray)
jj.output.write(" seconds.")

jj.output.setBackgroundColor(colors.black)
jj.output.setCursorPos(1, 13)
jj.output.clearLines()

-- delete save file
fs.delete(settings.get("mining_save_file"))
