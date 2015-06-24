--[[
	单位
	长度：米
	体积：立方米
	重量：千克
]]
local sTerrainCell = class("sTerrainCell")









----- 构造 -----
function sTerrainCell:init()
	self.area = 1 * 1

	-- 云层
	self.cloudWaterMass = 0
	self.cloudHeight = 1

	-- 空气层
	self.airWaterMass = 0
	self.airHeight = 100

	-- 水
	self.waterMass = 0
	self.waterHeight = 0 	-- PS 这个值通过waterMass计算所得

	-- 地面
	self.groundWaterMass = 0
	self.groundHeight = 1
end









----- 辅助方法 -----








return sTerrainCell