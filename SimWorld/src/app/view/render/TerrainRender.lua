local TerrainRender = class("TerrainRender", function()
	return display.newNode()
	end)

function TerrainRender:ctor(terrain)
	self.width = terrain.width * ul.RENDER_CELL_WIDTH
	self.height = terrain.height * ul.RENDER_CELL_HEIGHT

	-- 创建CellRender
	local grid = terrain.cellGrid
	local cell
	for y = 1, terrain.height do
		for x = 1, terrain.width do
			cell = grid[y][x]

			local cellRender = ul.CellRender:create(cell, ul.RENDER_CELL_WIDTH, ul.RENDER_CELL_HEIGHT)
				:addTo(self)
				:move((x - 1) * ul.RENDER_CELL_WIDTH, (y - 1) * ul.RENDER_CELL_HEIGHT)
		end
	end

	self:setContentSize(self.width, self.height)
end

return TerrainRender