local MainScene = class("MainScene", mvc.ViewBase)

function MainScene:onCreate()
	local world = ul.World:create()
	self.world = world

	local terrainRender = ul.TerrainRender:create(world.terrain)
		:addTo(self)
		:move(100, 100)

	dump(world)

	ul.Tools.createDebugMenu({
			{
				"update",
				function()
					print("update", 0.1)
					self.world:update(0.1)
				end,		
			},
		})
		:addTo(self)
		:move(100, display.height - 100)
end

function MainScene:onEnter()
	print("MainScene.onEnter")
end

function MainScene:onExit()
	print("MainScene.onExit")
end

return MainScene
