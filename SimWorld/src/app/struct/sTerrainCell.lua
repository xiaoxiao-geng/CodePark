--[[
	单位
	长度：米
	体积：立方米
	重量：千克
]]
local sTerrainCell = class("sTerrainCell")









----- 构造 -----
function sTerrainCell:ctor()
	self.area = 1 * 1

	-- 云层
	self.cloudWaterMass = 0
	self.cloudHeight = 4

	-- 空气层
	self.airWaterMass = 0
	self.airHeight = 1000

	-- 水
	self.pondWaterMass = 0

	-- 地面
	self.groundWaterMass = 0
	self.groundHeight = 1



	--- 由外部赋值
	self.x = 0
	self.y = 0
	self.neighbourCells = {}
end









----- 辅助方法 -----








return sTerrainCell