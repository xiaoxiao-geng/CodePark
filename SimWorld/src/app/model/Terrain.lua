local Terrain = class("Terrain")

function Terrain:ctor(width, height)
	self.width = width
	self.height = height

	--[[
		关于cells的类型，采用二维数据结构最直观
		采用一维数组遍历快

		由于terrain创建后几乎不会改变，可以考虑将两个结构都保留
	]]
	self.cells = {}

	local cellArr = {}
	local cellGrid = {}

	local rows
	for y = 1, height do
		rows = {}
		for x = 1, width do
			local cell = ul.sTerrainCell:create()
			cellArr[#cellArr + 1] = cell
			rows[x] = cell

			-- TODO 写入坐标，方便调试
			cell.x = x
			cell.y = y
		end

		cellGrid[y] = rows
	end

	-- 创建邻居
	local cell
	for y = 1, height do
		for x = 1, width do
			cell = cellGrid[y][x]

			-- 查找邻居
			local neighbourCells = {}
			-- 右
			if x < width then
				neighbourCells[#neighbourCells + 1] = cellGrid[y][x + 1]
			end

			-- 下
			if y > 1 then
				neighbourCells[#neighbourCells + 1] = cellGrid[y - 1][x]
			end

			-- 左
			if x > 1 then
				neighbourCells[#neighbourCells + 1] = cellGrid[y][x - 1]
			end

			-- 上
			if y < height then
				neighbourCells[#neighbourCells + 1] = cellGrid[y + 1][x]
			end

			cell.neighbourCells = neighbourCells
		end
	end

	self.cellArr = cellArr
	self.cellGrid = cellGrid
end

return Terrain