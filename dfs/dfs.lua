-- require "turtle"
local moves = require "moves"

local dfs = {}

local opts = {...}

local function checkWin()
	local f, b = turtle.inspectDown()
	local wBlock = turtle.getItemDetail(1)
	return f and b.name == wBlock.name and b.metadata == wBlock.damage
end

local function adjacent(grid)

	local f = grid.facing
	local i = 0
	return function()
		while i < 4 do
			i = i + 1
			f = moves.modDir(grid.facing, i-1)

			local checkVec = grid.pos + moves.facingMap[f]
			if not grid.cells[checkVec.x]
			or not grid.cells[checkVec.x][checkVec.z] then
				moves.faceDir(grid, f)
				grid.cells[checkVec.x] = grid.cells[checkVec.x] or {}
				grid.cells[checkVec.x][checkVec.z] = grid.cells[checkVec.x][checkVec.z] or {}

				local found, bDat = turtle.inspect()
				grid.cells[checkVec.x][checkVec.z].block = bDat

				if not found and not grid.cells[checkVec.x][checkVec.z].visited then
					return checkVec, grid.facing
				end

			end
		end
	end
end

local function allAdjacent(grid)
	--* same thing as the adjacent function but scans all blocks before moving forward
	local nextCache = {}
	for vec, eVec in adjacent(grid) do
		table.insert(nextCache, {vec, eVec})
	end

	local i = 0
	return function()
		i = i + 1
		if nextCache[i] then
			moves.faceDir(grid, nextCache[i][2])
			return nextCache[i][1], nextCache[i][2]
		end
	end

end

local adjacent = opts[1] == "all" and allAdjacent or adjacent

function dfs.recurse(G, v)

	--@ v is the cell coords just moved into
	G.cells[v.x][v.z].visited = true

	for w, entryVector in adjacent(G) do
		--@ w is actual cell coords of adjacent cell
		moves.forward(G)
		if checkWin() or dfs.recurse(G, w) then return true end

		-- go back to previous cell if dead end
		moves.faceDir(G, moves.modDir(entryVector, 2))
		assert(moves.forward(G), "Critical: Failed forward move!")
	end


end


function dfs.run()

	local grid = {
		pos = vector.new(0,0,0),
		facing = 1,
		cells = { [0] = { [0] = {} } }
	}

	if checkWin() or dfs.recurse(grid, grid.pos) then
		print("VICTORY")
	end

end

dfs.run()
