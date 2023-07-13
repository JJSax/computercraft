
--currently designed for dfs but plans to make more robust

local moves = {}
math.randomseed(os.time())

moves.facingMap = {
	vector.new( 0, 0, 1),
	vector.new( 1, 0, 0),
	vector.new( 0, 0,-1),
	vector.new(-1, 0, 0),
}

function moves.modDir(c, dir) return (c + (dir-1)) % 4 + 1 end
function moves.turnLeft(grid)
	grid.facing = moves.modDir(grid.facing, -1)
	return turtle.turnLeft() -- always true
end
function moves.turnRight(grid)
	grid.facing = moves.modDir(grid.facing, 1)
	return turtle.turnRight() -- always true
end
function moves.flip(grid) -- random left/right turns for character
	local m = {moves.turnLeft, moves.turnRight}
	local c = math.random(1, 2)
	m[c](grid)
	m[c](grid)
	return true
end
function moves.forward(grid)
	if not turtle.forward() then return false end
	grid.pos = grid.pos + moves.facingMap[grid.facing]
	return true
end
function moves.back(grid)
	if not turtle.back() then return false end
	grid.pos = grid.pos - moves.facingMap[grid.facing]
	return true
end
function moves.up(grid)
	if not turtle.up() then return false end
	grid.pos = grid.pos + vector.new(0, 1, 0)
	return true
end
function moves.down(grid)
	if not turtle.down() then return false end
	grid.pos = grid.pos + vector.new(0, -1, 0)
	return true
end

function moves.faceDir(grid, dir)
	--@dir is index of facingMap
    local diff = (dir - grid.facing) % 4
    if diff == 0 then return end
	if diff == 1 then moves.turnRight(grid) end
	if diff == 2 then moves.flip(grid) end
	if diff == 3 then moves.turnLeft(grid) end
end

function moves.faceAdjacent(grid, pos)

	-- requires pos to be adjacent
	local found1
	for k, v in pairs(pos) do
		local pv = math.abs(v)
		assert(pv == 1 or pv == 0, "All Values passed must be -1/0/1. Recieved: ".. tostring(pos))
		if pv == 1 then
			assert(not found1, "Cannot pass a non-adjacent position. Recieved: ".. tostring(pos))
			found1 = true
		end
	end

	if pos.z == 1 then moves.faceDir(grid, 1) end
	if pos.x == 1 then moves.faceDir(grid, 2) end
	if pos.x ==-1 then moves.faceDir(grid, 3) end
	if pos.z ==-1 then moves.faceDir(grid, 4) end

end

function moves.facePos(grid, pos)
	moves.faceAdjacent(grid, grid.pos - pos)
end

return moves

