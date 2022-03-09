import "CoreLibs/graphics"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics
local cellSize = 4
local rows = playdate.display.getHeight() / cellSize
local cols = playdate.display.getWidth() / cellSize

local cells = table.create(rows, 0)
local iterations = {}

local function createCell(row, col, alive)
	return {
		row = row,
		col = col,
		x = (col - 1) * cellSize,	
		y = (row - 1) * cellSize,
		w = cellSize,
		h = cellSize,
		alive = alive,
		draw = function(self)
			if self.alive then
				gfx.fillRect(self.x, self.y, self.w, self.h)
			end
		end,
		tick = function(self)
			local liveNeighbors = 0
			for nRow = math.max(self.row - 1, 1), math.min(self.row + 1, rows) do
				for nCol = math.max(self.col - 1, 1), math.min(self.col + 1, cols) do
					if nRow ~= self.row or nCol ~= self.col then
						liveNeighbors += cells[nRow][nCol].alive and 1 or 0
					end
				end
			end
			
			if not self.alive then
				-- Any dead cell with three live neighbors becomes a live cell.
				self.alive = liveNeighbors == 3
			else
				-- Any live cell with two or three live neighbors survives.
				-- All other live cells die in the next generation. Similarly, all other dead cells stay dead.
				self.alive = liveNeighbors == 2 or liveNeighbors == 3
			end
		end
	}
end

local function advanceSimulation()
	table.insert(iterations, table.deepcopy(cells))
	
	for row = 1, rows do
		for col = 1, cols do
			cells[row][col]:tick()
		end
	end
end

local function reverseSimulation()
	cells = table.remove(iterations) or cells
end

local function setUpGame()
	for row = 1, rows do
		cells[row] = table.create(cols, 0)
		for col = 1, cols do
			local cell = createCell(row, col, math.random() > 0.69)
			cell:draw()
			cells[row][col] = cell
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
				cells[row][col]:draw()
			end
		end
	end
end
