import "CoreLibs/graphics"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics
local cellSize = 4
local rows = playdate.display.getHeight() / cellSize
local cols = playdate.display.getWidth() / cellSize
maxIterations = 150

cells = table.create(rows, 0)
iterations = table.create(maxIterations, 0)

local function drawCell(row, col)
	if cells[row][col] then
		local x = (col - 1) * cellSize
		local y = (row - 1) * cellSize
		gfx.fillRect(x, y, cellSize, cellSize)
	end
end

local function tickCell(row, col)
	local liveNeighbors = 0
	local alive = cells[row][col]
	
	for nRow = math.max(row - 1, 1), math.min(row + 1, rows) do
		for nCol = math.max(col - 1, 1), math.min(col + 1, cols) do
			if nRow ~= row or nCol ~= col then
				liveNeighbors += cells[nRow][nCol] and 1 or 0
			end
		end
	end
	
	if not alive then
		-- Any dead cell with three live neighbors becomes a live cell.
		cells[row][col] = liveNeighbors == 3
	else
		-- Any live cell with two or three live neighbors survives.
		-- All other live cells die in the next generation. Similarly, all other dead cells stay dead.
		cells[row][col] = liveNeighbors == 2 or liveNeighbors == 3
	end
end

local function advanceSimulation()
	if #iterations == maxIterations then
		table.remove(iterations, 1)
	end
	
	table.insert(iterations, table.deepcopy(cells))
	
	for row = 1, rows do
		for col = 1, cols do
			tickCell(row, col)
		end
	end
end

local function reverseSimulation()
	cells = table.remove(iterations) or cells
end

local function setUpGame()
	local z = math.random()
	local modifier = math.random() * 0.5
	for row = 1, rows do
		cells[row] = table.create(cols, 0)
		
		for col = 1, cols do
			local noise = playdate.graphics.perlin(row/rows + modifier, col/cols + modifier, z + modifier, 8, 4, math.random())
			local alive = noise > 0.5
			cells[row][col] = alive
			drawCell(row, col)
		end
	end
end

setUpGame()

function playdate.update()
	local crankTicks = playdate.getCrankTicks(10)
	local updated = crankTicks ~= 0
	
	if crankTicks > 0 then
		advanceSimulation()
	elseif crankTicks < 0 then
		reverseSimulation()
	end
	
	if updated then
		gfx.clear()
		for row = 1, rows do
			for col = 1, cols do
				drawCell(row, col)
			end
		end
	end
end
