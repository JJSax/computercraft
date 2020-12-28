-- load this file using require(string_path_to_this_file)
assert(turtle, "This API is designed specifically for turtles.")

local oTurtle = {}
for k,v in pairs(turtle) do
	oTurtle[k] = v
end

turtle.invSize = 16

local function slots() -- slot iterator
	local default = {name = nil, damage = nil, count = 0}
	local i = 0
	return function ()
		i = i + 1
		if i <= turtle.invSize then
			local info = oTurtle.getItemDetail(i)
			return i, info and info or default
		end
	end
end

function turtle.getItemCount(item, damage)
	if type(item) == "number" then
		return oTurtle.getItemCount(item)
	end
	local c = 0
	for i, info in slots() do
		if info.name == item and 
		  (damage and data.damage == damage or true) then
		  	c = c + info.count
		end
	end
	return c
end
function turtle.getItemSpace(item, damage)
	if type(item) == "number" then
		return oTurtle.getItemSpace(item)
	end
	local c = 0
	for i, info in slots() do
		if info.name == item and 
		  (damage and data.damage == damage or true) then
		  	c = c + oTurtle.getItemSpace(i)
		end
	end
	return c
end

function turtle.getInventorySpace(slotOnly)
	-- slot only is if the slot has nothing in it
	local space = 0
	for i = 1, 16 do
		if slotOnly then
			space = space + (turtle.getItemCount(i) == 0 and 1 or 0)
		else
			space = space + turtle.getItemSpace(i)
		end
	end
	return space
end

function turtle.transferTo(slot, quantity)
	local space = turtle.getItemSpace(slot)
	if oTurtle.transferTo(slot, quantity) then
		return true, math.min(space, quantity ~= nil and quantity or space)
	end
	return false
end

function turtle.find(item, damage)
	-- returns first slot given item is in
	for i = 1, 16 do
		if turtle.getItemCount(i) > 0 then
			local data = turtle.getItemDetail(i)
			if data.name == item and (damage and data.damage == damage or true) then
				return i
			end
		end
	end
	return false
end

function turtle.selectItem(name, damage)
	local slot = turtle.find(item, damage)
	if slot then 
		turtle.select(slot) 
		return true 
	end
	return false
end

function turtle.isEmpty()
	for i = 1, turtle.invSize do
		if turtle.getItemCount(i) > 0 then
			return false
		end
	end
	return true
end
function turtle.emptySlots()
	local output = {}
	for i = 1, turtle.invSize do
		if turtle.getItemCount(i) == 0 then
			table.insert(output, i)
		end
	end
	return output
end
function turtle.firstEmptySlot()
	for i = 1, 16 do
		if turtle.getItemCount(i) == 0 then
			return i
		end
	end
end

function turtle.flip(pick)
	local character = {turtle.turnLeft, turtle.turnRight}
	local pick = pick and pick or character[math.random(1, 2)] -- pick random direction to turn 
	character[pick]()
	character[pick]()
end



local pbsides = {
	placeBlock = "place",
	placeBlockUp = "placeUp",
	placeBlockDown = "placeDown",
	dropItem = "drop",
	dropItemUp = "dropUp",
	dropItemDown = "dropDown"
}
for k,v in pairs(pbsides) do
	turtle[k] = function(name, damage, ext)
		for i, info in slots() do
			if info.name == name and info.damage == damage then
				turtle.select(i)
				return oTurtle[v](ext)
			end
		end
		return false, "object '"..name.."' not found."
	end
end

function turtle.sort(ordered)
	local function compare(s1, s2)
		for k,v in pairs(s1) do
			if k ~= "count" then
				if s2[k] ~= v then
					return false
				end
			end
		end
		return true
	end

	local empty = {name = nil, damage = nil, count = 0}
	local sInfo = {}
	for slot, info in slots() do
		sInfo[slot] = info
	end

	for s = 1, 15 do
		for c = s + 1, 16 do
			if compare(sInfo[s], sInfo[c]) and sInfo[s].count > 0 then
				turtle.select(c)
				if turtle.compareTo(s) then -- double check in case NBT difference
					local suc, moved = turtle.transferTo(s)
					sInfo[s].count = sInfo[s].count + moved
					sInfo[c].count = sInfo[c].count - moved
					if turtle.getItemCount(c) == 0 then
						sInfo[c] = empty
					end
				end
			end
		end
	end

	-- fill holes
	for c = 1 , 15 do
		if turtle.getItemCount( c ) == 0 then
			for t = c + 1 , 16 do
				if turtle.getItemCount( t ) > 0 then
					turtle.select( t )
					turtle.transferTo( c, 64 )
				end
			end
		end
	end
end
