local WaterSystem = class("WaterSystem", ul.SystemBase)









----- 继承方法 -----
function WaterSystem:update(elapsed)
	print("WaterSystem.update", elapsed)

	local cells = self.world.terrain.cellArr
	for _, cell in pairs(cells) do
		print(string.format("%d: [%d, %d]", _, cell.x, cell.y))

		for _, ncell in pairs(cell.neighbourCells) do
			print(string.format("  neighbour%d: [%d, %d]", _, ncell.x, ncell.y))
		end
	end
end









----- 内部方法 -----











return WaterSystem