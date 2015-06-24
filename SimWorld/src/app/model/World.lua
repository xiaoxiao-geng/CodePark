local World = class("World")

local TERRAIN_WIDTH = 3
local TERRAIN_HEIGHT = 3

function World:ctor()
	self.systems = self:_createSystems()

	self.terrain = self:_createTerrain()

	print("World.ctor")
end

function World:update(elapsed)
	print("World:update", elapsed)
	self:_updateSystems(elapsed)
end









----- system -----
function World:_createSystems()
	local systems = {}
	table.insert(systems, ul.WaterSystem:create(self))
	return systems
end

function World:_updateSystems(elapsed)
	local systems = self.systems
	for i = 1, #systems do
		systems[i]:update(elapsed)
	end
	return systems
end










----- terrain ------
function World:_createTerrain()
	local terrain = ul.Terrain:create(TERRAIN_WIDTH, TERRAIN_HEIGHT)
	return terrain
end











return World